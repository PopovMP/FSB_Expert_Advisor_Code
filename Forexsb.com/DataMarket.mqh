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

#include <Forexsb.com\Enumerations.mqh>

//## Import Start

class DataMarket
{
public:
    string     Symbol;
    DataPeriod Period;

    bool IsNewBid;

    double OldBid;
    double OldAsk;
    double OldClose;
    double Bid;
    double Ask;
    double Close;
    long   Volume;

    datetime TickLocalTime;
    datetime TickServerTime;
    datetime BarTime;

    double AccountBalance;
    double AccountEquity;
    double AccountFreeMargin;

    double       PositionLots;
    double       PositionOpenPrice;
    datetime     PositionOpenTime;
    double       PositionStopLoss;
    double       PositionTakeProfit;
    double       PositionProfit;
    PosDirection PositionDirection;

    int  ConsecutiveLosses;
    int  WrongStopLoss;
    int  WrongTakeProf;
    int  WrongStopsRetry;
    bool IsFailedCloseOrder;
    int  CloseOrderTickCounter;
    bool IsSentCloseOrder;

    int    LotSize;
    double Spread;
    double Point;
    int    StopLevel;
    double TickValue;
    double MinLot;
    double MaxLot;
    double LotStep;
    double MarginRequired;
};
