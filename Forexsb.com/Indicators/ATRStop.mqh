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

#include <Forexsb.com/Indicator.mqh>
#include <Forexsb.com/Enumerations.mqh>

class ATRStop : public Indicator
{
public:
    ATRStop(SlotTypes slotType)
    {
        SlotType = slotType;
        
        IndicatorName     = "ATR Stop";

        WarningMessage    = "";
        IsAllowLTF        = true;
        ExecTime          = ExecutionTime_DuringTheBar;
        IsSeparateChart   = false;
        IsDiscreteValues  = false;
        IsDefaultGroupAll = false;
    }

    virtual void Calculate(DataSet &dataSet);
};

void ATRStop::Calculate(DataSet &dataSet)
{
    Data = GetPointer(dataSet);

    // Reading the parameters
    MAMethod maMethod = (MAMethod) ListParam[1].Index;
    int period = (int) NumParam[0].Value;
    int multipl = (int) NumParam[1].Value;
    int prev = CheckParam[0].Checked ? 1 : 0;

    // Calculation
    int firstBar = period + 2;

    double atr1[]; ArrayResize(atr1, Data.Bars); ArrayInitialize(atr1,0);

    for (int bar = 1; bar < Data.Bars; bar++)
        atr1[bar] = MathMax(Data.High[bar], Data.Close[bar - 1]) - MathMin(Data.Low[bar], Data.Close[bar - 1]);

    double atr[]; MovingAverage(period, 0, maMethod, atr1, atr);

    double atrStop[]; ArrayResize(atrStop, Data.Bars); ArrayInitialize(atrStop,0);
    double pip = (Data.Digits == 5 || Data.Digits == 3) ? 10*Data.Point : Data.Point;
    double minStop = 5*pip;

    for (int bar = firstBar; bar < Data.Bars - prev; bar++)
        atrStop[bar + prev] = MathMax(atr[bar]*multipl, minStop);

    // Saving the components

    ArrayResize(Component[0].Value, Data.Bars);
    Component[0].CompName = "ATR Stop margin";
    Component[0].DataType = IndComponentType_IndicatorValue;
    Component[0].FirstBar = firstBar;
    ArrayCopy(Component[0].Value, atrStop);

    ArrayResize(Component[1].Value, Data.Bars);
    ArrayInitialize(Component[1].Value,0);
    Component[1].CompName = "ATR Stop prev pos";
    Component[1].DataType = IndComponentType_Other;
    Component[1].FirstBar = firstBar;
}
