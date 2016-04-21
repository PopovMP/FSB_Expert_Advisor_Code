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
#property version   "4.00"
#property strict

#include <Forexsb.com\StrategyManager.mqh>
#include <Forexsb.com\DataMarket.mqh>
#include <Forexsb.com\DataSet.mqh>
#include <Forexsb.com\Strategy.mqh>
#include <Forexsb.com\Helpers.mqh>
#include <Forexsb.com\HelperMq4.mqh>
#include <Forexsb.com\Enumerations.mqh>
#include <Forexsb.com\IndicatorSlot.mqh>
#include <Forexsb.com\Position.mqh>
#include <Forexsb.com\Logger.mqh>
#include <Forexsb.com\StrategyTrader.mqh>

//## Import Start

#define TRADE_RETRY_COUNT 4
#define TRADE_RETRY_WAIT  100

class ActionTrade
{
private:
    double epsilon;

    // Fields
    Strategy       *strategy;
    DataSet        *dataSet[];
    DataMarket     *dataMarket;
    Position       *position;
    Logger         *logger;
    StrategyTrader *strategyTrader;

   // Properties
    int      lastError;
    double   pipsValue;
    int      pipsPoint;
    int      stopLevel;
    datetime barTime;
    datetime barHighTime;
    datetime barLowTime;
    double   barHighPrice;
    double   barLowPrice;
    int      trailingStop;
    TrailingStopMode trailingMode;
    int      breakEven;
    int      consecutiveLosses;

    string dynamicInfoParams[];
    string dynamicInfoValues[];

    // Methods
    bool CheckEnvironment(int minDataBars);
    bool CheckChartBarsCount(int minDataBars);
    int FindBarsCountNeeded(int minDataBars);
    int SetAggregatePosition(Position *pos);
    void UpdateDataSet(DataSet *data, int maxBars);
    bool IsTradeContextFree(void);
    void ActivateProtectionMinAccount(void);
    void CloseExpert(void);

    // Trading methods
    double GetTakeProfitPrice(int type, int takeProfit);
    double GetStopLossPrice(int type, int stopLoss);
    double CorrectTakeProfitPrice(int type, double takeProfitPrice);
    double CorrectStopLossPrice(int type, double stopLossPrice);
    double NormalizeEntryPrice(double price);
    void SetMaxStopLoss(void);
    void SetBreakEvenStop(void);
    void SetTrailingStop(bool isNewBar);
    void SetTrailingStopBarMode(void);
    void SetTrailingStopTickMode(void);
    void DetectPositionClosing(void);

    // Specific MQ4 trading methods
    bool OpenNewPosition(int type, double lots, int stopLoss, int takeProfit);
    bool AddToCurrentPosition(int type, double lots, int stopLoss, int takeProfit);
    bool ReduceCurrentPosition(double lots, int stopLoss, int takeProfit);
    bool ReverseCurrentPosition(int type, double lots, int stopLoss, int takeProfit);
    bool CloseOrder(int orderTicket, double lots);
    bool SelectOrder(int orderTicket);
    bool SendOrder(int type, double lots, int stopLoss, int takeProfit);
    bool ModifyOrder(int orderTicket, double stopLossPrice, double takeProfitPrice);

public:
    // Constructors
     ActionTrade(void);
    ~ActionTrade(void);

    // Properties
    double EntryAmount;
    double MaximumAmount;
    double AddingAmount;
    double ReducingAmount;
    string OrderComment;
    int MinDataBars;
    int ProtectionMinAccount;
    int ProtectionMaxStopLoss;
    int ExpertMagic;
    bool SeparateSLTP;
    bool WriteLogFile;
    bool FIFOorder;
    int TrailingStopMovingStep;
    int MaxLogLinesInFile;
    int BarCloseAdvance;

    // Methods
    int  OnInit(void);
    void OnTick(void);
    void OnDeinit(const int reason);
    void UpdateDataMarket(DataMarket *market);
    double NormalizeEntrySize(double size);
    bool ManageOrderSend(int type, double lots, int stopLoss, int takeProfit,
                         TrailingStopMode trlMode, int trlStop, int brkEven);
    bool ModifyPosition(double stopLossPrice, double takeProfitPrice);
    bool CloseCurrentPosition(void);
};

void ActionTrade::ActionTrade(void)
{
    epsilon  = 0.000001;
    position = new Position();
    logger   = new Logger();
    strategyTrader = new StrategyTrader(GetPointer(this));
}

void ActionTrade::~ActionTrade(void)
{
    if (CheckPointer(position) == POINTER_DYNAMIC)
        delete position;
    if (CheckPointer(logger) == POINTER_DYNAMIC)
        delete logger;
    if (CheckPointer(strategyTrader) == POINTER_DYNAMIC)
        delete strategyTrader;
}

