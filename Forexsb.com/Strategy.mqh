//+--------------------------------------------------------------------+
//| Copyright:  (C) 2016 Forex Software Ltd.                           |
//| Website:    http://forexsb.com/                                    |
//| Support:    http://forexsb.com/forum/                              |
//| License:    Proprietary under the following circumstances:         |
//|                                                                    |
//| This code is a part of Forex Strategy Builder. It is free for      |
//| use as an integral part of Forex Strategy Builder.                 |
//| One can modify it in order to improve the code or to fit it for    |
//| personal use. This code or any part of it cannot be used in        |
//| other applications without a permission.                           |
//| The contact information cannot be changed.                         |
//|                                                                    |
//| NO LIABILITY FOR CONSEQUENTIAL DAMAGES                             |
//|                                                                    |
//| In no event shall the author be liable for any damages whatsoever  |
//| (including, without limitation, incidental, direct, indirect and   |
//| consequential damages, damages for loss of business profits,       |
//| business interruption, loss of business information, or other      |
//| pecuniary loss) arising out of the use or inability to use this    |
//| product, even if advised of the possibility of such damages.       |
//+--------------------------------------------------------------------+

#property copyright "Copyright (C) 2016 Forex Software Ltd."
#property link      "http://forexsb.com"
#property version   "2.00"
#property strict

#include <Forexsb.com/Enumerations.mqh>
#include <Forexsb.com/IndicatorSlot.mqh>

//## Import Start

class Strategy
{
private:
    // Fields
    string strategySymbol;
    DataPeriod strategyPeriod;
    bool isInTester;
    int openSlotsCount;
    int closeSlotsCount;

    // Methods
    string GetSlotChart(int slotNumber);

public:
    // Constructors
    Strategy(int openSlots, int closeSlots);

    ~Strategy(void);

    // Properties
    string  StrategyName;
    string  Description;
    double  AddingLots;
    double  ReducingLots;
    double  EntryLots;
    double  MaxOpenLots;
    bool    UseAccountPercentEntry;
    bool    UsePermanentSL;
    int     PermanentSL;
    bool    UsePermanentTP;
    int     PermanentTP;
    bool    UseBreakEven;
    int     BreakEven;
    bool    UseMartingale;
    double  MartingaleMultiplier;
    int     FirstBar;
    int     MinBarsRequired;
    int     RecommendedBars;

    PermanentProtectionType PermanentTPType;
    PermanentProtectionType PermanentSLType;
    OppositeDirSignalAction OppSignalAction;
    SameDirSignalAction     SameSignalAction;

    IndicatorSlot *Slot[];

    // Methods
    void        SetSymbol(string symbol)    { strategySymbol = symbol; }
    void        SetPeriod(int period)       { strategyPeriod = EnumTimeFramesToPeriod(period); }
    void        SetIsTester(bool isTester)  { isInTester = isTester; }
    string      GetSymbol(void)             { return (strategySymbol); }
    DataPeriod  GetPeriod(void)             { return (strategyPeriod); }
    bool        IsTester(void)              { return (isInTester); }
    int         OpenSlots(void)             { return (openSlotsCount); };
    int         CloseSlots(void)            { return (closeSlotsCount); };
    int         Slots(void)                 { return (openSlotsCount + closeSlotsCount + 2); }
    int         CloseSlotNumber(void)       { return (openSlotsCount + 1); }
    SlotTypes   GetSlotType(int slotNumber);
    void        GetRequiredCharts(string &charts[]);
    bool        IsUsingLogicalGroups(void);
    bool        IsLogicalGroupSpecial(int slotNumber);
    string      GetDefaultGroup(int slotNumber);
    bool        IsLongerTimeFrame(int slotNumber);
    void        CalculateStrategy(DataSet *&dataSet[]);
    string      DynamicInfoText(void);
    void        DynamicInfoInitArrays(string &params[], string &values[]);
    void        DynamicInfoSetValues(string &values[]);
    string      ToString(void);
};

Strategy::Strategy(int openSlots, int closeSlots)
{
    openSlotsCount = openSlots;
    closeSlotsCount = closeSlots;

    ArrayResize(Slot, Slots());

    for (int i = 0; i < Slots(); i++)
    {
        Slot[i] = new IndicatorSlot();
        Slot[i].SlotNumber = i;
        Slot[i].SlotType = GetSlotType(i);
    }
}

