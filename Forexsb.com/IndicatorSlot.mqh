//+--------------------------------------------------------------------+
//| Copyright:  (C) 2014 Forex Software Ltd.                           |
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

#property copyright "Copyright (C) 2014 Forex Software Ltd."
#property link      "http://forexsb.com"
#property version   "2.00"
#property strict

#include <Forexsb.com/Enumerations.mqh>
#include <Forexsb.com/IndicatorParam.mqh>
#include <Forexsb.com/IndicatorComp.mqh>
#include <Forexsb.com/Indicator.mqh>
#include <Forexsb.com/Helpers.mqh>

//## Import Start

class IndicatorSlot
{
public:
    // Constructors
    IndicatorSlot();
    ~IndicatorSlot();

    // Properties
    int        SlotNumber;
    SlotTypes  SlotType;
    string     IndicatorName;
    string     LogicalGroup;
    int        SignalShift;
    int        SignalRepeat;
    string     IndicatorSymbol;
    DataPeriod IndicatorPeriod;

    Indicator *IndicatorPointer;

    // Methods
    bool GetUsePreviousBarValue(void);
    string LogicalGroupToString(void);
    string AdvancedParamsToString(void);
    string GetIndicatorSymbol(string baseSymbol);
    DataPeriod GetIndicatorPeriod(DataPeriod basePeriod);
};

IndicatorSlot::IndicatorSlot(void)
{
}

IndicatorSlot::~IndicatorSlot(void)
{
    if (CheckPointer(IndicatorPointer) == POINTER_DYNAMIC)
        delete IndicatorPointer;
}

bool IndicatorSlot::GetUsePreviousBarValue(void)
{
    for (int i = 0; i < ArraySize(IndicatorPointer.CheckParam); i++)
        if (IndicatorPointer.CheckParam[i].Caption == "Use previous bar value")
            return (IndicatorPointer.CheckParam[i].Checked);
    return (false);
}

string IndicatorSlot::LogicalGroupToString(void)
{
    return ("Logical group: " + LogicalGroup);
}

string IndicatorSlot::AdvancedParamsToString(void)
{
    string text = "Signal shift: " + IntegerToString(SignalShift) + "\n";
    if (SlotType == SlotTypes_OpenFilter ||
        SlotType == SlotTypes_CloseFilter)
        text += "Signal repeat: " + IntegerToString(SignalRepeat) + "\n";

    string symbol = (IndicatorSymbol == "")
                    ? "Default"
                    : IndicatorSymbol;
    string period = (IndicatorPeriod == DataPeriod_M1)
                    ? "Default"
                    : DataPeriodToString(IndicatorPeriod);
    text += "Symbol: " + symbol + "\n";
    text += "Period: " + period + "\n";

    return (text);
}

string IndicatorSlot::GetIndicatorSymbol(string baseSymbol)
{
    return (IndicatorSymbol == "" ? baseSymbol : IndicatorSymbol);
}

DataPeriod IndicatorSlot::GetIndicatorPeriod(DataPeriod basePeriod)
{
    return (IndicatorPeriod < basePeriod ? basePeriod : IndicatorPeriod);
}