int ActionTrade::OnInit()
{
    dataMarket     = new DataMarket();
    barHighTime    = 0;
    barLowTime     = 0;
    barHighPrice = 0;
    barLowPrice  = 1000000;

    string message = StringFormat("%s loaded.", MQLInfoString(MQL_PROGRAM_NAME));
    Comment(message);
    Print(message);

    if (WriteLogFile)
    {
        logger.CreateLogFile(logger.GetLogFileName(_Symbol, _Period, ExpertMagic));
        logger.WriteLogLine(message);
        logger.WriteLogLine("Entry Amount: "    + DoubleToString(EntryAmount, 2)   + ", " +
                            "Maximum Amount: "  + DoubleToString(MaximumAmount, 2) + ", " +
                            "Adding Amount: "   + DoubleToString(AddingAmount, 2)  + ", " +
                            "Reducing Amount: " + DoubleToString(ReducingAmount, 2));
        logger.WriteLogLine("Protection Min Account: "  + IntegerToString(ProtectionMinAccount) + ", " +
                            "Protection Max StopLoss: " + IntegerToString(ProtectionMaxStopLoss));
        logger.WriteLogLine("Expert Magic: "      + IntegerToString(ExpertMagic) + ", " +
                            "Bar Close Advance: " + IntegerToString(BarCloseAdvance));
        logger.FlushLogFile();
    }

    if (_Digits == 2 || _Digits == 3)
        pipsValue = 0.01;
    else if (_Digits == 4 || _Digits == 5)
        pipsValue = 0.0001;
    else
        pipsValue = _Digits;

    if (_Digits == 3 || _Digits == 5)
        pipsPoint = 10;
    else
        pipsPoint = 1;

    stopLevel = (int) MarketInfo(_Symbol, MODE_STOPLEVEL) + pipsPoint;
    if (stopLevel < 3 * pipsPoint)
        stopLevel = 3 * pipsPoint;

    if (ProtectionMaxStopLoss > 0 && ProtectionMaxStopLoss < stopLevel)
        ProtectionMaxStopLoss = stopLevel;

    if (TrailingStopMovingStep < pipsPoint)
        TrailingStopMovingStep = pipsPoint;

    StrategyManager *strategyManager = new StrategyManager();

    // Strategy initialization
    strategy = strategyManager.GetStrategy();
    strategy.SetSymbol(_Symbol);
    strategy.SetPeriod((DataPeriod) _Period);
    strategy.SetIsTester(MQLInfoInteger(MQL_TESTER));
    strategy.EntryLots    = EntryAmount;
    strategy.MaxOpenLots  = MaximumAmount;
    strategy.AddingLots   = AddingAmount;
    strategy.ReducingLots = ReducingAmount;

    delete strategyManager;

    // Checks the requirements.
    bool isEnvironmentGood = CheckEnvironment(strategy.MinBarsRequired);
    if (!isEnvironmentGood)
    {   // There is a non fulfilled condition, therefore we must exit.
        Sleep(20 * 1000);
        ExpertRemove();
        return (INIT_FAILED);
    }

    // Market initialization
    string charts[];
    strategy.GetRequiredCharts(charts);

    string chartsNote = "Loading data: ";
    for (int i = 0; i < ArraySize(charts); i++)
        chartsNote += charts[i] + ", ";
    chartsNote += "Minumum bars: " + IntegerToString(strategy.MinBarsRequired) + "...";
    Comment(chartsNote);
    Print(chartsNote);

    // Initial data loading
    ArrayResize(dataSet, ArraySize(charts));
    for (int i = 0; i < ArraySize(charts); i++)
        dataSet[i] = new DataSet(charts[i]);

    SetAggregatePosition(position);

    // Checks the necessary bars.
    MinDataBars = FindBarsCountNeeded(MinDataBars);

    // Initial strategy calculation
    for (int i = 0; i < ArraySize(dataSet); i++)
        UpdateDataSet(dataSet[i], MinDataBars);
    strategy.CalculateStrategy(dataSet);

    // Initialize StrategyTrader
    strategyTrader.OnInit(strategy, dataMarket);
    strategyTrader.InitTrade();

    // Initialize the chart's info label.
    strategy.DynamicInfoInitArrays(dynamicInfoParams, dynamicInfoValues);
    int paramsX   = 0;
    int valuesX   = 140;
    int locationY = 40;
    color foreColor = GetChartForeColor(0);
    int count = ArraySize(dynamicInfoParams);
    for (int i = 0; i < count; i++)
    {
        string namep = "Lbl_prm_" + IntegerToString(i);
        string namev = "Lbl_val_" + IntegerToString(i);
        string param = dynamicInfoParams[i] == "" ? "." : dynamicInfoParams[i];
        LabelCreate(0, namep, 0, paramsX, locationY, CORNER_LEFT_UPPER, param, "Ariel", 8, foreColor);
        LabelCreate(0, namev, 0, valuesX, locationY, CORNER_LEFT_UPPER, ".",   "Ariel", 8, foreColor);
        locationY += 12;
    }

    LabelCreate(0, "Lbl_pos_0", 0, 350,  0, CORNER_LEFT_UPPER, ".", "Ariel", 10, foreColor);
    LabelCreate(0, "Lbl_pos_1", 0, 350, 15, CORNER_LEFT_UPPER, ".", "Ariel", 10, foreColor);
    LabelCreate(0, "Lbl_pos_2", 0, 350, 29, CORNER_LEFT_UPPER, ".", "Ariel", 10, foreColor);

    Comment("");

    return (INIT_SUCCEEDED);
}

void ActionTrade::OnTick()
{
    RefreshRates();

    for (int i = 0; i < ArraySize(dataSet); i++)
        UpdateDataSet(dataSet[i], MinDataBars);
    UpdateDataMarket(dataMarket);

    bool isNewBar = (barTime < dataMarket.BarTime && dataMarket.Volume < 5);
    barTime   = dataMarket.BarTime;
    lastError = 0;

    // Checks if minimum account was reached.
    if (ProtectionMinAccount > 0 && AccountEquity() < ProtectionMinAccount)
        ActivateProtectionMinAccount();

    // Checks and sets Max SL protection.
    if (ProtectionMaxStopLoss > 0)
        SetMaxStopLoss();

    // Checks if position was closed.
    DetectPositionClosing();

    if (breakEven > 0)
        SetBreakEvenStop();

    if (trailingStop > 0)
        SetTrailingStop(isNewBar);

    SetAggregatePosition(position);

    if (isNewBar && WriteLogFile)
        logger.WriteNewLogLine(position.ToString());

    if (dataSet[0].Bars >= strategy.MinBarsRequired)
    {
        strategy.CalculateStrategy(dataSet);
        TickType tickType = strategyTrader.GetTickType(isNewBar, BarCloseAdvance);
        strategyTrader.CalculateTrade(tickType);
    }

    // Sends OrderModify on SL/TP errors
    if (strategyTrader.IsWrongStopsExecution())
        strategyTrader.ResendWrongStops();

    string accountInfo = StringFormat("%s Balance: %.2f, Equity: %.2f",
                                      TimeToString(dataMarket.TickServerTime, TIME_SECONDS),
                                      AccountInfoDouble(ACCOUNT_BALANCE),
                                      AccountInfoDouble(ACCOUNT_EQUITY));
    LabelTextChange(0, "Lbl_pos_0", accountInfo);
    string positionInfo[2];
    position.SetPositionInfo(positionInfo);
    for (int i = 0; i < 2; i++)
        LabelTextChange(0, "Lbl_pos_" + IntegerToString(i + 1), positionInfo[i]);

    strategy.DynamicInfoSetValues(dynamicInfoValues);
    int count = ArraySize(dynamicInfoValues);
    for (int i = 0; i < count; i++)
    {
        string namev = "Lbl_val_" + IntegerToString(i);
        string val = dynamicInfoValues[i] == "" ? "." : dynamicInfoValues[i];
        LabelTextChange(0, namev, val);
    }

    if (WriteLogFile)
    {
        if (logger.IsLogLinesLimitReached(MaxLogLinesInFile))
        {
            logger.CloseLogFile();
            logger.CreateLogFile(logger.GetLogFileName(_Symbol, _Period, ExpertMagic));
        }
        logger.FlushLogFile();
    }
}

void ActionTrade::OnDeinit(const int reason)
{
    strategyTrader.OnDeinit();

    if (WriteLogFile)
        logger.CloseLogFile();

    if (CheckPointer(strategy) == POINTER_DYNAMIC)
        delete strategy;

    for (int i = 0; i < ArraySize(dataSet); i++)
        if (CheckPointer(dataSet[i]) == POINTER_DYNAMIC)
            delete dataSet[i];
    ArrayFree(dataSet);

    if (CheckPointer(dataMarket) == POINTER_DYNAMIC)
        delete dataMarket;

    int count = ArraySize(dynamicInfoParams);
    for (int i = 0; i < count; i++)
    {
        LabelDelete(0, "Lbl_val_" + IntegerToString(i));
        LabelDelete(0, "Lbl_prm_" + IntegerToString(i));
    }

    for (int i = 0; i < 3; i++)
        LabelDelete(0, "Lbl_pos_" + IntegerToString(i));
}