Strategy::~Strategy(void)
{
    for (int slot = 0; slot < ArraySize(Slot); slot++)
        delete Slot[slot];
}

SlotTypes Strategy::GetSlotType(int slotNumber)
{
    if (slotNumber == 0)
        return (SlotTypes_Open);
    else if (slotNumber < CloseSlotNumber())
        return (SlotTypes_OpenFilter);
    else if (slotNumber == CloseSlotNumber())
        return (SlotTypes_Close);
    else
        return (SlotTypes_CloseFilter);
}

bool Strategy::IsLongerTimeFrame(int slotNumber)
{
    return !(Slot[slotNumber].IndicatorSymbol == "" &&
             Slot[slotNumber].IndicatorPeriod == DataPeriod_M1);
}

string Strategy::GetSlotChart(int slotNumber)
{
    string symbol = Slot[slotNumber].GetIndicatorSymbol(GetSymbol());
    DataPeriod period = Slot[slotNumber].GetIndicatorPeriod(GetPeriod());

    return (symbol + "," + DataPeriodToString(period));
}

void Strategy::GetRequiredCharts(string &charts[])
{
    ArrayResize(charts, 1);
    charts[0] = GetSymbol() + "," + DataPeriodToString(GetPeriod());

    for (int i = 0; i < Slots(); i++)
    {
        if (!Slot[i].IndicatorPointer.IsAllowLTF)
            continue;
        if (!IsLongerTimeFrame(i))
            continue;
        string chart = GetSlotChart(i);
        if (!ArrayContainsString(charts, chart))
            ArrayAppendString(charts, chart);
    }
}

void Strategy::CalculateStrategy(DataSet *&dataSet[])
{
    for (int i = 0; i < Slots(); i++)
    {
        string chart = GetSlotChart(i);
        for (int j = 0; j < ArraySize(dataSet); j++)
        {
            if (dataSet[j].Chart != chart)
                continue;
            
            Slot[i].IndicatorPointer.Calculate(dataSet[j]);
            
            if (IsLongerTimeFrame(i))
            {
                int ltfShift;
                bool isBasePriceOpen = false;
                bool isCloseFilterShift = false;
                
                for (int p = 1; p < 5; p++)
                {
                    if (Slot[i].IndicatorPointer.ListParam[p].Caption == "Base price" &&
                        Slot[i].IndicatorPointer.ListParam[p].Text == "Open" )
                    {
                        isBasePriceOpen = true;
                        break;
                    }
                }
                
                if (isBasePriceOpen)
                {
                    ltfShift = 0;
                }
                else
                {
                    ltfShift = Slot[i].IndicatorPeriod != DataPeriod_M1 &&
                              !Slot[i].GetUsePreviousBarValue() ? 1 : 0;
                    isCloseFilterShift = Slot[i].SlotType == SlotTypes_CloseFilter;
                }
                
                Slot[i].IndicatorPointer.NormalizeComponents(dataSet[0], ltfShift, isCloseFilterShift);
            }

            if (Slot[i].SignalShift > 0)
            {
                Slot[i].IndicatorPointer.ShiftSignal(Slot[i].SignalShift);
            }

            if (Slot[i].SignalRepeat > 0)
            {
                Slot[i].IndicatorPointer.RepeatSignal(Slot[i].SignalRepeat);
            }
        }
    }
}

bool Strategy::IsUsingLogicalGroups()
{
    bool isUsingGroups = false;
    for (int slot = 0; slot < ArraySize(Slot); slot++)
    {
        SlotTypes slotType = Slot[slot].SlotType;
        if (slotType == SlotTypes_OpenFilter)
        {
            string defaultGroup = GetDefaultGroup(slot);
            string logicalGroup = Slot[slot].LogicalGroup;
            if (defaultGroup != logicalGroup && logicalGroup != "All")
            {
                isUsingGroups = true;
                break;
            }
        }
        else if (slotType == SlotTypes_CloseFilter)
        {
            string defaultGroup = GetDefaultGroup(slot);
            string logicalGroup = Slot[slot].LogicalGroup;
            if (defaultGroup != logicalGroup)
            {
                isUsingGroups = true;
                break;
            }
        }
    }
    return (isUsingGroups);
}

