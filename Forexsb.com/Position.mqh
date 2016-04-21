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
#property version   "1.00"
#property strict

#include <Forexsb.com\Enumerations.mqh>

//## Import Start

#define OP_FLAT          -1

class Position
{
public:
    // Constructors
    Position(void);

    // Properties
    int PosType;
    PosDirection Direction;
    double Lots;
    datetime OpenTime;
    double OpenPrice;
    double StopLossPrice;
    double TakeProfitPrice;
    double Profit;
    double Commission;
    string PosComment;

    // Methods
    string ToString();

    void SetPositionInfo(string &positionInfo[]);
};

void Position::Position(void)
{
}

string Position::ToString()
{
    if (PosType == OP_FLAT)
        return ("Position: Flat");

    string text =
            "Position: "  +
            "Time="       + TimeToString(OpenTime, TIME_SECONDS)     + ", " +
            "Type="       + (PosType == OP_BUY ? "Long" : "Short")   + ", " +
            "Lots="       + DoubleToString(Lots, 2)                  + ", " +
            "Price="      + DoubleToString(OpenPrice, _Digits)       + ", " +
            "StopLoss="   + DoubleToString(StopLossPrice, _Digits)   + ", " +
            "TakeProfit=" + DoubleToString(TakeProfitPrice, _Digits) + ", " +
            "Commission=" + DoubleToString(Commission, 2)            + ", " +
            "Profit="     + DoubleToString(Profit, 2);

    if (PosComment != "")
        text += ", \"" + PosComment + "\"";

    return (text);
}

void Position::SetPositionInfo(string &positionInfo[])
{
    if (PosType == OP_FLAT)
    {
        positionInfo[0] = "Position: Flat";
        positionInfo[1] = ".";
    }
    else
    {
        positionInfo[0] = StringFormat("Position: %s %.2f at %s, Profit %.2f",
                                  (PosType == OP_BUY) ? "Long" : "Short",
                                  Lots,
                                  DoubleToString(OpenPrice, _Digits),
                                  Profit);
        positionInfo[1] = StringFormat("Stop Loss: %s, Take Profit: %s",
                                  DoubleToString(StopLossPrice,   _Digits),
                                  DoubleToString(TakeProfitPrice, _Digits));
    }
}