bool ActionTrade::CheckEnvironment(int minDataBars)
{
    if (!CheckChartBarsCount(minDataBars))
        return (false);

    if (MQLInfoInteger(MQL_TESTER))
    {
        SetAggregatePosition(position);
        return (true);
    }

    if (AccountNumber() == 0)
    {
        Comment("\n You are not logged in. Please login first.");
        for (int attempt = 0; attempt < 200; attempt++)
        {
            if (AccountNumber() == 0)
                Sleep(300);
            else
                break;
        }
        if (AccountNumber() == 0)
            return (false);
    }

    if (SetAggregatePosition(position) == -1)
        return (false);

    return (true);
}

int ActionTrade::FindBarsCountNeeded(int minDataBars)
{
    int barStep = 50;
    int minBars = MathMax(minDataBars, 50);
    int maxBars = MathMax(minBars, 3000);

    // Initial state
    int initialBars = MathMax(strategy.MinBarsRequired, minBars);
    initialBars = MathMax(strategy.FirstBar, initialBars);
    for (int i = 0; i < ArraySize(dataSet); i++)
        UpdateDataSet(dataSet[i], initialBars);
    UpdateDataMarket(dataMarket);
    double initialBid = dataMarket.Bid;
    strategy.CalculateStrategy(dataSet);
    string dynamicInfo = strategy.DynamicInfoText();
    int necessaryBars = initialBars;
    int roundedInitialBars = (int) (barStep * MathCeil(((double) initialBars) / barStep));
    int firstTestBars = roundedInitialBars >= initialBars + barStep / 2
                        ? roundedInitialBars
                        : roundedInitialBars + barStep;

    for (int bars = firstTestBars; bars <= maxBars; bars += barStep)
    {
        for (int i = 0; i < ArraySize(dataSet); i++)
            UpdateDataSet(dataSet[i], bars);
        UpdateDataMarket(dataMarket);
        strategy.CalculateStrategy(dataSet);
        string currentInfo = strategy.DynamicInfoText();

        if (dynamicInfo == currentInfo)
            break;

        dynamicInfo = currentInfo;
        necessaryBars = bars;

        if (MathAbs(initialBid - dataMarket.Bid) > epsilon)
        {  // Reset the test if new tick has arrived.
            for (int i = 0; i < ArraySize(dataSet); i++)
                UpdateDataSet(dataSet[i], initialBars);
            UpdateDataMarket(dataMarket);
            initialBid = dataMarket.Bid;
            strategy.CalculateStrategy(dataSet);
            dynamicInfo = strategy.DynamicInfoText();
            bars = firstTestBars - barStep;
        }
    }

    string barsMessage = "The expert uses " + IntegerToString(necessaryBars) + " bars.";
    if (WriteLogFile)
    {
        logger.WriteLogLine(barsMessage);
        string timeLastBar = TimeToString(dataMarket.TickServerTime, TIME_DATE | TIME_MINUTES);
        logger.WriteLogLine("Indicator values: " + dataSet[0].Chart + ", Time last bar: " + timeLastBar);
        logger.WriteLogLine(dynamicInfo);
    }
    Print(barsMessage);

    return (necessaryBars);
}

void ActionTrade::UpdateDataSet(DataSet *data, int maxBars)
{
    string symbol = data.Symbol;
    int    period = (int) data.Period;
    int    bars   = MathMin(Bars(symbol, period), maxBars);

    data.LotSize        = (int) MarketInfo(symbol, MODE_LOTSIZE);
    data.Digits         = (int) MarketInfo(symbol, MODE_DIGITS);
    data.StopLevel      = (int) MarketInfo(symbol, MODE_STOPLEVEL);
    data.Point          = MarketInfo(symbol, MODE_POINT);
    data.TickValue      = MarketInfo(symbol, MODE_TICKVALUE);
    data.MinLot         = MarketInfo(symbol, MODE_MINLOT);
    data.MaxLot         = MarketInfo(symbol, MODE_MAXLOT);
    data.LotStep        = MarketInfo(symbol, MODE_LOTSTEP);
    data.MarginRequired = MarketInfo(symbol, MODE_MARGINREQUIRED);
    data.Bars           = bars;
    data.ServerTime     = TimeCurrent();
    data.Bid            = MarketInfo(symbol, MODE_BID);
    data.Ask            = MarketInfo(symbol, MODE_ASK);
    data.Spread         = (data.Ask - data.Bid) / data.Point;

    if (data.MarginRequired < epsilon)
        data.MarginRequired = data.Bid * data.LotSize / 100;

    data.SetPrecision();

    MqlRates rates[];
    RefreshRates();
    ArraySetAsSeries(rates, false);
    int copied = CopyRates(symbol, period, 0, bars, rates);

    ArrayResize(data.Time,   bars);
    ArrayResize(data.Open,   bars);
    ArrayResize(data.High,   bars);
    ArrayResize(data.Low,    bars);
    ArrayResize(data.Close,  bars);
    ArrayResize(data.Volume, bars);

    for (int i = 0; i < bars; i++)
    {
        data.Time[i]   = rates[i].time;
        data.Open[i]   = rates[i].open;
        data.High[i]   = rates[i].high;
        data.Low[i]    = rates[i].low;
        data.Close[i]  = rates[i].close;
        data.Volume[i] = (int) rates[i].tick_volume;
    }
}

void ActionTrade::UpdateDataMarket(DataMarket *market)
{
    market.Symbol = _Symbol;
    market.Period = (DataPeriod) _Period;

    market.TickLocalTime  = TimeLocal();
    market.TickServerTime = TimeCurrent();
    market.BarTime        = Time[0];

    market.PositionLots       = position.Lots;
    market.PositionOpenPrice  = position.OpenPrice;
    market.PositionOpenTime   = position.OpenTime;
    market.PositionStopLoss   = position.StopLossPrice;
    market.PositionTakeProfit = position.TakeProfitPrice;
    market.PositionProfit     = position.Profit;
    market.PositionDirection  = position.Direction;

    market.AccountBalance    = AccountBalance();
    market.AccountEquity     = AccountEquity();
    market.AccountFreeMargin = AccountFreeMargin();
    market.ConsecutiveLosses = consecutiveLosses;

    market.OldAsk    = market.Ask;
    market.OldBid    = market.Bid;
    market.OldClose  = market.Close;
    market.Ask       = MarketInfo(_Symbol, MODE_ASK);
    market.Bid       = MarketInfo(_Symbol, MODE_BID);
    market.Close     = Close[0];
    market.Volume    = Volume[0];
    market.IsNewBid  = MathAbs(market.OldBid - market.Bid) > epsilon;

    market.LotSize        = (int) MarketInfo(_Symbol, MODE_LOTSIZE);
    market.StopLevel      = (int) MarketInfo(_Symbol, MODE_STOPLEVEL);
    market.Point          = MarketInfo(_Symbol, MODE_POINT);
    market.TickValue      = MarketInfo(_Symbol, MODE_TICKVALUE);
    market.MinLot         = MarketInfo(_Symbol, MODE_MINLOT);
    market.MaxLot         = MarketInfo(_Symbol, MODE_MAXLOT);
    market.LotStep        = MarketInfo(_Symbol, MODE_LOTSTEP);
    market.MarginRequired = MarketInfo(_Symbol, MODE_MARGINREQUIRED);
    market.Spread         = (market.Ask - market.Bid) / market.Point;

    if (market.MarginRequired < epsilon)
        market.MarginRequired = market.Bid * market.LotSize / 100;
}

