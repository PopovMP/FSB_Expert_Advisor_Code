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

#include <Forexsb.com\Enumerations.mqh>

//## Import Start

class IndicatorComp
{
public:
    // Constructors
    IndicatorComp()
    {
        CompName           = "Not defined";
        DataType           = IndComponentType_NotDefined;
        FirstBar           = 0;
        UsePreviousBar     = 0;
        ShowInDynInfo      = true;
        PosPriceDependence = PositionPriceDependence_None;
    }

    // Properties
    string                  CompName;
    int                     FirstBar;
    int                     UsePreviousBar;
    IndComponentType        DataType;
    PositionPriceDependence PosPriceDependence;
    bool                    ShowInDynInfo;
    double                  Value[];

    // Methods
    double                  GetLastValue(int indexFromEnd);
};

double IndicatorComp::GetLastValue(int indexFromEnd = 0)
{
    int bars = ArraySize(Value);
    return (bars > indexFromEnd ? Value[bars - indexFromEnd - 1]: 0);
}
