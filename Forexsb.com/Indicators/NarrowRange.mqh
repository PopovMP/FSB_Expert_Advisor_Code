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
#property version   "2.1"
#property strict

#include <Forexsb.com/Indicator.mqh>
#include <Forexsb.com/Enumerations.mqh>

class NarrowRange : public Indicator
{
public:
    NarrowRange(SlotTypes slotType)
    {
        SlotType = slotType;
        
        IndicatorName     = "Narrow Range";

        WarningMessage    = "";
        IsAllowLTF        = true;
        ExecTime          = ExecutionTime_DuringTheBar;
        IsSeparateChart   = true;
        IsDiscreteValues  = false;
        IsDefaultGroupAll = false;
    }

    virtual void Calculate(DataSet &dataSet);
};

void NarrowRange::Calculate(DataSet &dataSet)
{
    Data = GetPointer(dataSet);

    int previous = CheckParam[0].Checked ? 1 : 0;

    // Calculation
    int stepBack = (ListParam[0].Text == "There is a NR4 formation" ? 3 : 6);
    int firstBar = stepBack + previous;
    double adNr[];    ArrayResize(adNr, Data.Bars);    ArrayInitialize(adNr,0);
    double adRange[]; ArrayResize(adRange, Data.Bars); ArrayInitialize(adRange,0);

    for (int bar = 0; bar < Data.Bars; bar++)
    {
        adRange[bar] = Data.High[bar] - Data.Low[bar];
        adNr[bar] = 0;
    }

    // Calculation of the logic
    for (int bar = firstBar; bar < Data.Bars; bar++)
    {
        bool isNarrowRange = true;
        for (int i = 1; i <= stepBack; i++)
        {   if (adRange[bar - i - previous] <= adRange[bar - previous])
                isNarrowRange = false;
		}
        if (isNarrowRange)
			adNr[bar] = 1;
    }

    // Saving the components
    ArrayResize(Component[0].Value, Data.Bars);
    Component[0].CompName = "Bar Range";
    Component[0].DataType = IndComponentType_IndicatorValue;
    Component[0].FirstBar = firstBar;
    for (int i = 0; i < Data.Bars; i++)
        Component[0].Value[i] = MathRound(adRange[i]/Data.Point);

    ArrayResize(Component[1].Value, Data.Bars);
    Component[1].CompName = "Allow long entry";
    Component[1].DataType = IndComponentType_AllowOpenLong;
    Component[1].FirstBar = firstBar;
    ArrayCopy(Component[1].Value, adNr);

    ArrayResize(Component[2].Value, Data.Bars);
    Component[2].CompName = "Allow short entry";
    Component[2].DataType = IndComponentType_AllowOpenShort;
    Component[2].FirstBar = firstBar;
    ArrayCopy(Component[2].Value, adNr);
}