bool ActionTrade::CheckChartBarsCount(int minDataBars)
{
    if (MQLInfoInteger(MQL_TESTER))
    {
        if (Bars(_Symbol, _Period) >= minDataBars)
            return (true);

        string message =
                "\n Cannot load enough bars! The expert needs minimum " +
                IntegerToString(minDataBars) + " bars." +
                "\n Please check the \"Use date\" option" +
                " and set the \"From:\" and \"To:\" dates properly.";
        Comment(message);
        Print(message);
        return (false);
    }

    int bars = 0;
    double rates[][6];

    for (int attempt = 0; attempt < 10; attempt++)
    {
        RefreshRates();
        bars = ArrayCopyRates(rates, _Symbol, _Period);
        if (bars < minDataBars && GetLastError() == 4066)
        {
            Comment("Loading...");
            Sleep(500);
        }
        else
            break;

        if (IsStopped())
            break;
    }

    bool isEnoughBars = (bars >= minDataBars);
    if (!isEnoughBars)
    {
        string message = "There isn\'t enough bars. The expert needs minimum " +
                         IntegerToString(minDataBars) + " bars. " +
                         "Currently " + IntegerToString(bars) + " bars are loaded." +
                         "\n Press and hold the Home key to force MetaTrader loading more bars.";
        Comment(message);
        Print(message);
    }

    return (isEnoughBars);
}

int ActionTrade::SetAggregatePosition(Position *pos)
{
    pos.PosType          = OP_FLAT;
    pos.Direction        = PosDirection_None;
    pos.OpenTime         = D'2050.01.01 00:00';
    pos.Lots             = 0;
    pos.OpenPrice        = 0;
    pos.StopLossPrice    = 0;
    pos.TakeProfitPrice  = 0;
    pos.Profit           = 0;
    pos.Commission       = 0;
    pos.PosComment       = "";

    int positions = 0;

    for (int i = 0; i < OrdersTotal(); i++)
    {
        if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            Print("Error with OrderSelect: ", GetErrorDescription(GetLastError()));
            Comment("Cannot check current position!");
            continue;
        }

        if (OrderMagicNumber() != ExpertMagic || OrderSymbol() != _Symbol)
            continue; // An order not sent by Forex Strategy Builder.

        if (OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLLIMIT ||
            OrderType() == OP_BUYSTOP  || OrderType() == OP_SELLSTOP)
            continue; // A pending order.

        if (pos.PosType >= 0 && pos.PosType != OrderType())
        {
            string message = "There are open positions in different directions!";
            Comment(message);
            Print(message);
            return (-1);
        }

        pos.PosType     = OrderType();
        pos.Direction   = position.PosType == OP_FLAT ? PosDirection_None :
                            position.PosType == OP_BUY ? PosDirection_Long : PosDirection_Short;
        pos.OpenTime    = (OrderOpenTime() < pos.OpenTime) ? OrderOpenTime() : pos.OpenTime;
        pos.OpenPrice   = (pos.Lots * pos.OpenPrice + OrderLots() * OrderOpenPrice()) / (pos.Lots + OrderLots());
        pos.Lots       += OrderLots();
        pos.Commission += OrderCommission();
        pos.Profit     += OrderProfit() + pos.Commission;
        pos.StopLossPrice   = OrderStopLoss();
        pos.TakeProfitPrice = OrderTakeProfit();
        pos.PosComment      = OrderComment();

        positions += 1;
    }

    if (pos.OpenPrice > 0)
        pos.OpenPrice = NormalizeDouble(pos.OpenPrice, _Digits);

    if (pos.Lots == 0)
        pos.OpenTime = D'2050.01.01 00:00';

    return (positions);
}

bool ActionTrade::ManageOrderSend(int type, double lots, int stopLoss, int takeProfit,
                                  TrailingStopMode trlMode, int trlStop, int brkEven)
{
    trailingMode = trlMode;
    trailingStop = trlStop;
    breakEven    = brkEven;

    bool orderResponse = false;
    int positions = SetAggregatePosition(position);

    if (positions < 0)
        return (false);

    if (positions == 0)
    {   // Open a new position.
        orderResponse = OpenNewPosition(type, lots, stopLoss, takeProfit);
    }
    else if (positions > 0)
    {   // There is an open position.
        if ((position.PosType == OP_BUY  && type == OP_BUY) ||
            (position.PosType == OP_SELL && type == OP_SELL))
        {
            orderResponse = AddToCurrentPosition(type, lots, stopLoss, takeProfit);
        }
        else if ((position.PosType == OP_BUY  && type == OP_SELL) ||
                 (position.PosType == OP_SELL && type == OP_BUY))
        {
            if (MathAbs(position.Lots - lots) < epsilon)
                orderResponse = CloseCurrentPosition();
            else if (position.Lots > lots)
                orderResponse = ReduceCurrentPosition(lots, stopLoss, takeProfit);
            else if (position.Lots < lots)
                orderResponse = ReverseCurrentPosition(type, lots, stopLoss, takeProfit);
        }
    }

    return (orderResponse);
}

bool ActionTrade::OpenNewPosition(int type, double lots, int stopLoss, int takeProfit)
{
    bool orderResponse = false;

    if (type != OP_BUY && type != OP_SELL)
    {   // Error. Wrong order type!
        Print("Wrong 'Open new position' request - Wrong order type!");
        return (false);
    }

    double orderLots = NormalizeEntrySize(lots);

    if (AccountFreeMarginCheck(_Symbol, type, orderLots) > 0)
    {
        if (SeparateSLTP)
        {
            if (WriteLogFile)
                logger.WriteLogLine("OpenNewPosition => SendOrder");

            orderResponse = SendOrder(type, orderLots, 0, 0);

            if (orderResponse)
            {
                if (WriteLogFile)
                    logger.WriteLogLine("OpenNewPosition => ModifyPosition");
                double stopLossPrice = GetStopLossPrice(type, stopLoss);
                double takeProfitPrice = GetTakeProfitPrice(type, takeProfit);

                orderResponse = ModifyOrder(orderResponse, stopLossPrice, takeProfitPrice);
            }
        }
        else
        {
            orderResponse = SendOrder(type, orderLots, stopLoss, takeProfit);

            if (WriteLogFile)
                logger.WriteLogLine("OpenNewPosition: SendOrder Response = " +
                                    (orderResponse ? "Ok" : "Failed"));

            if (!orderResponse && lastError == 130)
            {   // Invalid Stops. We'll check for forbidden direct set of SL and TP
                if (WriteLogFile)
                    logger.WriteLogLine("OpenNewPosition: SendOrder");

                orderResponse = SendOrder(type, lots, 0, 0);

                if (orderResponse)
                {
                    if (WriteLogFile)
                        logger.WriteLogLine("OpenNewPosition: ModifyPosition");
                    double stopLossPrice = GetStopLossPrice(type, stopLoss);
                    double takeProfitPrice = GetTakeProfitPrice(type, takeProfit);

                    orderResponse = ModifyOrder(orderResponse, stopLossPrice, takeProfitPrice);

                    if (orderResponse)
                    {
                        SeparateSLTP = true;
                        Print(AccountCompany(), " marked with separate stops setting.");
                    }
                }
            }
        }
    }

    SetAggregatePosition(position);
    if (WriteLogFile)
        logger.WriteLogLine(position.ToString());

    return (orderResponse);
}