bool Strategy::IsLogicalGroupSpecial(int slotNumber)
{
    SlotTypes slotType = Slot[slotNumber].SlotType;
    string group = Slot[slotNumber].LogicalGroup;
    if (slotType == SlotTypes_Open || slotType == SlotTypes_Close)
        return (false);
    if (slotType == SlotTypes_OpenFilter && group != GetDefaultGroup(slotNumber) && group != "[All]")
        return (true);
    if (slotType == SlotTypes_CloseFilter && group != GetDefaultGroup(slotNumber))
        return (true);
    if (slotType == SlotTypes_CloseFilter)
    {
        int count = 0;
        for (int i = OpenSlots() + 2; i < Slots(); i++)
            if (Slot[i].LogicalGroup == group)
                count++;
        if (count > 1)
            return (true);
    }
    return (false);
}

string Strategy::GetDefaultGroup(int slotNumber)
{
    string group = "";
    SlotTypes slotType = GetSlotType(slotNumber);
    if (slotType == SlotTypes_OpenFilter)
    {
        bool isDefault = Slot[slotNumber].IndicatorPointer.IsDeafultGroupAll ||
                         Slot[slotNumber].IndicatorPointer.IsDefaultGroupAll;
        group = isDefault ? "All" : "A";
    }
    else if (slotType == SlotTypes_CloseFilter)
    {
        int index = slotNumber - CloseSlotNumber() - 1;
        group = IntegerToString('a' + index);
    }
    return (group);
}

void Strategy::DynamicInfoInitArrays(string &params[], string &values[])
{
    ArrayResize(params, 200);
    ArrayResize(values, 200);
    for (int i = 0; i < 200; i++)
    {
        params[i] = "";
        values[i] = "";
    }

    int index = -2;
    for (int slot = 0; slot < Slots(); slot++)
    {
        index++;
        index++;
        params[index] = Slot[slot].IndicatorName;
        for (int i = 0; i < Slot[slot].IndicatorPointer.Components(); i++)
        {
            IndComponentType type = Slot[slot].IndicatorPointer.Component[i].DataType;
            if (type == IndComponentType_NotDefined)
                continue;
            if (Slot[slot].IndicatorPointer.Component[i].ShowInDynInfo)
            {
                index++;
                params[index] = Slot[slot].IndicatorPointer.Component[i].CompName;
            }
        }
    }
    ArrayResize(params, index + 1);
    ArrayResize(values, index + 1);
}

void Strategy::DynamicInfoSetValues(string &values[])
{
    int index = -1;
    for (int slot = 0; slot < Slots(); slot++)
    {
        index++;
        index++;
        for (int i = 0; i < Slot[slot].IndicatorPointer.Components(); i++)
        {
            IndicatorComp *component = Slot[slot].IndicatorPointer.Component[i];
            IndComponentType type = component.DataType;
            if (type == IndComponentType_NotDefined)
            {
                component = NULL;
                continue;
            }
            int bars = ArraySize(component.Value);
            if (bars < 3)
            {
                component = NULL;
                continue;
            }

            string name   = component.CompName;
            double value0 = component.Value[bars - 1];
            double value1 = component.Value[bars - 2];
            double dl0    = MathAbs(value0);
            double dl1    = MathAbs(value0);
            string sFr0   = dl0 < 10 ? "%10.5f" : dl0 < 100 ? "%10.5f" : dl0 < 1000 ? "%10.3f" :
                            dl0 < 10000 ? "%10.3f" : dl0 < 100000 ? "%10.2f" : "%10.1f";
            string sFr1   = dl1 < 10 ? "%10.5f" : dl1 < 100 ? "%10.5f" : dl1 < 1000 ? "%10.3f" :
                            dl1 < 10000 ? "%10.3f" : dl1 < 100000 ? "%10.2f" : "%10.1f";
            string format = sFr1 + "    " + sFr0;
            if (component.ShowInDynInfo)
            {
                if (type == IndComponentType_AllowOpenLong  ||
                    type == IndComponentType_AllowOpenShort ||
                    type == IndComponentType_ForceClose     ||
                    type == IndComponentType_ForceCloseLong ||
                    type == IndComponentType_ForceCloseShort)
                    values[index] = StringFormat("%13s    %13s", (value1 < 1 ? "No" : "Yes"), (value0 < 1 ? "No" : "Yes"));
                else
                    values[index] = StringFormat(format, value1, value0);
                index++;
            }
            component = NULL;
        }
    }
}

