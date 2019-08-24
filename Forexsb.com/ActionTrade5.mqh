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
#property version   "5.00"
#property strict

#include <Forexsb.com\StrategyManager.mqh>
#include <Forexsb.com\DataMarket.mqh>
#include <Forexsb.com\DataSet.mqh>
#include <Forexsb.com\Strategy.mqh>
#include <Forexsb.com\Helpers.mqh>
#include <Forexsb.com\HelperMq5.mqh>
#include <Forexsb.com\Enumerations.mqh>
#include <Forexsb.com\IndicatorSlot.mqh>
#include <Forexsb.com\Position.mqh>
#include <Forexsb.com\Logger.mqh>
#include <Forexsb.com\StrategyTrader.mqh>

//## Import Start

#define TRADE_RETRY_COUNT 4
#define TRADE_RETRY_WAIT  100
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ActionTrade
  {
private:
   double            epsilon;

   // Fields
   Strategy         *strategy;
   DataSet          *dataSet[];
   DataMarket       *dataMarket;
   Position         *position;
   Logger           *logger;
   StrategyTrader   *strategyTrader;
   ENUM_ORDER_TYPE_FILLING orderFillingType;

   // Properties
   int               lastError;
   double            pipsValue;
   int               pipsPoint;
   int               stopLevel;
   datetime          barTime;
   datetime          barHighTime;
   datetime          barLowTime;
   double            barHighPrice;
   double            barLowPrice;
   int               trailingStop;
   TrailingStopMode  trailingMode;
   int               breakEven;
   int               consecutiveLosses;

   string            dynamicInfoParams[];
   string            dynamicInfoValues[];

   // Methods
   bool              CheckEnvironment(int minDataBars);
   bool              CheckChartBarsCount(int minDataBars);
   int               FindBarsCountNeeded(int minDataBars);
   int               SetAggregatePosition(Position *pos);
   void              UpdateDataSet(DataSet *data,int maxBars);
   bool              IsTradeContextFree(void);
   void              ActivateProtectionMinAccount(void);
   void              CloseExpert(void);
   ENUM_ORDER_TYPE_FILLING GetOrderFillingType(void);

   // Trading methods
   double            GetTakeProfitPrice(int type,int takeProfit);
   double            GetStopLossPrice(int type,int stopLoss);
   double            CorrectTakeProfitPrice(int type,double takeProfitPrice);
   double            CorrectStopLossPrice(int type,double stopLossPrice);
   double            NormalizeEntryPrice(double price);
   void              SetMaxStopLoss(void);
   void              SetBreakEvenStop(void);
   void              SetTrailingStop(bool isNewBar);
   void              SetTrailingStopBarMode(void);
   void              SetTrailingStopTickMode(void);
   void              DetectPositionClosing(void);

public:
   // Constructor, deconstructor
                     ActionTrade(void);
                    ~ActionTrade(void);

   // Properties
   double            EntryAmount;
   double            MaximumAmount;
   double            AddingAmount;
   double            ReducingAmount;
   string            OrderComment;
   int               MinDataBars;
   int               ProtectionMinAccount;
   int               ProtectionMaxStopLoss;
   bool              SeparateSLTP;
   bool              WriteLogFile;
   int               TrailingStopMovingStep;
   int               MaxLogLinesInFile;
   int               BarCloseAdvance;

   // Methods
   int               OnInit(void);
   void              OnTick(void);
   void              OnTrade(void);
   void              OnDeinit(const int reason);
   void              UpdateDataMarket(DataMarket *market);
   double            NormalizeEntrySize(double size);
   bool              ManageOrderSend(int type,double lots,int stopLoss,int takeProfit,
                                     TrailingStopMode trlMode,int trlStop,int brkEven);
   bool              ModifyPosition(double stopLossPrice,double takeProfitPrice);
   bool              CloseCurrentPosition(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ActionTrade::ActionTrade(void)
  {
   epsilon  = 0.000001;
   position = new Position();
   logger   = new Logger();
   strategyTrader   = new StrategyTrader(GetPointer(this));
   orderFillingType = GetOrderFillingType();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ActionTrade::~ActionTrade(void)
  {
   if(CheckPointer(position)==POINTER_DYNAMIC)
      delete position;
   if(CheckPointer(logger)==POINTER_DYNAMIC)
      delete logger;
   if(CheckPointer(strategyTrader)==POINTER_DYNAMIC)
      delete strategyTrader;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ActionTrade::OnInit()
  {
   dataMarket   = new DataMarket();
   barHighTime  = 0;
   barLowTime   = 0;
   barHighPrice = 0;
   barLowPrice  = 1000000;

   string message=StringFormat("%s loaded.",MQLInfoString(MQL_PROGRAM_NAME));
   Comment(message);
   Print(message);

   if(WriteLogFile)
     {
      logger.CreateLogFile(logger.GetLogFileName(_Symbol, _Period, 5));
      logger.WriteLogLine(message);
      logger.WriteLogLine("Entry Amount: "    + DoubleToString(EntryAmount, 2)   + ", " +
                          "Maximum Amount: "  + DoubleToString(MaximumAmount, 2) + ", " +
                          "Adding Amount: "   + DoubleToString(AddingAmount, 2)  + ", " +
                          "Reducing Amount: " + DoubleToString(ReducingAmount, 2));
      logger.WriteLogLine("Protection Min Account: "  + IntegerToString(ProtectionMinAccount) + ", " +
                          "Protection Max StopLoss: " + IntegerToString(ProtectionMaxStopLoss));
      logger.WriteLogLine("Bar Close Advance:  " + IntegerToString(BarCloseAdvance));
      logger.FlushLogFile();
     }

   if(_Digits==2 || _Digits==3)
      pipsValue=0.01;
   else if(_Digits==4 || _Digits==5)
      pipsValue=0.0001;
   else
      pipsValue=_Digits;

   if(_Digits==3 || _Digits==5)
      pipsPoint=10;
   else
      pipsPoint=1;

   stopLevel=(int) SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL)+pipsPoint;
   if(stopLevel<3*pipsPoint)
      stopLevel=3*pipsPoint;

   if(ProtectionMaxStopLoss>0 && ProtectionMaxStopLoss<stopLevel)
      ProtectionMaxStopLoss=stopLevel;

   if(TrailingStopMovingStep<pipsPoint)
      TrailingStopMovingStep=pipsPoint;

   StrategyManager *strategyManager=new StrategyManager();

// Strategy initialization
   strategy=strategyManager.GetStrategy();
   strategy.SetSymbol(_Symbol);
   strategy.SetPeriod((DataPeriod) _Period);
   strategy.SetIsTester(MQLInfoInteger(MQL_TESTER));
   strategy.EntryLots    = EntryAmount;
   strategy.MaxOpenLots  = MaximumAmount;
   strategy.AddingLots   = AddingAmount;
   strategy.ReducingLots = ReducingAmount;

   delete strategyManager;

// Checks the requirements.
   bool isEnvironmentGood=CheckEnvironment(strategy.MinBarsRequired);
   if(!isEnvironmentGood)
     {   // There is a non fulfilled condition, therefore we must exit.
      Sleep(20*1000);
      ExpertRemove();
      return (INIT_FAILED);
     }

// Market initialization
   string charts[];
   strategy.GetRequiredCharts(charts);

   string chartsNote="Loading data: ";
   for(int i=0; i<ArraySize(charts); i++)
     {
      chartsNote+=charts[i]+", ";
     }
   chartsNote+="Minumum bars: "+IntegerToString(strategy.MinBarsRequired)+"...";
   Comment(chartsNote);
   Print(chartsNote);

// Initial data loading
   ArrayResize(dataSet,ArraySize(charts));
   for(int i=0; i<ArraySize(charts); i++)
     {
      dataSet[i]=new DataSet(charts[i]);
     }

   SetAggregatePosition(position);

// Checks the necessary bars.
   MinDataBars=FindBarsCountNeeded(MinDataBars);

// Initial strategy calculation
   for(int i=0; i<ArraySize(dataSet); i++)
     {
      UpdateDataSet(dataSet[i],MinDataBars);
     }
   strategy.CalculateStrategy(dataSet);

// Initialize StrategyTrader
   strategyTrader.OnInit(strategy, dataMarket);
   strategyTrader.InitTrade();

// Initialize the chart's info label.
   strategy.DynamicInfoInitArrays(dynamicInfoParams,dynamicInfoValues);
   int paramsX   = 0;
   int valuesX   = 140;
   int locationY = 40;
   color foreColor=GetChartForeColor(0);
   int count = ArraySize(dynamicInfoParams);
   for(int i = 0; i < count; i++)
     {
      string namep = "Lbl_prm_" + IntegerToString(i);
      string namev = "Lbl_val_" + IntegerToString(i);
      string param = dynamicInfoParams[i] == "" ? "." : dynamicInfoParams[i];
      LabelCreate(0,namep,0,paramsX,locationY,CORNER_LEFT_UPPER,param,"Ariel",8,foreColor);
      LabelCreate(0,namev,0,valuesX,locationY,CORNER_LEFT_UPPER,".","Ariel",8,foreColor);
      locationY+=12;
     }

   LabelCreate(0,"Lbl_pos_0",0,350,0,CORNER_LEFT_UPPER,".","Ariel",10,foreColor);
   LabelCreate(0,"Lbl_pos_1",0,350,15,CORNER_LEFT_UPPER,".","Ariel",10,foreColor);
   LabelCreate(0,"Lbl_pos_2",0,350,29,CORNER_LEFT_UPPER,".","Ariel",10,foreColor);

   Comment("");

   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ActionTrade::OnTick()
  {
   for(int i=0; i<ArraySize(dataSet); i++)
     {
      UpdateDataSet(dataSet[i],MinDataBars);
     }
   UpdateDataMarket(dataMarket);

   bool isNewBar=(barTime<dataMarket.BarTime && dataMarket.Volume<5);
   barTime   = dataMarket.BarTime;
   lastError = 0;

// Checks if minimum account was reached.
   if(ProtectionMinAccount>0 && AccountInfoDouble(ACCOUNT_EQUITY)<ProtectionMinAccount)
      ActivateProtectionMinAccount();

// Checks and sets Max SL protection.
   if(ProtectionMaxStopLoss>0)
      SetMaxStopLoss();

// Checks if position was closed.
   DetectPositionClosing();

   if(breakEven>0)
      SetBreakEvenStop();

   if(trailingStop>0)
      SetTrailingStop(isNewBar);

   SetAggregatePosition(position);

   if(isNewBar && WriteLogFile)
      logger.WriteNewLogLine(position.ToString());

   if(dataSet[0].Bars>=strategy.MinBarsRequired)
     {
      strategy.CalculateStrategy(dataSet);
      TickType tickType=strategyTrader.GetTickType(isNewBar,BarCloseAdvance);
      strategyTrader.CalculateTrade(tickType);
     }

// Sends OrderModify on SL/TP errors
   if(strategyTrader.IsWrongStopsExecution())
      strategyTrader.ResendWrongStops();

   string accountInfo=StringFormat("%s Balance: %.2f, Equity: %.2f",
                                   TimeToString(dataMarket.TickServerTime,TIME_SECONDS),
                                   AccountInfoDouble(ACCOUNT_BALANCE),
                                   AccountInfoDouble(ACCOUNT_EQUITY));
   LabelTextChange(0,"Lbl_pos_0",accountInfo);
   string positionInfo[2];
   position.SetPositionInfo(positionInfo);
   for(int i=0; i<2; i++)
     {
      LabelTextChange(0,"Lbl_pos_"+IntegerToString(i+1),positionInfo[i]);
     }

   strategy.DynamicInfoSetValues(dynamicInfoValues);
   int count = ArraySize(dynamicInfoValues);
   for(int i = 0; i < count; i++)
     {
      string namev="Lbl_val_"+IntegerToString(i);
      string val=dynamicInfoValues[i]=="" ? "." : dynamicInfoValues[i];
      LabelTextChange(0,namev,val);
     }

   if(WriteLogFile)
     {
      if(logger.IsLogLinesLimitReached(MaxLogLinesInFile))
        {
         logger.CloseLogFile();
         logger.CreateLogFile(logger.GetLogFileName(_Symbol, _Period, 5));
        }
      logger.FlushLogFile();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ActionTrade::OnDeinit(const int reason)
  {
   strategyTrader.OnDeinit();

   if(WriteLogFile)
      logger.CloseLogFile();

   if(CheckPointer(strategy)==POINTER_DYNAMIC)
      delete strategy;

   for(int i=0; i<ArraySize(dataSet); i++)
     {
      if(CheckPointer(dataSet[i])==POINTER_DYNAMIC)
         delete dataSet[i];
     }
   ArrayFree(dataSet);

   if(CheckPointer(dataMarket)==POINTER_DYNAMIC)
      delete dataMarket;

   int count = ArraySize(dynamicInfoParams);
   for(int i = 0; i < count; i++)
     {
      LabelDelete(0,"Lbl_val_"+IntegerToString(i));
      LabelDelete(0,"Lbl_prm_"+IntegerToString(i));
     }

   for(int i=0; i<3; i++)
      LabelDelete(0,"Lbl_pos_"+IntegerToString(i));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ActionTrade::OnTrade(void)
  {
   datetime now=TimeCurrent();
   HistorySelect(now-30*24*60*60,now);
   int total=(int) HistoryDealsTotal();
   ulong ticket=0;
   int maxLosses=0;
   for(int i=total; i>=0; i--)
     {
      if((ticket=HistoryDealGetTicket(i))>0)
        {
         double price  = HistoryDealGetDouble(ticket, DEAL_PRICE);
         long   time   = HistoryDealGetInteger(ticket, DEAL_TIME);
         string symbol = HistoryDealGetString(ticket, DEAL_SYMBOL);
         double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
         if(price>epsilon && time>0 && symbol==_Symbol)
           {
            if(profit<-epsilon)
               maxLosses++;
            if(profit>epsilon)
              {
               consecutiveLosses=maxLosses;
               break;
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ActionTrade::CheckEnvironment(int minDataBars)
  {
// Checks the count of bars available.
   if(!CheckChartBarsCount(minDataBars))
      return (false);

   if(MQLInfoInteger(MQL_TESTER))
     {
      SetAggregatePosition(position);
      return (true);
     }

   if(AccountNumber()==0)
     {
      Comment("\n You are not logged in. Please login first.");
      for(int attempt=0; attempt<200; attempt++)
        {
         if(AccountNumber()==0)
            Sleep(300);
         else
            break;
        }
      if(AccountNumber()==0)
         return (false);
     }

   if(SetAggregatePosition(position)==-1)
      return (false);

   return (true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ActionTrade::FindBarsCountNeeded(int minDataBars)
  {
   int barStep = 50;
   int minBars = MathMax(minDataBars, 50);
   int maxBars = MathMax(minBars, 3000);

// Initial state
   int initialBars=MathMax(strategy.MinBarsRequired,minBars);
   initialBars=MathMax(strategy.FirstBar,initialBars);
   for(int i=0; i<ArraySize(dataSet); i++)
     {
      UpdateDataSet(dataSet[i],initialBars);
     }
   UpdateDataMarket(dataMarket);
   double initialBid=dataMarket.Bid;
   strategy.CalculateStrategy(dataSet);
   string dynamicInfo= strategy.DynamicInfoText();
   int necessaryBars = initialBars;
   int roundedInitialBars=(int)(barStep*MathCeil(((double) initialBars)/barStep));
   int firstTestBars=roundedInitialBars>=initialBars+barStep/2
                     ? roundedInitialBars
                     : roundedInitialBars+barStep;

   for(int bars=firstTestBars; bars<=maxBars; bars+=barStep)
     {
      for(int i=0; i<ArraySize(dataSet); i++)
        {
         UpdateDataSet(dataSet[i],bars);
        }
      UpdateDataMarket(dataMarket);
      strategy.CalculateStrategy(dataSet);
      string currentInfo=strategy.DynamicInfoText();

      if(dynamicInfo==currentInfo)
         break;

      dynamicInfo=currentInfo;
      necessaryBars=bars;

      if(MathAbs(initialBid-dataMarket.Bid)>epsilon)
        {  // Reset the test if new tick has arrived.
         for(int i=0; i<ArraySize(dataSet); i++)
           {
            UpdateDataSet(dataSet[i],initialBars);
           }
         UpdateDataMarket(dataMarket);
         initialBid=dataMarket.Bid;
         strategy.CalculateStrategy(dataSet);
         dynamicInfo=strategy.DynamicInfoText();
         bars=firstTestBars-barStep;
        }
     }

   string barsMessage="The expert uses "+IntegerToString(necessaryBars)+" bars.";
   if(WriteLogFile)
     {
      logger.WriteLogLine(barsMessage);
      string timeLastBar=TimeToString(dataMarket.TickServerTime,TIME_DATE|TIME_MINUTES);
      logger.WriteLogLine("Indicator values: " + dataSet[0].Chart + ", Time last bar: " + timeLastBar);
      logger.WriteLogLine(dynamicInfo);
     }
   Print(barsMessage);

   return (necessaryBars);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ActionTrade::UpdateDataSet(DataSet *data,int maxBars)
  {
   string symbol = data.Symbol;
   int    bars   = MathMin(Bars(symbol, DataPeriodToTimeFrame(data.Period)), maxBars);
   MqlTick tick;
   SymbolInfoTick(symbol,tick);

   data.LotSize        = (int) SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE);
   data.Digits         = (int) SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   data.StopLevel      = (int) SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);
   data.Point          = SymbolInfoDouble(symbol, SYMBOL_POINT);
   data.TickValue      = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
   data.MinLot         = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   data.MaxLot         = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   data.LotStep        = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   data.MarginRequired = SymbolInfoDouble(symbol, SYMBOL_MARGIN_INITIAL);
   data.Bars           = bars;
   data.ServerTime     = tick.time;
   data.Bid            = tick.bid;
   data.Ask            = tick.ask;
   data.Spread         = (tick.ask - tick.bid) / data.Point;

   if(data.MarginRequired<epsilon)
      bool ok=OrderCalcMargin(ORDER_TYPE_BUY,symbol,1,tick.ask,data.MarginRequired);
   if(data.MarginRequired<epsilon)
      data.MarginRequired=tick.bid*data.LotSize/100;

   data.SetPrecision();

   MqlRates rates[];
   ArraySetAsSeries(rates,false);
   int copied=CopyRates(symbol,DataPeriodToTimeFrame(data.Period),0,bars,rates);

   ArrayResize(data.Time,   bars);
   ArrayResize(data.Open,   bars);
   ArrayResize(data.High,   bars);
   ArrayResize(data.Low,    bars);
   ArrayResize(data.Close,  bars);
   ArrayResize(data.Volume, bars);

   for(int i=0; i<bars; i++)
     {
      data.Time[i]   = rates[i].time;
      data.Open[i]   = rates[i].open;
      data.High[i]   = rates[i].high;
      data.Low[i]    = rates[i].low;
      data.Close[i]  = rates[i].close;
      data.Volume[i] = (int) rates[i].tick_volume;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ActionTrade::UpdateDataMarket(DataMarket *market)
  {
   market.Symbol = _Symbol;
   market.Period = (DataPeriod) (PeriodSeconds(_Period)/60);

   MqlTick tick;
   SymbolInfoTick(_Symbol,tick);

   market.TickLocalTime  = TimeLocal();
   market.TickServerTime = tick.time;
   market.BarTime        = Time(_Symbol, _Period, 0);

   market.PositionLots       = position.Lots;
   market.PositionOpenPrice  = position.OpenPrice;
   market.PositionOpenTime   = position.OpenTime;
   market.PositionStopLoss   = position.StopLossPrice;
   market.PositionTakeProfit = position.TakeProfitPrice;
   market.PositionProfit     = position.Profit;
   market.PositionDirection  = position.Direction;

   market.AccountBalance    = AccountInfoDouble(ACCOUNT_BALANCE);
   market.AccountEquity     = AccountInfoDouble(ACCOUNT_EQUITY);
   market.AccountFreeMargin = AccountInfoDouble(ACCOUNT_FREEMARGIN);
   market.ConsecutiveLosses = consecutiveLosses;

   market.OldAsk   = market.Ask;
   market.OldBid   = market.Bid;
   market.OldClose = market.Close;
   market.Ask      = tick.ask;
   market.Bid      = tick.bid;
   market.Close    = Close(_Symbol, _Period, 0);
   market.Volume   = Volume(_Symbol, _Period, 0);
   market.IsNewBid = MathAbs(market.OldBid - market.Bid) > epsilon;

   market.LotSize        = (int) SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE);
   market.StopLevel      = (int) SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   market.Point          = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   market.TickValue      = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   market.MinLot         = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   market.MaxLot         = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   market.LotStep        = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   market.MarginRequired = SymbolInfoDouble(_Symbol, SYMBOL_MARGIN_INITIAL);
   market.Spread         = (market.Ask - market.Bid) / market.Point;

   if(market.MarginRequired<epsilon)
      bool ok=OrderCalcMargin(ORDER_TYPE_BUY,_Symbol,1,market.Ask,market.MarginRequired);
   if(market.MarginRequired<epsilon)
      market.MarginRequired=market.Bid*market.LotSize/100;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ActionTrade::CheckChartBarsCount(int minDataBars)
  {
   int bars=Bars(_Symbol,_Period);
   bool isEnoughBars=bars>=minDataBars;
   if(isEnoughBars) return (true);

   string message="\n Cannot load enough bars! The expert needs minimum "+
                  IntegerToString(minDataBars)+" bars."+
                  "\n Currently "+IntegerToString(bars)+" bars are loaded.";

   if(MQLInfoInteger(MQL_TESTER))
      message+="\n Please use a custom date period and set the dates properly.";

   Comment(message);
   Print(message);
   return (false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
   pos.Ticket           = 0;
   pos.PosComment       = "";

   if(!PositionSelect(_Symbol))
      return (0);

   pos.PosType    = (int) PositionGetInteger(POSITION_TYPE);
   pos.Direction  = position.PosType == OP_FLAT ? PosDirection_None :
                   position.PosType==OP_BUY ? PosDirection_Long : PosDirection_Short;
   pos.OpenTime=(datetime) MathMax(PositionGetInteger(POSITION_TIME),
                 PositionGetInteger(POSITION_TIME_UPDATE));
   pos.OpenPrice  = NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN), _Digits);
   pos.Lots       = NormalizeDouble(PositionGetDouble(POSITION_VOLUME), 2);
   pos.Profit     = NormalizeDouble(PositionGetDouble(POSITION_PROFIT) +
                                    PositionGetDouble(POSITION_COMMISSION),2);
   pos.Commission=NormalizeDouble(PositionGetDouble(POSITION_COMMISSION),2);
   pos.StopLossPrice   = NormalizeDouble(PositionGetDouble(POSITION_SL), _Digits);
   pos.TakeProfitPrice = NormalizeDouble(PositionGetDouble(POSITION_TP), _Digits);
   pos.Ticket     = PositionGetInteger(POSITION_TICKET);
   pos.PosComment = PositionGetString(POSITION_COMMENT);

   return (1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ActionTrade::ManageOrderSend(int type,double lots,int stopLoss,int takeProfit,
                                  TrailingStopMode trlMode,int trlStop,int brkEven)
  {
   trailingMode = trlMode;
   trailingStop = trlStop;
   breakEven    = brkEven;

   for(int attempt=0; attempt<TRADE_RETRY_COUNT; attempt++)
     {
      if(IsTradeContextFree())
        {
         ResetLastError();

         MqlTick tick;
         SymbolInfoTick(_Symbol,tick);

         double orderLots       = NormalizeEntrySize(lots);
         double stopLossPrice   = GetStopLossPrice(type, stopLoss);
         double takeProfitPrice = GetTakeProfitPrice(type, takeProfit);

         MqlTradeRequest request;
         MqlTradeResult result;
         MqlTradeCheckResult check;
         ZeroMemory(request);
         ZeroMemory(result);
         ZeroMemory(check);

         request.action       = TRADE_ACTION_DEAL;
         request.symbol       = _Symbol;
         request.volume       = orderLots;
         request.type_filling = orderFillingType;
         request.type         = (type == OP_BUY) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
         request.price        = (type == OP_BUY) ? tick.ask : tick.bid;
         request.deviation    = 10;
         request.sl           = stopLossPrice;
         request.tp           = takeProfitPrice;
         request.comment      = OrderComment;

         if(PositionSelect(_Symbol))
           {
            ulong  posType = PositionGetInteger(POSITION_TYPE);
            ulong  ticket  = PositionGetInteger(POSITION_TICKET);
            double volume  = PositionGetDouble(POSITION_VOLUME);

            if((posType==OP_BUY && type==OP_BUY) || (posType==OP_SELL && type==OP_SELL))
              {
               request.position=ticket; // Adding
              }
            else if((posType==OP_BUY && type==OP_SELL) || (posType==OP_SELL && type==OP_BUY))
                 {
                  if(volume==orderLots)
                     request.position=ticket; // Close
                  else if(volume>orderLots)
                     request.position=ticket; // Reducing
                  else if(volume<orderLots)
                     request.position=ticket; // Reverse
                 }
              }

            bool isOrderCheck=OrderCheck(request,check);
            string retcode=ResultRetcodeDescription(check.retcode);

            if(!isOrderCheck)
               Print("Error: ",__FUNCTION__,"(): OrderCheck(): ",retcode);

            bool isOrderSend=false;
            if(isOrderCheck)
              {
               isOrderSend=OrderSend(request,result);
               retcode=ResultRetcodeDescription(result.retcode);

               if(!isOrderSend)
                  Print("Error: ",__FUNCTION__,"(): OrderSend(): ",retcode);
              }

            bool isExecuted=isOrderCheck && isOrderSend && result.retcode==TRADE_RETCODE_DONE;

            SetAggregatePosition(position);

            lastError=GetLastError();
            if(WriteLogFile)
              {
               logger.WriteLogLine(
                                   "ManageOrderSend: "+_Symbol+
                                   ", Type="+(type==OP_BUY ? "Buy" : "Sell")+
                                   ", Lots="+DoubleToString(orderLots,2)+
                                   ", Price="+DoubleToString(result.price,_Digits)+
                                   ", StopLoss="+DoubleToString(stopLossPrice,_Digits)+
                                   ", TakeProfit="+DoubleToString(takeProfitPrice,_Digits)+
                                   ", RetCode="+retcode+
                                   ", LastError="+IntegerToString(lastError));
              }

            if(isExecuted)
               return (true);
           }

         Sleep(TRADE_RETRY_WAIT);
        }
      return (false);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   bool ActionTrade::CloseCurrentPosition()
     {
      if(position.PosType==OP_FLAT)
         return (true);
      int    type = (position.PosType == OP_BUY) ? OP_SELL : OP_BUY;
      double lots = position.Lots;

      bool orderResponse=ManageOrderSend(type,lots,0,0,trailingMode,trailingStop,breakEven);

      return (orderResponse);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   bool ActionTrade::ModifyPosition(double stopLossPrice,double takeProfitPrice)
     {
      for(int attempt=0; attempt<TRADE_RETRY_COUNT; attempt++)
        {
         if(IsTradeContextFree())
           {
            if(position.PosType == OP_FLAT) return (false);
            stopLossPrice=CorrectStopLossPrice(position.PosType,stopLossPrice);
            takeProfitPrice=CorrectTakeProfitPrice(position.PosType,takeProfitPrice);

            MqlTradeRequest request;
            MqlTradeResult result;
            MqlTradeCheckResult check;
            ZeroMemory(request);
            ZeroMemory(result);
            ZeroMemory(check);

            request.symbol = _Symbol;
            request.action = TRADE_ACTION_SLTP;
            request.sl = stopLossPrice;
            request.tp = takeProfitPrice;

            bool isOrderCheck=OrderCheck(request,check);
            string retcode=ResultRetcodeDescription(check.retcode);

            if(!isOrderCheck)
               Print("Error: ","ModifyPosition: ","OrderCheck: ",retcode);

            bool isOrderSend=false;
            if(isOrderCheck)
              {
               isOrderSend=OrderSend(request,result);
               retcode=ResultRetcodeDescription(result.retcode);

               if(!isOrderSend)
                  Print("Error: ","ModifyPosition: ","OrderSend: ",retcode);
              }

            bool isExecuted=isOrderCheck && isOrderSend && result.retcode==TRADE_RETCODE_DONE;

            SetAggregatePosition(position);

            lastError=GetLastError();
            if(WriteLogFile)
              {
               logger.WriteLogLine("ModifyPosition: "+_Symbol+
                                   ", StopLoss="+DoubleToString(stopLossPrice,_Digits)+
                                   ", TakeProfit="+DoubleToString(takeProfitPrice,_Digits)+
                                   ", RetCode="+retcode+
                                   ", LastError="+IntegerToString(lastError));
              }

            if(isExecuted)
               return (true);
           }

         Sleep(TRADE_RETRY_WAIT);
        }
      return (false);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   double ActionTrade::GetTakeProfitPrice(int type,int takeProfit)
     {
      if(takeProfit<epsilon)
         return (0);

      if(takeProfit<stopLevel)
         takeProfit=stopLevel;

      MqlTick tick;
      SymbolInfoTick(_Symbol,tick);

      double takeProfitPrice=(type==OP_BUY)
                             ? (tick.bid + takeProfit * _Point)
                             : (tick.ask - takeProfit * _Point);

      return (NormalizeEntryPrice(takeProfitPrice));
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   double ActionTrade::GetStopLossPrice(int type,int stopLoss)
     {
      if(stopLoss<epsilon)
         return (0);

      if(stopLoss<stopLevel)
         stopLoss=stopLevel;

      MqlTick tick;
      SymbolInfoTick(_Symbol,tick);

      double stopLossPrice=(type==OP_BUY)
                           ? (tick.bid - stopLoss * _Point)
                           : (tick.ask + stopLoss * _Point);

      return (NormalizeEntryPrice(stopLossPrice));
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   double ActionTrade::CorrectTakeProfitPrice(int type,double takeProfitPrice)
     {
      if(takeProfitPrice<epsilon)
         return (0);

      MqlTick tick;
      SymbolInfoTick(_Symbol,tick);

      if(type==OP_BUY)
        {
         double minTPPrice=tick.bid+stopLevel*_Point;
         if(takeProfitPrice<minTPPrice)
            takeProfitPrice=minTPPrice;
        }
      else if(type==OP_SELL)
        {
         double maxTPPrice=tick.ask-stopLevel*_Point;
         if(takeProfitPrice>maxTPPrice)
            takeProfitPrice=maxTPPrice;
        }

      return (NormalizeEntryPrice(takeProfitPrice));
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   double ActionTrade::CorrectStopLossPrice(int type,double stopLossPrice)
     {
      if(stopLossPrice<epsilon)
         return (0);

      MqlTick tick;
      SymbolInfoTick(_Symbol,tick);

      if(type==OP_BUY)
        {
         double minSLPrice=tick.bid-stopLevel*_Point;
         if(stopLossPrice>minSLPrice)
            stopLossPrice=minSLPrice;
        }
      else if(type==OP_SELL)
        {
         double maxSLPrice=tick.ask+stopLevel*_Point;
         if(stopLossPrice<maxSLPrice)
            stopLossPrice=maxSLPrice;
        }

      return (NormalizeEntryPrice(stopLossPrice));
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   double ActionTrade::NormalizeEntryPrice(double price)
     {
      double tickSize=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
      if(tickSize!=0)
         return (NormalizeDouble(MathRound(price / tickSize) * tickSize, _Digits));
      return (NormalizeDouble(price, _Digits));
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   double ActionTrade::NormalizeEntrySize(double size)
     {
      double minlot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      double maxlot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
      double lotstep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

      if(size<minlot-epsilon)
         return (0);

      if(MathAbs(size-minlot)<epsilon)
         return (minlot);

      int steps=(int) MathRound((size-minlot)/lotstep);
      size=minlot+steps*lotstep;

      if(size >= maxlot)
         size = maxlot;

      return (size);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   void ActionTrade::SetMaxStopLoss()
     {
      if(position.PosType==OP_FLAT || ProtectionMaxStopLoss==0)
         return;

      double stopLossPrice=position.StopLossPrice;
      int spread=(int) SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);
      int stopLoss=(int) MathRound(MathAbs(position.OpenPrice-position.StopLossPrice)/_Point);

      if(stopLossPrice<epsilon || stopLoss>ProtectionMaxStopLoss+spread)
        {
         stopLossPrice=(position.PosType==OP_BUY)
                       ? (position.OpenPrice - _Point * (ProtectionMaxStopLoss + spread))
                       : (position.OpenPrice + _Point * (ProtectionMaxStopLoss + spread));

         if(WriteLogFile)
           {
            logger.WriteLogRequest("SetMaxStopLoss",
                                   "StopLossPrice="+
                                   DoubleToString(stopLossPrice,_Digits));
           }                       

         bool result=ModifyPosition(stopLossPrice,position.TakeProfitPrice);

         if(result)
            Print("SetMaxStopLoss(",ProtectionMaxStopLoss,") set StopLoss to ",
                  DoubleToString(stopLossPrice,_Digits));
        }
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   void ActionTrade::SetBreakEvenStop()
     {
      if(SetAggregatePosition(position)<=0)
         return;

      double breakeven=stopLevel;
      if(breakeven<breakEven)
         breakeven=breakEven;

      double breakprice = 0; // Break Even price including commission.
      double commission = 0; // Commission in points.
      if(position.Commission!=0)
         commission=MathAbs(position.Commission)/
                    SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);

      MqlTick tick;
      SymbolInfoTick(_Symbol,tick);

      if(position.PosType==OP_BUY)
        {
         breakprice=position.OpenPrice+_Point*commission/position.Lots;
         if(tick.bid-breakprice>=_Point*breakeven)
           {
            if(position.StopLossPrice<breakprice)
              {
               if(WriteLogFile)
                  logger.WriteLogRequest("SetBreakEvenStop",
                                         "BreakPrice="+DoubleToString(breakprice,_Digits));

               ModifyPosition(breakprice,position.TakeProfitPrice);

               Print("SetBreakEvenStop(",breakEven,") set StopLoss to ",
                     DoubleToString(breakprice,_Digits),", Bid=",tick.bid);
              }
           }
        }
      else if(position.PosType==OP_SELL)
        {
         breakprice=position.OpenPrice-_Point*commission/position.Lots;
         if(breakprice-tick.ask>=_Point*breakeven)
           {
            if(position.StopLossPrice==0 || position.StopLossPrice>breakprice)
              {
               if(WriteLogFile)
                  logger.WriteLogRequest("SetBreakEvenStop",
                                         "BreakPrice="+DoubleToString(breakprice,_Digits));

               ModifyPosition(breakprice,position.TakeProfitPrice);

               Print("SetBreakEvenStop(",breakEven,") set StopLoss to ",
                     DoubleToString(breakprice,_Digits),", Ask=",tick.ask);
              }
           }
        }
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   void ActionTrade::SetTrailingStop(bool isNewBar)
     {
      bool isCheckTS=true;

      if(isNewBar)
        {
         if(position.PosType==OP_BUY && position.OpenTime>barHighTime)
            isCheckTS=false;

         if(position.PosType==OP_SELL && position.OpenTime>barLowTime)
            isCheckTS=false;

         barHighTime  = Time(_Symbol, _Period, 0);
         barLowTime   = Time(_Symbol, _Period, 0);
         barHighPrice = High(_Symbol, _Period, 0);
         barLowPrice  = Low(_Symbol, _Period, 0);
        }
      else
        {
         if(High(_Symbol,_Period,0)>barHighPrice)
           {
            barHighPrice = High(_Symbol, _Period, 0);
            barHighTime  = Time(_Symbol, _Period, 0);
           }
         if(Low(_Symbol,_Period,0)<barLowPrice)
           {
            barLowPrice = Low(_Symbol, _Period, 0);
            barLowTime  = Time(_Symbol, _Period, 0);
           }
        }

      if(SetAggregatePosition(position)<=0)
         return;

      if(trailingMode==TrailingStopMode_Tick)
         SetTrailingStopTickMode();
      else if(trailingMode==TrailingStopMode_Bar && isNewBar && isCheckTS)
         SetTrailingStopBarMode();
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   void ActionTrade::SetTrailingStopBarMode()
     {
      MqlTick tick;
      SymbolInfoTick(_Symbol,tick);

      if(position.PosType==OP_BUY)
        {   // Long position
         double stopLossPrice=High(_Symbol,_Period,1)-_Point*trailingStop;
         if(position.StopLossPrice<stopLossPrice-pipsValue)
           {
            if(stopLossPrice<tick.bid)
              {
               if(stopLossPrice>tick.bid-_Point*stopLevel)
                  stopLossPrice=tick.bid-_Point*stopLevel;

               if(WriteLogFile)
                  logger.WriteLogRequest("SetTrailingStopBarMode",
                                         "StopLoss="+DoubleToString(stopLossPrice,_Digits));

               ModifyPosition(stopLossPrice,position.TakeProfitPrice);

               Print("Trailing Stop (",trailingStop,") moved to: ",
                     DoubleToString(stopLossPrice,_Digits),", Bid=",tick.bid);
              }
            else
              {
               if(WriteLogFile)
                  logger.WriteLogRequest("SetTrailingStopBarMode",
                                         "StopLoss="+DoubleToString(stopLossPrice,_Digits));

               bool isSucceed=CloseCurrentPosition()==0;

               int lastErrorOrdClose=GetLastError();
               lastErrorOrdClose=(lastErrorOrdClose>0) ? lastErrorOrdClose : lastError;
              }
           }
        }
      else if(position.PosType==OP_SELL)
        {   // Short position
         double stopLossPrice=Low(_Symbol,_Period,1)+_Point*trailingStop;
         if(position.StopLossPrice>stopLossPrice+pipsValue)
           {
            if(stopLossPrice>tick.ask)
              {
               if(stopLossPrice<tick.ask+_Point*stopLevel)
                  stopLossPrice=tick.ask+_Point*stopLevel;

               if(WriteLogFile)
                  logger.WriteLogRequest("SetTrailingStopBarMode",
                                         "StopLoss="+DoubleToString(stopLossPrice,_Digits));

               ModifyPosition(stopLossPrice,position.TakeProfitPrice);

               Print("Trailing Stop (",trailingStop,") moved to: ",
                     DoubleToString(stopLossPrice,_Digits),", Ask=",tick.ask);
              }
            else
              {
               if(WriteLogFile)
                  logger.WriteLogRequest("SetTrailingStopBarMode",
                                         "StopLoss="+DoubleToString(stopLossPrice,_Digits));

               bool isSucceed=CloseCurrentPosition()==0;

               int lastErrorOrdClose=GetLastError();
               lastErrorOrdClose=(lastErrorOrdClose>0) ? lastErrorOrdClose : lastError;
              }
           }
        }
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   void ActionTrade::SetTrailingStopTickMode()
     {
      MqlTick tick;
      SymbolInfoTick(_Symbol,tick);

      if(position.PosType==OP_BUY)
        {   // Long position
         if(tick.bid>=position.OpenPrice+trailingStop*_Point)
           {
            if(position.StopLossPrice<tick.bid -(trailingStop+TrailingStopMovingStep)*_Point)
              {
               double stopLossPrice=tick.bid-trailingStop*_Point;
               if(WriteLogFile)
                  logger.WriteLogRequest("SetTrailingStopTickMode","StopLoss="+
                                         DoubleToString(stopLossPrice,_Digits));

               ModifyPosition(stopLossPrice,position.TakeProfitPrice);

               Print("Trailing Stop (",trailingStop,") moved to: ",
                     DoubleToString(stopLossPrice,_Digits),", Bid=",tick.bid);
              }
           }
        }
      else if(position.PosType==OP_SELL)
        {   // Short position
         if(position.OpenPrice-tick.ask>=_Point*trailingStop)
           {
            if(position.StopLossPrice>tick.ask+_Point *(trailingStop+TrailingStopMovingStep))
              {
               double stopLossPrice=tick.ask+trailingStop*_Point;
               if(WriteLogFile)
                  logger.WriteLogRequest("SetTrailingStopTickMode",
                                         "StopLoss="+DoubleToString(stopLossPrice,_Digits));

               ModifyPosition(stopLossPrice,position.TakeProfitPrice);

               Print("Trailing Stop (",trailingStop,") moved to: ",
                     DoubleToString(stopLossPrice,_Digits),", Ask=",tick.ask);
              }
           }
        }
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   void ActionTrade::DetectPositionClosing()
     {
      double oldStopLoss   = position.StopLossPrice;
      double oldTakeProfit = position.TakeProfitPrice;
      double oldProfit     = position.Profit;
      int    oldType       = position.PosType;
      double oldLots       = position.Lots;

      SetAggregatePosition(position);

      if(oldType==OP_FLAT || position.PosType!=OP_FLAT)
         return;

      double closePrice     = (oldType == OP_BUY) ? dataMarket.Bid : dataMarket.Ask;
      string stopMessage    = "Position was closed";
      string closePriceText = DoubleToString(closePrice, _Digits);

      if(MathAbs(oldStopLoss-closePrice)<2*pipsValue)
         stopMessage="Activated StopLoss="+closePriceText;
      else if(MathAbs(oldTakeProfit-closePrice)<2*pipsValue)
         stopMessage="Activated TakeProfit="+closePriceText;

      consecutiveLosses=(oldProfit<0) ? (consecutiveLosses+1) : 0;

      string message=stopMessage+
                     ", ClosePrice=" +closePriceText+
                     ", ClosedLots= "+DoubleToString(oldLots,2)+
                     ", Profit="     +DoubleToString(oldProfit,2)+
                     ", ConsecutiveLosses="+IntegerToString(consecutiveLosses);

      if(WriteLogFile)
         logger.WriteNewLogLine(message);
      Print(message);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   bool ActionTrade::IsTradeContextFree()
     {
      if(MQL5InfoInteger(MQL5_TRADE_ALLOWED))
         return (true);

      uint startWait=GetTickCount();
      Print("Trade context is busy! Waiting...");

      while(true)
        {
         if(IsStopped())
            return (false);

         uint diff=GetTickCount()-startWait;
         if(diff>30*1000)
           {
            Print("The waiting limit exceeded!");
            return (false);
           }

         if(MQL5InfoInteger(MQL5_TRADE_ALLOWED))
            return (true);
         Sleep(100);
        }

      return (true);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   void ActionTrade::ActivateProtectionMinAccount()
     {
      if(position.Lots>epsilon)
         CloseCurrentPosition();

      string account = DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2);
      string message = "\n" + "The account equity (" + account +
                      ") dropped below the minimum allowed ("+
                      IntegerToString(ProtectionMinAccount)+").";
      Comment(message);
      Print(message);

      if(WriteLogFile)
         logger.WriteLogLine(message);

      Sleep(20*1000);
      CloseExpert();
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   void ActionTrade::CloseExpert(void)
     {
      ExpertRemove();
      OnDeinit(0);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
	ENUM_ORDER_TYPE_FILLING ActionTrade::GetOrderFillingType()
	 {
	  const int oftIndex=(int) SymbolInfoInteger(_Symbol,SYMBOL_FILLING_MODE);
	  const ENUM_ORDER_TYPE_FILLING fillType=(ENUM_ORDER_TYPE_FILLING)(oftIndex>0 ? oftIndex-1 : oftIndex);

      return (fillType);
	 }
//+------------------------------------------------------------------+