bool ActionTrade::CloseCurrentPosition()
{
    bool orderResponse = false;
    int  totalOrders   = OrdersTotal();
    int  orders        = 0;
    datetime openPos[][2];

    for (int i = 0; i < totalOrders; i++)
    {
        if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            lastError = GetLastError();
            Print("Error in OrderSelect: ", GetErrorDescription(lastError));
            continue;
        }

        if (OrderMagicNumber() != ExpertMagic || OrderSymbol() != _Symbol)
            continue;

        int orderType = OrderType();
        if (orderType != OP_BUY && orderType != OP_SELL)
            continue;

        orders++;
        ArrayResize(openPos, orders);
        openPos[orders - 1][0] = OrderOpenTime();
        openPos[orders - 1][1] = OrderTicket();
    }

    if (FIFOorder)
        ArraySort(openPos, WHOLE_ARRAY, 0, MODE_ASCEND);
    else
        ArraySort(openPos, WHOLE_ARRAY, 0, MODE_DESCEND);

    for (int i = 0; i < orders; i++)
    {
        if (!OrderSelect((int) openPos[i][1], SELECT_BY_TICKET))
        {
            lastError = GetLastError();
            Print("Error in OrderSelect: ", GetErrorDescription(lastError));
            continue;
        }

        orderResponse = CloseOrder(OrderTicket(), OrderLots());
    }

    consecutiveLosses = (position.Profit < 0) ? consecutiveLosses + 1 : 0;
    SetAggregatePosition(position);
    Print("ConsecutiveLosses=", consecutiveLosses);

    return (orderResponse);
}

bool ActionTrade::AddToCurrentPosition(int type, double lots, int stopLoss, int takeProfit)
{
    if (AccountFreeMarginCheck(_Symbol, type, lots) <= 0)
        return (false);

    if (WriteLogFile)
        logger.WriteLogLine("AddToCurrentPosition: OpenNewPosition");

    bool orderResponse = OpenNewPosition(type, lots, stopLoss, takeProfit);

    if (!orderResponse)
        return (false);

    double stopLossPrice = GetStopLossPrice(type, stopLoss);
    double takeProfitPrice = GetTakeProfitPrice(type, takeProfit);

    orderResponse = ModifyPosition(stopLossPrice, takeProfitPrice);

    SetAggregatePosition(position);

    return (orderResponse);
}

bool ActionTrade::ReduceCurrentPosition(double lots, int stopLoss, int takeProfit)
{
    int totalOrders = OrdersTotal();
    int orders = 0;
    datetime openPos[][2];

    for (int i = 0; i < totalOrders; i++)
    {
        if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            lastError = GetLastError();
            Print("Error in OrderSelect: ", GetErrorDescription(lastError));
            continue;
        }

        if (OrderMagicNumber() != ExpertMagic ||
            OrderSymbol() != _Symbol)
            continue;

        int orderType = OrderType();
        if (orderType != OP_BUY && orderType != OP_SELL)
            continue;

        orders++;
        ArrayResize(openPos, orders);
        openPos[orders - 1][0] = OrderOpenTime();
        openPos[orders - 1][1] = OrderTicket();
    }

    if (FIFOorder)
        ArraySort(openPos, WHOLE_ARRAY, 0, MODE_ASCEND);
    else
        ArraySort(openPos, WHOLE_ARRAY, 0, MODE_DESCEND);

    for (int i = 0; i < orders; i++)
    {
        if (!OrderSelect((int) openPos[i][1], SELECT_BY_TICKET))
        {
            lastError = GetLastError();
            Print("Error in OrderSelect: ", GetErrorDescription(lastError));
            continue;
        }

        double orderLots = (lots >= OrderLots()) ? OrderLots() : lots;
        CloseOrder(OrderTicket(), orderLots);
        lots -= orderLots;

        if (lots <= 0)
            break;
    }

    double stopLossPrice = GetStopLossPrice(position.PosType, stopLoss);
    double takeProfitPrice = GetTakeProfitPrice(position.PosType, takeProfit);

    bool orderResponse = ModifyPosition(stopLossPrice, takeProfitPrice);

    SetAggregatePosition(position);
    consecutiveLosses = 0;

    return (orderResponse);
}

bool ActionTrade::ReverseCurrentPosition(int type, double lots, int stopLoss, int takeProfit)
{
    lots -= position.Lots;

    bool orderResponse = CloseCurrentPosition();

    if (!orderResponse)
        return (false);

    orderResponse = OpenNewPosition(type, lots, stopLoss, takeProfit);

    SetAggregatePosition(position);
    consecutiveLosses = 0;

    return (orderResponse);
}

bool ActionTrade::SendOrder(int type, double lots, int stopLoss, int takeProfit)
{
    bool orderResponse = false;
    int  response      = -1;

    for (int attempt = 0; attempt < TRADE_RETRY_COUNT; attempt++)
    {
        if (IsTradeContextFree())
        {
            double orderLots       = NormalizeEntrySize(lots);
            double orderPrice      = type == OP_BUY
                                        ? MarketInfo(_Symbol, MODE_ASK)
                                        : MarketInfo(_Symbol, MODE_BID);
            double stopLossPrice   = GetStopLossPrice(type, stopLoss);
            double takeProfitPrice = GetTakeProfitPrice(type, takeProfit);
            color  colorDeal       = type == OP_BUY ? Lime : Red;
            string comment         = (OrderComment == "")
                                        ? "Magic=" + IntegerToString(ExpertMagic)
                                        : OrderComment;

            response = OrderSend(_Symbol, type, orderLots, orderPrice, 100,
                                 stopLossPrice, takeProfitPrice, comment,
                                 ExpertMagic, 0, colorDeal);

            lastError = GetLastError();

            if (WriteLogFile)
                logger.WriteLogLine(
                    "SendOrder: "   + _Symbol +
                    ", Type="       + (type == OP_BUY ? "Buy" : "Sell") +
                    ", Lots="       + DoubleToString(orderLots, 2) +
                    ", Price="      + DoubleToString(orderPrice, _Digits) +
                    ", StopLoss="   + DoubleToString(stopLossPrice, _Digits) +
                    ", TakeProfit=" + DoubleToString(takeProfitPrice, _Digits) +
                    ", Magic="      + IntegerToString(ExpertMagic) +
                    ", Response="   + IntegerToString(response) +
                    ", LastError="  + IntegerToString(lastError));
        }

        orderResponse = response > 0;

        if (orderResponse)
            break;

        if (lastError != 135 && lastError != 136 &&
            lastError != 137 && lastError != 138)
            break;

        Print("Error with SendOrder: ", GetErrorDescription(lastError));

        Sleep(TRADE_RETRY_WAIT);
    }

    return (orderResponse);
}