string Strategy::DynamicInfoText()
{
    string info;
    for (int slot = 0; slot < Slots(); slot++)
    {
        info += "\n\n" + Slot[slot].IndicatorName;
        for (int i = 0; i < Slot[slot].IndicatorPointer.Components(); i++)
        {
            IndicatorComp *component = Slot[slot].IndicatorPointer.Component[i];
            IndComponentType type = component.DataType;
            if (type == IndComponentType_NotDefined) continue;
            int bars = ArraySize(component.Value);
            if (bars < 4) continue;

            string name   = component.CompName;
            double value0 = component.Value[bars - 1];
            double value1 = component.Value[bars - 2];
            double value2 = component.Value[bars - 3];
            double dl     = MathAbs(value0);
            string sFr    = dl < 10 ? "%10.6f" : dl < 100 ? "%10.5f" : dl < 1000 ? "%10.4" :
                            dl < 10000 ? "%10.3f" : dl < 100000 ? "%10.2f" : "%10.1f";
            string format = "\n%-40s " + sFr + "    " + sFr + "    " + sFr;
            if (component.ShowInDynInfo)
            {
                if (type == IndComponentType_AllowOpenLong  ||
                    type == IndComponentType_AllowOpenShort ||
                    type == IndComponentType_ForceClose     ||
                    type == IndComponentType_ForceCloseLong ||
                    type == IndComponentType_ForceCloseShort)
                {
                    info += StringFormat("\n%-42s %-10s    %-10s    %-10s", name,
                                         (value2 < 1 ? "No" : "Yes"),
                                         (value1 < 1 ? "No" : "Yes"),
                                         (value0 < 1 ? "No" : "Yes"));
                }
                else
                {
                    info += StringFormat(format, name, value2, value1, value0);
                }
            }
            component = NULL;
        }
    }
    return (info);
}

string Strategy::ToString()
{
    string stopLoss   = UsePermanentSL ? IntegerToString(PermanentSL)            : "None";
    string takeProfit = UsePermanentTP ? IntegerToString(PermanentTP)            : "None";
    string breakEven  = UseBreakEven   ? IntegerToString(BreakEven)              : "None";
    string martingale = UseMartingale  ? DoubleToString(MartingaleMultiplier, 2) : "None";

    string text = "Name: "            + StrategyName                                     + "\n" +
                  "Symbol: "          + GetSymbol()                                      + "\n" +
                  "Period: "          + DataPeriodToString(GetPeriod())                  + "\n\n" +
                  "Trade unit: "      + (UseAccountPercentEntry ? "Percent" : "Lot")     + "\n" +
                  "Entry amount: "    + DoubleToString(EntryLots, 2)                     + "\n" +
                  "Max open lots: "   + DoubleToString(MaxOpenLots, 2)                   + "\n\n" +
                  "Same signal: "     + SameDirSignalActionToString(SameSignalAction)    + "\n" +
                  "Adding amount: "   + DoubleToString(AddingLots, 2)                    + "\n" +
                  "Opposite signal: " + OppositeDirSignalActionToString(OppSignalAction) + "\n" +
                  "Reducing amount: " + DoubleToString(ReducingLots, 2)                  + "\n\n" +
                  "Stop Loss: "       + stopLoss                                         + "\n" +
                  "Take Profit: "     + takeProfit                                       + "\n" +
                  "Break Even: "      + breakEven                                        + "\n\n" +
                  "Martingale: "      + martingale                                       + "\n\n" +
                  "Description: "     + Description                                      + "\n\n";

    for (int slot = 0; slot < ArraySize(Slot); slot++)
    {
        text += SlotTypeToString(Slot[slot].SlotType)                + "\n" +
                Slot[slot].IndicatorName                             + "\n" +
                Slot[slot].IndicatorPointer.IndicatorParamToString() + "\n";

        if (Slot[slot].SlotType == SlotTypes_OpenFilter || Slot[slot].SlotType == SlotTypes_CloseFilter)
            text += Slot[slot].LogicalGroupToString();
        if (Slot[slot].IndicatorPointer.IsAllowLTF)
            text += Slot[slot].AdvancedParamsToString() + "\n";
    }
    return (text);
}
