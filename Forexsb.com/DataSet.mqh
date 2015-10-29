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
#property version   "3.00"
#property strict

#include <Forexsb.com/Enumerations.mqh>
#include <Forexsb.com/Helpers.mqh>

//## Import Start

class DataSet
{
public:
    // Constructor
     DataSet(string chart);

    // Properties
    string     Chart;
    string     Symbol;
    DataPeriod Period;

    int        LotSize;
    double     Spread;
    int        Digits;
    double     Point;
    double     Pip;
    bool       IsFiveDigits;
    int        StopLevel;
    double     TickValue;
    double     MinLot;
    double     MaxLot;
    double     LotStep;
    double     MarginRequired;

    int        Bars;

    datetime   ServerTime;
    double     Bid;
    double     Ask;

    datetime   Time[];
    double     Open[];
    double     High[];
    double     Low[];
    double     Close[];
    long       Volume[];

    // Methods
    void SetPrecision(void);
};

DataSet::DataSet(string chart)
{
    Chart = chart;
    string parts[];
    StringSplit(chart, ',', parts);
    Symbol = parts[0];
    Period = StringToDataPeriod(parts[1]);
}

void DataSet::SetPrecision(void)
{
    IsFiveDigits = (Digits == 3 || Digits == 5);
    Point = 1/MathPow(10, Digits);
    Pip = IsFiveDigits ? 10*Point : Point;
}