bool ActionTrade::CloseOrder(int orderTicket, double orderLots)
{
    if (!OrderSelect(orderTicket, SELECT_BY_TICKET))
    {
        lastError = GetLastError();
        Print("Error with OrderSelect: ", GetErrorDescription(lastError));
        return (false);
    }

    int orderType = OrderType();

    for (int attempt = 0; attempt < TRADE_RETRY_COUNT; attempt++)
    {
        bool orderResponse = false;
        if (IsTradeContextFree())
        {
            double orderPrice = (orderType == OP_BUY)
                                ? MarketInfo(_Symbol, MODE_BID)
                                : MarketInfo(_Symbol, MODE_ASK);
            orderPrice = NormalizeDouble(orderPrice, Digits);

            orderResponse = OrderClose(orderTicket, orderLots, orderPrice, 100, Gold);

            lastError = GetLastError();
            if (WriteLogFile)
                logger.WriteLogLine("OrderClose: " + _Symbol +
                        ", Ticket="    + IntegerToString(orderTicket) +
                        ", Lots="      + DoubleToString(orderLots, 2) +
                        ", Price="     + DoubleToString(orderPrice, _Digits) +
                        ", Response="  + (orderResponse ? "True" : "False") +
                        ", LastError=" + IntegerToString(lastError));
        }

        if (orderResponse)
            return (true);

        if (lastError == 4108)
            return (false); // Invalid ticket error.

        Print("Error with CloseOrder: ", GetErrorDescription(lastError),
              ". Attempt No: ", (attempt + 1));

        Sleep(TRADE_RETRY_WAIT);
    }

    return (false);
}

bool ActionTrade::ModifyPosition(double stopLossPrice, double takeProfitPrice)
{
    bool orderResponse = true;

    for (int i = 0; i < OrdersTotal(); i++)
    {
        if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            lastError = GetLastError();
            Print("Error with OrderSelect: ", GetErrorDescription(lastError));
            continue;
        }

        if (OrderMagicNumber() != ExpertMagic || OrderSymbol() != _Symbol)
            continue;

        int type = OrderType();
        if (type != OP_BUY && type != OP_SELL)
            continue;

        orderResponse = ModifyOrder(OrderTicket(), stopLossPrice, takeProfitPrice);
    }

    return (orderResponse);
}

bool ActionTrade::ModifyOrder(int orderTicket, double stopLossPrice, double takeProfitPrice)
{
    if (!SelectOrder(orderTicket))
        return (false);

    stopLossPrice = NormalizeEntryPrice(stopLossPrice);
    takeProfitPrice = NormalizeEntryPrice(takeProfitPrice);
    double oldStopLoss = NormalizeEntryPrice(OrderStopLoss());
    double oldTakeProfit = NormalizeEntryPrice(OrderTakeProfit());

    for (int attempt = 0; attempt < TRADE_RETRY_COUNT; attempt++)
    {
        if (attempt > 0)
        {
            stopLossPrice = CorrectStopLossPrice(OrderType(), stopLossPrice);
            takeProfitPrice = CorrectTakeProfitPrice(OrderType(), takeProfitPrice);
        }

        if (MathAbs(stopLossPrice - oldStopLoss) < pipsValue &&
            MathAbs(takeProfitPrice - oldTakeProfit) < pipsValue)
            return (true); // There isn't anything to change.

        bool isSuccess = false;
        string logline = "";
        double orderOpenPrice = 0;
        if (IsTradeContextFree())
        {
            orderOpenPrice = NormalizeDouble(OrderOpenPrice(), _Digits);

            isSuccess = OrderModify(orderTicket, orderOpenPrice, stopLossPrice, takeProfitPrice, 0);

            lastError = GetLastError();
            if (WriteLogFile)
                logline =
                        "ModifyOrder: " + _Symbol +
                        ", Ticket="     + IntegerToString(orderTicket) +
                        ", Price="      + DoubleToString(orderOpenPrice, _Digits) +
                        ", StopLoss="   + DoubleToString(stopLossPrice, _Digits) +
                        ", TakeProfit=" + DoubleToString(takeProfitPrice, _Digits) + ")" +
                        "  Magic="      + IntegerToString(ExpertMagic) +
                        ", Response="   + IntegerToString(isSuccess) +
                        ", LastError="  + IntegerToString(lastError);
        }

        if (isSuccess)
        {   // Modification was successful.
            if (WriteLogFile)
                logger.WriteLogLine(logline);
            return (true);
        }
        else if (lastError == 1)
        {
            if (!SelectOrder(orderTicket))
                return (false);

            if (MathAbs(stopLossPrice - OrderStopLoss()) < pipsValue &&
                MathAbs(takeProfitPrice - OrderTakeProfit()) < pipsValue)
            {
                if (WriteLogFile)
                    logger.WriteLogLine(logline + ", Checked OK");
                lastError = 0;
                return (true); // We assume that there is no error.
            }
        }

        Print("Error with ModifyOrder(",
              orderTicket, ", ",
              orderOpenPrice, ", ",
              stopLossPrice, ", ",
              takeProfitPrice, ") ",
              GetErrorDescription(lastError), ".");
        Sleep(TRADE_RETRY_WAIT);
        RefreshRates();

        if (lastError == 4108)
            return (false);  // Invalid ticket error.
    }

    return (false);
}

bool ActionTrade::SelectOrder(int orderTicket)
{
    bool orderResponse = OrderSelect(orderTicket, SELECT_BY_TICKET);

    if (!orderResponse)
    {
        lastError = GetLastError();
        string message = "Error with OrderSelect(" +
                         IntegerToString(orderTicket) + ")" +
                         ", LastError=" + IntegerToString(lastError) + ", " +
                         GetErrorDescription(lastError);
        Print(message);
        if (WriteLogFile)
            logger.WriteLogLine(message);
    }

    return (orderResponse);
}

double ActionTrade::GetTakeProfitPrice(int type, int takeProfit)
{
    if (takeProfit < epsilon)
        return (0);

    if (takeProfit < stopLevel)
        takeProfit = stopLevel;

    double takeProfitPrice = (type == OP_BUY)
                             ? MarketInfo(_Symbol, MODE_BID) + takeProfit * _Point
                             : MarketInfo(_Symbol, MODE_ASK) - takeProfit * _Point;

    return (NormalizeEntryPrice(takeProfitPrice));
}

double ActionTrade::GetStopLossPrice(int type, int stopLoss)
{
    if (stopLoss < epsilon)
        return (0);

    if (stopLoss < stopLevel)
        stopLoss = stopLevel;

    double stopLossPrice = (type == OP_BUY)
                           ? MarketInfo(_Symbol, MODE_BID) - stopLoss * _Point
                           : MarketInfo(_Symbol, MODE_ASK) + stopLoss * _Point;

    return (NormalizeEntryPrice(stopLossPrice));
}

double ActionTrade::CorrectTakeProfitPrice(int type, double takeProfitPrice)
{
    if (takeProfitPrice < epsilon)
        return (0);

    double bid = MarketInfo(_Symbol, MODE_BID);
    double ask = MarketInfo(_Symbol, MODE_ASK);

    if (type == OP_BUY)
    {
        double minTPPrice = bid + stopLevel * _Point;
        if (takeProfitPrice < minTPPrice)
            takeProfitPrice = minTPPrice;
    }
    else if (type == OP_SELL)
    {
        double maxTPPrice = ask - stopLevel * _Point;
        if (takeProfitPrice > maxTPPrice)
            takeProfitPrice = maxTPPrice;
    }

    return (NormalizeEntryPrice(takeProfitPrice));
}

double ActionTrade::CorrectStopLossPrice(int type, double stopLossPrice)
{
    if (stopLossPrice == epsilon)
        return (0);

    double bid = MarketInfo(_Symbol, MODE_BID);
    double ask = MarketInfo(_Symbol, MODE_ASK);

    if (type == OP_BUY)
    {
        double minSLPrice = bid - stopLevel * _Point;
        if (stopLossPrice > minSLPrice)
            stopLossPrice = minSLPrice;
    }
    else if (type == OP_SELL)
    {
        double maxSLPrice = ask + stopLevel * _Point;
        if (stopLossPrice < maxSLPrice)
            stopLossPrice = maxSLPrice;
    }

    return (NormalizeEntryPrice(stopLossPrice));
}

double ActionTrade::NormalizeEntryPrice(double price)
{
    double tickSize = MarketInfo(_Symbol, MODE_TICKSIZE);
    if (tickSize != 0)
        return (NormalizeDouble(MathRound(price / tickSize) * tickSize, _Digits));
    return (NormalizeDouble(price, _Digits));
}

double ActionTrade::NormalizeEntrySize(double size)
{
    double minlot  = MarketInfo(_Symbol, MODE_MINLOT);
    double maxlot  = MarketInfo(_Symbol, MODE_MAXLOT);
    double lotstep = MarketInfo(_Symbol, MODE_LOTSTEP);

    if (size < minlot - epsilon)
        return (0);

    if (MathAbs(size - minlot) < epsilon)
        return (minlot);

    int steps = (int) MathRound((size - minlot) / lotstep);
    size = minlot + steps * lotstep;

    if (size >= maxlot)
        size = maxlot;

    return (size);
}

void ActionTrade::SetMaxStopLoss()
{
    double bid = MarketInfo(_Symbol, MODE_BID);
    double ask = MarketInfo(_Symbol, MODE_ASK);
    double spread = (ask - bid) / _Point;

    for (int i = 0; i < OrdersTotal(); i++)
    {
        if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            lastError = GetLastError();
            Print("Error with OrderSelect: ", GetErrorDescription(lastError));
            continue;
        }

        if (OrderMagicNumber() != ExpertMagic ||
            OrderSymbol() != _Symbol)
            continue;

        int type = OrderType();
        if (type != OP_BUY && type != OP_SELL)
            continue;

        int orderTicket = OrderTicket();
        double posOpenPrice = OrderOpenPrice();
        double stopLossPrice = OrderStopLoss();
        double takeProfitPrice = OrderTakeProfit();
        int stopLossPoints = (int)
                MathRound(MathAbs(posOpenPrice - stopLossPrice) / _Point);

        if (stopLossPrice < epsilon ||
            stopLossPoints > ProtectionMaxStopLoss + spread)
        {
            stopLossPrice = (type == OP_BUY)
                            ? posOpenPrice - _Point * (ProtectionMaxStopLoss + spread)
                            : posOpenPrice + _Point * (ProtectionMaxStopLoss + spread);
            stopLossPrice = CorrectStopLossPrice(type, stopLossPrice);

            if (WriteLogFile)
                logger.WriteLogRequest("SetMaxStopLoss", "StopLoss=" +
                                                         DoubleToString(stopLossPrice, _Digits));

            bool isSuccess = ModifyOrder(orderTicket, stopLossPrice, takeProfitPrice);

            if (isSuccess)
                Print("MaxStopLoss(", ProtectionMaxStopLoss, ") set StopLoss to ",
                      DoubleToString(stopLossPrice, _Digits));
        }
    }
}

void ActionTrade::SetBreakEvenStop()
{
    if (SetAggregatePosition(position) <= 0)
        return;

    double breakeven = stopLevel;
    if (breakeven < breakEven)
        breakeven = breakEven;

    double breakprice = 0; // Break Even price including commission.
    double commission = 0; // Commission in points.
    if (position.Commission != 0)
        commission = MathAbs(position.Commission) / MarketInfo(_Symbol, MODE_TICKVALUE);

    double bid = MarketInfo(_Symbol, MODE_BID);
    double ask = MarketInfo(_Symbol, MODE_ASK);

    if (position.PosType == OP_BUY)
    {
        breakprice = NormalizeEntryPrice(position.OpenPrice +
                                         _Point * commission / position.Lots);
        if (bid - breakprice >= _Point * breakeven)
        {
            if (position.StopLossPrice < breakprice)
            {
                if (WriteLogFile)
                    logger.WriteLogRequest("SetBreakEvenStop",
                                           "BreakPrice=" + DoubleToString(breakprice, _Digits));

                ModifyPosition(breakprice, position.TakeProfitPrice);

                Print("SetBreakEvenStop(", breakEven,
                      ") set StopLoss to ", DoubleToString(breakprice, _Digits),
                      ", Bid=", DoubleToString(bid, _Digits));
            }
        }
    }
    else if (position.PosType == OP_SELL)
    {
        breakprice = NormalizeEntryPrice(position.OpenPrice -
                                         _Point * commission / position.Lots);
        if (breakprice - ask >= _Point * breakeven)
        {
            if (position.StopLossPrice == 0 || position.StopLossPrice > breakprice)
            {
                if (WriteLogFile)
                    logger.WriteLogRequest("SetBreakEvenStop", "BreakPrice=" +
                                                               DoubleToString(breakprice, _Digits));

                ModifyPosition(breakprice, position.TakeProfitPrice);

                Print("SetBreakEvenStop(", breakEven, ") set StopLoss to ",
                      DoubleToString(breakprice, _Digits),
                      ", Ask=", DoubleToString(ask, _Digits));
            }
        }
    }
}

void ActionTrade::SetTrailingStop(bool isNewBar)
{
    bool isCheckTS = true;

    if (isNewBar)
    {
        if (position.PosType == OP_BUY && position.OpenTime > barHighTime)
            isCheckTS = false;

        if (position.PosType == OP_SELL && position.OpenTime > barLowTime)
            isCheckTS = false;

        barHighTime  = Time[0];
        barLowTime   = Time[0];
        barHighPrice = High[0];
        barLowPrice  = Low[0];
    }
    else
    {
        if (High[0] > barHighPrice)
        {
            barHighPrice = High[0];
            barHighTime  = Time[0];
        }
        if (Low[0] < barLowPrice)
        {
            barLowPrice = Low[0];
            barLowTime  = Time[0];
        }
    }

    if (SetAggregatePosition(position) <= 0)
        return;

    if (trailingMode == TrailingStopMode_Tick)
        SetTrailingStopTickMode();
    else if (trailingMode == TrailingStopMode_Bar && isNewBar && isCheckTS)
        SetTrailingStopBarMode();
}

void ActionTrade::SetTrailingStopBarMode()
{
    double bid = MarketInfo(_Symbol, MODE_BID);
    double ask = MarketInfo(_Symbol, MODE_ASK);

    if (position.PosType == OP_BUY)
    {   // Long position
        double stopLossPrice = High[1] - _Point * trailingStop;
        if (position.StopLossPrice < stopLossPrice - pipsValue)
        {
            if (stopLossPrice < bid)
            {
                if (stopLossPrice > bid - _Point * stopLevel)
                    stopLossPrice = bid - _Point * stopLevel;

                if (WriteLogFile)
                    logger.WriteLogRequest("SetTrailingStopBarMode",
                                           "StopLoss=" +
                                           DoubleToString(stopLossPrice, _Digits));

                ModifyPosition(stopLossPrice, position.TakeProfitPrice);

                Print("Trailing Stop (", trailingStop, ") moved to: ",
                      DoubleToString(stopLossPrice, _Digits),
                      ", Bid=", DoubleToString(bid, _Digits));
            }
            else
            {
                if (WriteLogFile)
                    logger.WriteLogRequest("SetTrailingStopBarMode",
                                           "StopLoss=" +
                                           DoubleToString(stopLossPrice, _Digits));

                bool orderResponse = CloseCurrentPosition();

                int lastErrorOrdClose = GetLastError();
                lastErrorOrdClose = (lastErrorOrdClose > 0)
                                    ? lastErrorOrdClose
                                    : lastError;
                if (!orderResponse)
                    Print("Error in OrderClose: ",
                          GetErrorDescription(lastErrorOrdClose));
            }
        }
    }
    else if (position.PosType == OP_SELL)
    {   // Short position
        double stopLossPrice = Low[1] + _Point * trailingStop;
        if (position.StopLossPrice > stopLossPrice + pipsValue)
        {
            if (stopLossPrice > ask)
            {
                if (stopLossPrice < ask + _Point * stopLevel)
                    stopLossPrice = ask + _Point * stopLevel;

                if (WriteLogFile)
                    logger.WriteLogRequest("SetTrailingStopBarMode",
                                           "StopLoss=" + DoubleToString(stopLossPrice, _Digits));

                ModifyPosition(stopLossPrice, position.TakeProfitPrice);

                Print("Trailing Stop (", trailingStop, ") moved to: ",
                      DoubleToString(stopLossPrice, _Digits),
                      ", Ask=", DoubleToString(ask, _Digits));
            }
            else
            {
                if (WriteLogFile)
                    logger.WriteLogRequest("SetTrailingStopBarMode",
                                           "StopLoss=" + DoubleToString(stopLossPrice, _Digits));

                bool orderResponse = CloseCurrentPosition();

                int lastErrorOrdClose = GetLastError();
                lastErrorOrdClose = (lastErrorOrdClose > 0) ? lastErrorOrdClose : lastError;
                if (!orderResponse)
                    Print("Error in OrderClose: ",
                          GetErrorDescription(lastErrorOrdClose));
            }
        }
    }
}

void ActionTrade::SetTrailingStopTickMode()
{
    if (position.PosType == OP_BUY)
    {   // Long position
        double bid = MarketInfo(_Symbol, MODE_BID);
        if (bid >= position.OpenPrice + _Point * trailingStop)
        {
            if (position.StopLossPrice < bid - _Point * (trailingStop + TrailingStopMovingStep))
            {
                double stopLossPrice = bid - _Point * trailingStop;
                if (WriteLogFile)
                    logger.WriteLogRequest("SetTrailingStopTickMode",
                                           "StopLoss=" + DoubleToString(stopLossPrice, _Digits));

                ModifyPosition(stopLossPrice, position.TakeProfitPrice);

                Print("Trailing Stop (", trailingStop, ") moved to: ",
                      DoubleToString(stopLossPrice, _Digits),
                      ", Bid=", DoubleToString(bid, _Digits));
            }
        }
    }
    else if (position.PosType == OP_SELL)
    {   // Short position
        double ask = MarketInfo(_Symbol, MODE_ASK);
        if (position.OpenPrice - ask >= _Point * trailingStop)
        {
            if (position.StopLossPrice > ask + _Point * (trailingStop + TrailingStopMovingStep))
            {
                double stopLossPrice = ask + _Point * trailingStop;
                if (WriteLogFile)
                    logger.WriteLogRequest("SetTrailingStopTickMode",
                                           "StopLoss=" + DoubleToString(stopLossPrice, _Digits));

                ModifyPosition(stopLossPrice, position.TakeProfitPrice);

                Print("Trailing Stop (", trailingStop, ") moved to: ",
                      DoubleToString(stopLossPrice, _Digits),
                      ", Ask=", DoubleToString(ask, _Digits));
            }
        }
    }
}

void ActionTrade::DetectPositionClosing()
{
    double oldStopLoss   = position.StopLossPrice;
    double oldTakeProfit = position.TakeProfitPrice;
    double oldProfit     = position.Profit;
    int    oldType       = position.PosType;
    double oldLots       = position.Lots;

    SetAggregatePosition(position);

    if (oldType == OP_FLAT || position.PosType != OP_FLAT)
        return;

    double closePrice     = (oldType == OP_BUY) ? dataMarket.Bid : dataMarket.Ask;
    string stopMessage    = "Position was closed";
    string closePriceText = DoubleToString(closePrice, _Digits);

    if (MathAbs(oldStopLoss - closePrice) < 2 * pipsValue)
        stopMessage = "Activated StopLoss=" + closePriceText;
    else if (MathAbs(oldTakeProfit - closePrice) < 2 * pipsValue)
        stopMessage = "Activated TakeProfit=" + closePriceText;

    consecutiveLosses = (oldProfit < 0) ? consecutiveLosses + 1 : 0;

    string message = stopMessage +
             ", ClosePrice="        + closePriceText +
             ", ClosedLots= "       + DoubleToString(oldLots, 2) +
             ", Profit="            + DoubleToString(oldProfit, 2) +
             ", ConsecutiveLosses=" + IntegerToString(consecutiveLosses);

    if (WriteLogFile)
        logger.WriteNewLogLine(message);
    Print(message);
}

bool ActionTrade::IsTradeContextFree()
{
    if (IsTradeAllowed())
        return (true);

    uint startWait = GetTickCount();
    Print("Trade context is busy! Waiting...");

    while (true)
    {
        if (IsStopped())
            return (false);

        uint diff = GetTickCount() - startWait;
        if (diff > 30 * 1000)
        {
            Print("The waiting limit exceeded!");
            return (false);
        }

        if (IsTradeAllowed())
        {
            RefreshRates();
            return (true);
        }
        Sleep(100);
    }

    return (true);
}

void ActionTrade::ActivateProtectionMinAccount()
{
    CloseCurrentPosition();

    string account = DoubleToString(AccountEquity(), 2);
    string message = "\n" + "The account equity (" + account +
                     ") dropped below the minimum allowed (" +
                     IntegerToString(ProtectionMinAccount) + ").";
    Comment(message);
    Print(message);

    if (WriteLogFile)
        logger.WriteLogLine(message);

    Sleep(20 * 1000);
    CloseExpert();
}

void ActionTrade::CloseExpert(void)
{
    ExpertRemove();
    OnDeinit(0);
}
