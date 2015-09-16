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

#include <Forexsb.com\StrategyManager.mqh>
#include <Forexsb.com\DataMarket.mqh>
#include <Forexsb.com\DataSet.mqh>
#include <Forexsb.com\Strategy.mqh>
#include <Forexsb.com\Helpers.mqh>
#include <Forexsb.com\Enumerations.mqh>
#include <Forexsb.com\IndicatorSlot.mqh>
#include <Forexsb.com\Logger.mqh>
#include <Forexsb.com\MQ5Conv.mqh>

//## Import Start

#define TRADE_RETRY_COUNT 4
#define TRADE_RETRY_WAIT  100
#define OP_FLAT          -1

const double Epsilon=0.000001;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ActionTrade5
  {
   // Fields
   Strategy         *m_Strategy;
   DataSet          *m_DataSet[];
   DataMarket       *m_DataMarket;
   Logger           *m_Logger;

   // Aggregate position
   int               m_PositionTicket;
   int               m_PositionType;
   datetime          m_PositionTime;
   double            m_PositionLots;
   double            m_PositionOpenPrice;
   double            m_PositionStopLoss;
   double            m_PositionTakeProfit;
   double            m_PositionProfit;
   double            m_PositionCommission;
   string            m_PositionComment;
   int               m_ConsecutiveLosses;

   // Properties
   int               m_LastError;
   double            m_PipsValue;
   int               m_PipsPoint;
   int               m_StopLevel;
   datetime          m_BarTime;
   datetime          m_TickTime;
   datetime          m_BarHighTime;
   datetime          m_BarLowTime;
   double            m_CurrentBarHigh;
   double            m_CurrentBarLow;
   int               m_TrailingStop;
   TrailingStopMode  m_TrailingMode;
   int               m_BreakEven;
   int               m_NBarExit;
   int               m_Digits;

   StrategyPriceType m_OpenStrPriceType;
   StrategyPriceType m_CloseStrPriceType;

   ExecutionTime     m_OpenTimeExec;
   ExecutionTime     m_CloseTimeExec;
   bool              m_UseLogicalGroups;
   DictStringBool   *m_GroupsAllowLong;
   DictStringBool   *m_GroupsAllowShort;
   ListString       *m_OpeningLogicGroups;
   ListString       *m_ClosingLogicGroups;
   bool              m_IsEnteredLong;
   bool              m_IsEnteredShort;
   datetime          m_TimeLastEntryBar;
   datetime          m_BarOpenTimeForLastCloseTick;
   datetime          m_BarOpenTimeForLastCloseEvent;

   string            m_DynamicInfoParams[];
   string            m_DynamicInfoValues[];
   string            m_DynamicInfoAccount[3];

   // Methods
   bool              CheckEnvironment(int minimumBars);
   bool              CheckChartBarsCount(int minimumBars);
   int               FindBarsCountNeeded(void);
   int               SetAggregatePosition(void);
   string            AggregatePositionToString(void);
   void              AggregatePositionToNormalString(string &posinfo[]);
   void              UpdateDataSet(DataSet *dataSet,int maxBars);
   void              UpdateDataMarket(DataMarket *dataMarket);
   bool              IsTradeContextFree(void);

   // Trading methods
   bool              ManageOrderSend(int type,double lots,double stoploss,double takeprofit);
   bool              CloseCurrentPosition();
   bool              ModifyPosition(double stoploss,double takeprofit);
   double            GetTakeProfitPrice(int type,double takeprofit);
   double            GetStopLossPrice(int type,double stoploss);
   double            CorrectTakeProfitPrice(int type,double takeprofit);
   double            CorrectStopLossPrice(int type,double stoploss);
   double            NormalizeEntrySize(double size);
   double            NormalizeEntryPrice(double price);
   void              SetMaxStopLoss(void);
   void              SetBreakEvenStop(void);
   void              SetTrailingStop(bool isNewBar);
   void              SetTrailingStopBarMode(void);
   void              SetTrailingStopTickMode(void);
   void              DetectSLTPActivation(void);

   // Strategy Trader methods
   TickType          GetTickType(DataSet *dataSet,bool isNewBar);
   void              CalculateTrade(TickType ticktype);
   PosDirection      GetNewPositionDirection(OrderDirection ordDir,double ordLots,PosDirection posDir,double posLots);
   TradeDirection    AnalyzeEntryPrice(void);
   TradeDirection    AnalyzeEntryDirection(void);
   void              AnalyzeEntryLogicConditions(int bar,string group,double buyPrice,double sellPrice,bool &canOpenLong,bool &canOpenShort);
   double            AnalyzeEntrySize(OrderDirection ordDir,PosDirection &newPosDir);
   TradeDirection    AnalyzeExitPrice(void);
   double            TradingSize(double size);
   double            AccountPercentStopPoints(double percent,double lots);
   TradeDirection    AnalyzeExitDirection(void);
   TradeDirection    ReduceDirectionStatus(TradeDirection baseDirection,TradeDirection direction);
   TradeDirection    IncreaseDirectionStatus(TradeDirection baseDirection,TradeDirection direction);
   TradeDirection    GetClosingDirection(TradeDirection baseDirection,IndComponentType compDataType);
   double            GetStopLossPoints(double lots);
   double            GetTakeProfitPoints(void);
   void              DoEntryTrade(TradeDirection tradeDir);
   bool              DoExitTrade(void);
   bool              IsWrongStopsExecution(void);
   void              ResendWrongStops(void);
   void              InitTrade(void);

public:
   // Constructors
                     ActionTrade5(void);
                    ~ActionTrade5(void);

   // Properties
   double            Entry_Amount;
   double            Maximum_Amount;
   double            Adding_Amount;
   double            Reducing_Amount;

   string            Strategy_File_Name;
   string            Strategy_XML;
   int               Max_Data_Bars;
   int               Protection_Min_Account;
   int               Protection_Max_StopLoss;
   bool              Separate_SL_TP;
   bool              Write_Log_File;
   bool              FIFO_order;
   int               TrailingStop_Moving_Step;
   int               MaxLogLinesInFile;
   int               Bar_Close_Advance;

   // Methods
   int               OnInit(void);
   void              OnTick(void);
   void              OnTrade(void);
   void              OnDeinit(const int reason);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ActionTrade5::ActionTrade5(void)
{
   m_Logger = new Logger();
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ActionTrade5::~ActionTrade5(void)
{
   if(CheckPointer(m_Logger)==POINTER_DYNAMIC)
      delete m_Logger;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ActionTrade5::OnInit()
  {
   m_DataMarket         = new DataMarket();
   m_GroupsAllowLong    = new DictStringBool();
   m_GroupsAllowShort   = new DictStringBool();
   m_OpeningLogicGroups = new ListString();
   m_ClosingLogicGroups = new ListString();

   m_BarHighTime    = 0;
   m_BarLowTime     = 0;
   m_CurrentBarHigh = 0;
   m_CurrentBarLow  = 1000000;
   m_Digits         = Digits();

   DataPeriod dataPeriod=(DataPeriod)Period();

   string message=StringFormat("%s loaded.",MQLInfoString(MQL_PROGRAM_NAME));
   Comment(message);
   Print(message);

   if(Write_Log_File)
     {
      m_Logger.CreateLogFile(m_Logger.GetLogFileName(_Symbol,_Period,5));
      m_Logger.WriteLogLine(message);
      m_Logger.WriteLogLine("Entry Amount: "   +DoubleToString(Entry_Amount,2)  +", "+
                            "Maximum Amount: " +DoubleToString(Maximum_Amount,2)+", "+
                            "Adding Amount: "  +DoubleToString(Adding_Amount,2) +", "+
                            "Reducing Amount: "+DoubleToString(Reducing_Amount,2));
      m_Logger.WriteLogLine("Protection Min Account: " +IntegerToString(Protection_Min_Account)+", "+
                            "Protection Max StopLoss: "+IntegerToString(Protection_Max_StopLoss));
      m_Logger.WriteLogLine("Bar Close Advance: "+IntegerToString(Bar_Close_Advance));
      m_Logger.FlushLogFile();
     }

   if(_Digits==2 || _Digits==3)
      m_PipsValue=0.01;
   else if(_Digits==4 || _Digits==5)
      m_PipsValue=0.0001;
   else
      m_PipsValue=_Digits;

   if(_Digits==3 || _Digits==5)
      m_PipsPoint=10;
   else
      m_PipsPoint=1;

   m_StopLevel=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL)+m_PipsPoint;
   if(m_StopLevel<3*m_PipsPoint)
      m_StopLevel=3*m_PipsPoint;

   if(Protection_Max_StopLoss>0 && Protection_Max_StopLoss<m_StopLevel)
      Protection_Max_StopLoss=m_StopLevel;

   if(TrailingStop_Moving_Step<m_PipsPoint)
      TrailingStop_Moving_Step=m_PipsPoint;

   string xml=(Strategy_XML=="##STRATEGY##")
              ? LoadStringFromFile(Strategy_File_Name)
              : Strategy_XML;

   StrategyManager *strategyManager=new StrategyManager();

// Strategy initialization
   m_Strategy=strategyManager.ParseXmlStrategy(xml);
   m_Strategy.SetSymbol(_Symbol);
   m_Strategy.SetPeriod(dataPeriod);
   m_Strategy.EntryLots    = Entry_Amount;
   m_Strategy.MaxOpenLots  = Maximum_Amount;
   m_Strategy.AddingLots   = Adding_Amount;
   m_Strategy.ReducingLots = Reducing_Amount;
   m_Strategy.SetIsTester(MQLInfoInteger(MQL_TESTER));

   delete strategyManager;

// Checks the requirements.
   bool isEnvironmentGood=CheckEnvironment(m_Strategy.MinBarsRequired);
   if(!isEnvironmentGood)
     {   // There is a non fulfilled condition, therefore we must exit.
      Sleep(20*1000);
      ExpertRemove();
      return (INIT_FAILED);
     }

// Market initialization
   string charts[];
   m_Strategy.GetRequiredCharts(charts);

   string chartsNote = "Loading data: ";
   for(int i=0;i<ArraySize(charts);i++)
      chartsNote += charts[i] + ", ";
   chartsNote += "Minumum bars: " + IntegerToString(m_Strategy.MinBarsRequired) + "...";
   Comment(chartsNote);
   Print(chartsNote);

// Initial data loading
   ArrayResize(m_DataSet,ArraySize(charts));
   for(int i=0; i<ArraySize(charts); i++)
      m_DataSet[i]=new DataSet(charts[i]);

   SetAggregatePosition();

// Checks the necessary bars.
   Max_Data_Bars=FindBarsCountNeeded();

// Initial strategy calculation
   for(int i=0; i<ArraySize(m_DataSet); i++)
      UpdateDataSet(m_DataSet[i],Max_Data_Bars);
   m_Strategy.CalculateStrategy(m_DataSet);

   InitTrade();

   m_Strategy.DynamicInfoInitArrays(m_DynamicInfoParams,m_DynamicInfoValues);
   int paramsX=0;
   int valuesX=140;
   int locationY=40;
   int count= ArraySize(m_DynamicInfoParams);
   for(int i=0;i<count;i++)
     {
      string namep = "Lbl_prm_"+IntegerToString(i);
      string namev = "Lbl_val_"+IntegerToString(i);
      string param = m_DynamicInfoParams[i] == "" ? "." : m_DynamicInfoParams[i];
      LabelCreate(0,namep,0,paramsX,locationY,CORNER_LEFT_UPPER,param);
      LabelCreate(0,namev,0,valuesX,locationY,CORNER_LEFT_UPPER,".");
      locationY+=12;
     }

   LabelCreate(0,"Lbl_pos_0",0,350,0,CORNER_LEFT_UPPER,".","Ariel",10);
   LabelCreate(0,"Lbl_pos_1",0,350,15,CORNER_LEFT_UPPER,".","Ariel",10);
   LabelCreate(0,"Lbl_pos_2",0,350,29,CORNER_LEFT_UPPER,".","Ariel",10);

   Comment("");

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ActionTrade5::OnTick()
  {
   for(int i=0; i<ArraySize(m_DataSet); i++)
      UpdateDataSet(m_DataSet[i],Max_Data_Bars);
   UpdateDataMarket(m_DataMarket);

   datetime barTime=Time(_Symbol,_Period,0);
   bool isNewBar=(m_BarTime<barTime&&m_DataMarket.Volume<5);
   m_BarTime=barTime;
   m_TickTime=m_DataMarket.TickServerTime;
   m_LastError=0;

// Checks if minimum account was reached.
   if(Protection_Min_Account>0 && AccountInfoDouble(ACCOUNT_EQUITY)<Protection_Min_Account)
     {
      if(m_PositionLots>Epsilon)
         CloseCurrentPosition();
      return;
     }

// Checks and sets Max SL protection.
   if(Protection_Max_StopLoss>0)
      SetMaxStopLoss();

// Checks if position was closed.
   DetectSLTPActivation();

   if(m_BreakEven>0)
      SetBreakEvenStop();

   if(m_TrailingStop>0)
      SetTrailingStop(isNewBar);

   SetAggregatePosition();

   if(isNewBar && Write_Log_File)
      m_Logger.WriteNewLogLine(AggregatePositionToString());

   if(m_DataSet[0].Bars >= m_Strategy.MinBarsRequired)
   {
      m_Strategy.CalculateStrategy(m_DataSet);
      TickType tickType=GetTickType(m_DataSet[0],isNewBar);
      CalculateTrade(tickType);
   }

// Sends OrderModify on SL/TP errors
   if(IsWrongStopsExecution())
      ResendWrongStops();

   AggregatePositionToNormalString(m_DynamicInfoAccount);
   for(int i=0;i<3;i++)
     {
      string lblName="Lbl_pos_"+IntegerToString(i);
      string val=m_DynamicInfoAccount[i]=="" ? "." : m_DynamicInfoAccount[i];
      LabelTextChange(0,lblName,val);
     }

   m_Strategy.DynamicInfoSetValues(m_DynamicInfoValues);
   int count= ArraySize(m_DynamicInfoValues);
   for(int i=0;i<count;i++)
     {
      string namev="Lbl_val_"+IntegerToString(i);
      string val=m_DynamicInfoValues[i]=="" ? "." : m_DynamicInfoValues[i];
      LabelTextChange(0,namev,val);
     }
   ChartRedraw();

   if(Write_Log_File)
     {
      if(m_Logger.IsLogLinesLimitReached(MaxLogLinesInFile))
        {
         m_Logger.CloseLogFile();
         m_Logger.CreateLogFile(m_Logger.GetLogFileName(_Symbol,_Period,5));
        }
      m_Logger.FlushLogFile();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ActionTrade5::OnTrade(void)
{
   datetime now = TimeCurrent();
   HistorySelect(now-30*24*60*60, now);
   int total = (int)HistoryDealsTotal();
   ulong ticket=0;
   int maxLosses=0;
   for(int i=total;i>=0;i--)
   {
      if((ticket=HistoryDealGetTicket(i))>0)
      {
         double price =HistoryDealGetDouble(ticket, DEAL_PRICE);
         long   time  =HistoryDealGetInteger(ticket,DEAL_TIME);
         string symbol=HistoryDealGetString(ticket, DEAL_SYMBOL);
         double profit=HistoryDealGetDouble(ticket, DEAL_PROFIT);
         if(price>Epsilon && time>0 && symbol==_Symbol)
         {
            if(profit<-Epsilon)
               maxLosses++;
            if(profit>Epsilon)
            {
               m_ConsecutiveLosses = maxLosses;
               break;
            }
         }
      }
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ActionTrade5::OnDeinit(const int reason)
  {
   if(Write_Log_File)
      m_Logger.CloseLogFile();

   if(CheckPointer(m_Strategy)==POINTER_DYNAMIC)
      delete m_Strategy;

   for(int i=0; i<ArraySize(m_DataSet); i++)
      if(CheckPointer(m_DataSet[i])==POINTER_DYNAMIC)
         delete m_DataSet[i];
   ArrayFree(m_DataSet);

   if(CheckPointer(m_DataMarket)==POINTER_DYNAMIC)
      delete m_DataMarket;

   delete m_GroupsAllowLong;
   delete m_GroupsAllowShort;
   delete m_OpeningLogicGroups;
   delete m_ClosingLogicGroups;

   int count= ArraySize(m_DynamicInfoParams);
   for(int i=0;i<count;i++)
     {
      string namev = "Lbl_val_"+IntegerToString(i);
      string namep = "Lbl_prm_"+IntegerToString(i);
      LabelDelete(0,namev);
      LabelDelete(0,namep);
     }

   for(int i=0;i<3;i++)
     {
      string lblName="Lbl_pos_"+IntegerToString(i);
      LabelDelete(0,lblName);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ActionTrade5::CheckEnvironment(int minimumBars)
  {
// Checks the count of bars available.
   if(!CheckChartBarsCount(minimumBars))
      return (false);

   if(MQLInfoInteger(MQL_TESTER))
     {
      SetAggregatePosition();
      return (true);
     }

// Checks if you are logged in.
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

// Checks the open positions.
   if(SetAggregatePosition()==-1)
      return (false);  // Some error with the current positions.

// Everything looks OK.
   return (true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ActionTrade5::CheckChartBarsCount(int barsNecessary)
  {
   int bars=Bars(_Symbol,_Period);
   bool isEnoughBars=bars>=barsNecessary;
   if(isEnoughBars) return(true);

   string message="\n Cannot load enough bars! The expert needs minimum "+
                     IntegerToString(barsNecessary)+" bars."+
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
int ActionTrade5::FindBarsCountNeeded()
  {
   int barStep=50;
   int minBars=50;
   int maxBars=3000;

   // Initial state
   int initialBars=MathMax(m_Strategy.MinBarsRequired,minBars);
   for(int i=0; i<ArraySize(m_DataSet); i++)
      UpdateDataSet(m_DataSet[i],initialBars);
   UpdateDataMarket(m_DataMarket);
   double initialBid=m_DataMarket.Bid;
   m_Strategy.CalculateStrategy(m_DataSet);
   string dynamicInfo=m_Strategy.DynamicInfoText();
   int necessaryBars=initialBars;
   int roundedInitialBars=(int)(barStep*MathCeil(((double)initialBars)/barStep));
   int firstTestBars=roundedInitialBars>=initialBars+barStep/2
      ? roundedInitialBars
      : roundedInitialBars+barStep;

   for(int bars=firstTestBars;bars<=maxBars;bars+=barStep)
     {
      for(int i=0; i<ArraySize(m_DataSet); i++)
         UpdateDataSet(m_DataSet[i],bars);
      UpdateDataMarket(m_DataMarket);
      m_Strategy.CalculateStrategy(m_DataSet);
      string currentInfo=m_Strategy.DynamicInfoText();

      if(dynamicInfo==currentInfo)
         break;

      dynamicInfo=currentInfo;
      necessaryBars=bars;

      if(MathAbs(initialBid-m_DataMarket.Bid)>Epsilon)
      {  // Reset the test if new tick has arrived.
         for(int i=0; i<ArraySize(m_DataSet); i++)
            UpdateDataSet(m_DataSet[i],initialBars);
         UpdateDataMarket(m_DataMarket);
         initialBid=m_DataMarket.Bid;
         m_Strategy.CalculateStrategy(m_DataSet);
         dynamicInfo=m_Strategy.DynamicInfoText();
         bars=firstTestBars-barStep;
      }
     }

   string barsMessage = "The expert uses "+IntegerToString(necessaryBars)+" bars.";
   if(Write_Log_File)
    {
      m_Logger.WriteLogLine(barsMessage);
      string timeLastBar=TimeToString(m_DataMarket.TickServerTime,TIME_DATE|TIME_MINUTES);
      m_Logger.WriteLogLine("Indicator values: "+m_DataSet[0].Chart+", Time last bar: "+timeLastBar);
      m_Logger.WriteLogLine(dynamicInfo);
    }
   Print(barsMessage);

   return (necessaryBars);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ActionTrade5::UpdateDataSet(DataSet *dataSet,int maxBars)
  {
   string  symbol = dataSet.Symbol;
   int     bars   = MathMin(Bars(symbol, DataPeriodToTimeFrame(dataSet.Period)), maxBars);
   MqlTick tick;
   SymbolInfoTick(symbol,tick);

   dataSet.LotSize        = (int) SymbolInfoDouble(symbol,SYMBOL_TRADE_CONTRACT_SIZE);
   dataSet.Digits         = (int) SymbolInfoInteger(symbol,SYMBOL_DIGITS);
   dataSet.StopLevel      = (int) SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL);
   dataSet.Point          = SymbolInfoDouble(symbol,SYMBOL_POINT);
   dataSet.TickValue      = SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE);
   dataSet.MinLot         = SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
   dataSet.MaxLot         = SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX);
   dataSet.LotStep        = SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP);
   dataSet.MarginRequired = SymbolInfoDouble(symbol,SYMBOL_MARGIN_INITIAL);
   dataSet.Bars           = bars;
   dataSet.ServerTime     = tick.time;
   dataSet.Bid            = tick.bid;
   dataSet.Ask            = tick.ask;
   dataSet.Spread         = (tick.ask-tick.bid)/dataSet.Point;

   if(dataSet.MarginRequired < Epsilon)
      bool ok = OrderCalcMargin(ORDER_TYPE_BUY, symbol, 1, tick.ask, dataSet.MarginRequired);
   if(dataSet.MarginRequired < Epsilon)
      dataSet.MarginRequired = tick.bid*dataSet.LotSize/100;

   dataSet.SetPrecision();

   MqlRates rates[];
   ArraySetAsSeries(rates,false);
   int copied=CopyRates(symbol,DataPeriodToTimeFrame(dataSet.Period),0,bars,rates);

   ArrayResize(dataSet.Time,   bars);
   ArrayResize(dataSet.Open,   bars);
   ArrayResize(dataSet.High,   bars);
   ArrayResize(dataSet.Low,    bars);
   ArrayResize(dataSet.Close,  bars);
   ArrayResize(dataSet.Volume, bars);

   for(int i=0; i<bars; i++)
     {
      dataSet.Time[i]   = rates[i].time;
      dataSet.Open[i]   = rates[i].open;
      dataSet.High[i]   = rates[i].high;
      dataSet.Low[i]    = rates[i].low;
      dataSet.Close[i]  = rates[i].close;
      dataSet.Volume[i] = (int) rates[i].tick_volume;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ActionTrade5::UpdateDataMarket(DataMarket *dataMarket)
  {
   MqlTick tick;
   SymbolInfoTick(_Symbol,tick);

   dataMarket.TickLocalTime       = TimeLocal();
   dataMarket.TickServerTime      = tick.time;

   dataMarket.PositionTicket      = m_PositionTicket;
   dataMarket.PositionLots        = m_PositionLots;
   dataMarket.PositionOpenPrice   = m_PositionOpenPrice;
   dataMarket.PositionOpenTime    = m_PositionTime;
   dataMarket.PositionStopLoss    = m_PositionStopLoss;
   dataMarket.PositionTakeProfit  = m_PositionTakeProfit;
   dataMarket.PositionProfit      = m_PositionProfit;
   dataMarket.PositionComment     = m_PositionComment;
   dataMarket.PositionDirection   = m_PositionType==OP_FLAT
                                       ? PosDirection_None
                                       : m_PositionType==OP_BUY
                                          ? PosDirection_Long
                                          : PosDirection_Short;

   dataMarket.AccountBalance      = AccountInfoDouble(ACCOUNT_BALANCE);
   dataMarket.AccountEquity       = AccountInfoDouble(ACCOUNT_EQUITY);
   dataMarket.AccountFreeMargin   = AccountInfoDouble(ACCOUNT_FREEMARGIN);
   dataMarket.ConsecutiveLosses   = m_ConsecutiveLosses;
   dataMarket.IsNewBid            = MathAbs(tick.bid-dataMarket.Bid)>Epsilon;
   dataMarket.OldAsk              = dataMarket.Ask;
   dataMarket.OldBid              = dataMarket.Bid;
   dataMarket.OldClose            = dataMarket.Close;
   dataMarket.Ask                 = tick.ask;
   dataMarket.Bid                 = tick.bid;
   dataMarket.Close               = Close(_Symbol,_Period,0);
   dataMarket.Volume              = Volume(_Symbol,_Period,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ActionTrade5::SetAggregatePosition()
  {
   m_PositionTicket     = 0;
   m_PositionType       = OP_FLAT;
   m_PositionTime       = D'2050.01.01 00:00';
   m_PositionLots       = 0;
   m_PositionOpenPrice  = 0;
   m_PositionStopLoss   = 0;
   m_PositionTakeProfit = 0;
   m_PositionProfit     = 0;
   m_PositionCommission = 0;
   m_PositionComment    = "";

   if(!PositionSelect(_Symbol))
      return (0);

   m_PositionTicket      = (int) PositionGetInteger(POSITION_IDENTIFIER);
   m_PositionType        = (int) PositionGetInteger(POSITION_TYPE);
   m_PositionTime        = (datetime) MathMax(PositionGetInteger(POSITION_TIME),
                              PositionGetInteger(POSITION_TIME_UPDATE));
   m_PositionOpenPrice   = NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN),_Digits);
   m_PositionLots        = NormalizeDouble(PositionGetDouble(POSITION_VOLUME),2);
   m_PositionProfit      = NormalizeDouble(PositionGetDouble(POSITION_PROFIT)+
                              PositionGetDouble(POSITION_COMMISSION),2);
   m_PositionCommission  = NormalizeDouble(PositionGetDouble(POSITION_COMMISSION),2);
   m_PositionStopLoss    = NormalizeDouble(PositionGetDouble(POSITION_SL),_Digits);
   m_PositionTakeProfit  = NormalizeDouble(PositionGetDouble(POSITION_TP),_Digits);
   m_PositionComment     = PositionGetString(POSITION_COMMENT);

   return (1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ActionTrade5::AggregatePositionToString()
  {
   if(m_PositionType==OP_FLAT)
      return "Position: Flat";

   string text="Position: "+
               "Ticket="+IntegerToString(m_PositionTicket)+
               ", Time="+TimeToString(m_PositionTime,TIME_SECONDS)+
               ", Type="+(m_PositionType==OP_BUY ? "Long" : "Short")+
               ", Lots="+DoubleToString(m_PositionLots,2)+
               ", Price="+DoubleToString(m_PositionOpenPrice,_Digits)+
               ", StopLoss="+DoubleToString(m_PositionStopLoss,_Digits)+
               ", TakeProfit="+DoubleToString(m_PositionTakeProfit,_Digits)+
               ", Commission="+DoubleToString(m_PositionCommission,2)+
               ", Profit="+DoubleToString(m_PositionProfit,2);

   if(m_PositionComment!="")
      text=text+", \""+m_PositionComment+"\"";

   return (text);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ActionTrade5::AggregatePositionToNormalString(string &posinfo[])
  {
   posinfo[0]=StringFormat("%s Balance: %.2f, Equity: %.2f",
                           TimeToString(m_TickTime,TIME_SECONDS),
                           AccountInfoDouble(ACCOUNT_BALANCE),
                           AccountInfoDouble(ACCOUNT_EQUITY));
   if(m_PositionType==OP_FLAT)
     {
      posinfo[1] = "Position: Flat";
      posinfo[2] = "";
     }
   else
     {
      string type=m_PositionType==OP_BUY ? "Long" : "Short";
      posinfo[1]=StringFormat("Position: %s %.2f at %s, Profit %.2f",
                              type,m_PositionLots,
                              DoubleToString(m_PositionOpenPrice,_Digits),
                              m_PositionProfit);
      posinfo[2]=StringFormat("Stop Loss: %s, Take Profit: %s",
                              DoubleToString(m_PositionStopLoss,_Digits),
                              DoubleToString(m_PositionTakeProfit,_Digits));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ActionTrade5::ManageOrderSend(int type,double lots,double stoploss,double takeprofit)
  {
   for(int attempt=0; attempt<TRADE_RETRY_COUNT; attempt++)
     {
      if(IsTradeContextFree())
        {
         ResetLastError();

         MqlTick tick;
         SymbolInfoTick(_Symbol,tick);

         double orderLots       = NormalizeEntrySize(lots);
         double stopLossPrice   = GetStopLossPrice(type,stoploss);
         double takeProfitPrice = GetTakeProfitPrice(type,takeprofit);

         MqlTradeRequest     request;
         MqlTradeResult      result;
         MqlTradeCheckResult check;
         ZeroMemory(request);
         ZeroMemory(result);
         ZeroMemory(check);

         request.action       = TRADE_ACTION_DEAL;
         request.symbol       = _Symbol;
         request.volume       = orderLots;
         request.type         = (type==OP_BUY)?ORDER_TYPE_BUY:ORDER_TYPE_SELL;
         request.type_filling = ORDER_FILLING_FOK;
         request.deviation    = 10;
         request.sl           = stopLossPrice;
         request.tp           = takeProfitPrice;

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

         SetAggregatePosition();

         m_LastError=GetLastError();
         if(Write_Log_File)
            m_Logger.WriteLogLine(__FUNCTION__+
                         ": "+_Symbol+
                         ", Type="       +(type==OP_BUY ? "Long" : "Short")+
                         ", Lots="       +DoubleToString(orderLots,2)+
                         ", Price="      +DoubleToString(result.price,_Digits)+
                         ", StopLoss="   +DoubleToString(stopLossPrice,_Digits)+
                         ", TakeProfit=" +DoubleToString(takeProfitPrice,_Digits)+
                         ", RetCode="    +retcode+
                         ", LastError="  +IntegerToString(m_LastError));

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
bool ActionTrade5::CloseCurrentPosition()
  {
   if(m_PositionType==OP_FLAT) return (true);
   int    type=m_PositionType==OP_BUY?OP_SELL:OP_BUY;
   double lots=m_PositionLots;
   bool   orderResponse=ManageOrderSend(type,lots,0,0);
   return (orderResponse);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ActionTrade5::ModifyPosition(double stoploss,double takeprofit)
  {
   for(int attempt=0; attempt<TRADE_RETRY_COUNT; attempt++)
     {
      if(IsTradeContextFree())
        {
         if(m_PositionType==OP_FLAT) return(false);
         double stopLossPrice   = CorrectStopLossPrice(m_PositionType, stoploss);
         double takeProfitPrice = CorrectTakeProfitPrice(m_PositionType, takeprofit);

         MqlTradeRequest     request;
         MqlTradeResult      result;
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
            Print("Error: ","ModifyPosition","(): OrderCheck(): ",retcode);

         bool isOrderSend=false;
         if(isOrderCheck)
           {
            isOrderSend=OrderSend(request,result);
            retcode=ResultRetcodeDescription(result.retcode);

            if(!isOrderSend)
               Print("Error: ","ModifyPosition","(): OrderSend(): ",retcode);
           }

         bool isExecuted=isOrderCheck && isOrderSend && result.retcode==TRADE_RETCODE_DONE;

         SetAggregatePosition();

         m_LastError=GetLastError();
         if(Write_Log_File)
            m_Logger.WriteLogLine("ModifyPosition"+
                         ": "            +_Symbol+
                         ", StopLoss="   +DoubleToString(stopLossPrice,_Digits)+
                         ", TakeProfit=" +DoubleToString(takeProfitPrice,_Digits)+
                         ", RetCode="    +retcode+
                         ", LastError="  +IntegerToString(m_LastError));

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
double ActionTrade5::GetTakeProfitPrice(int type,double takeprofit)
  {
   if(takeprofit<Epsilon)
      return (0);

   if(takeprofit<m_StopLevel)
      takeprofit=m_StopLevel;

   MqlTick tick;
   SymbolInfoTick(_Symbol,tick);

   double takeProfitPrice=(type==OP_BUY)
      ? tick.bid+takeprofit*_Point
      : tick.ask-takeprofit*_Point;

   return (NormalizeEntryPrice(takeProfitPrice));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ActionTrade5::GetStopLossPrice(int type,double stoploss)
  {
   if(stoploss<Epsilon)
      return (0);

   if(stoploss<m_StopLevel)
      stoploss=m_StopLevel;

   MqlTick tick;
   SymbolInfoTick(_Symbol,tick);

   double stopLossPrice=(type==OP_BUY)
      ? tick.bid-stoploss*_Point
      : tick.ask+stoploss*_Point;

   return (NormalizeEntryPrice(stopLossPrice));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ActionTrade5::CorrectTakeProfitPrice(int type,double takeProfitPrice)
  {
   if(takeProfitPrice<Epsilon)
      return (0);

   MqlTick tick;
   SymbolInfoTick(_Symbol,tick);

   if(type==OP_BUY)
     {
      double minTPPrice=tick.bid+m_StopLevel*_Point;
      if(takeProfitPrice<minTPPrice)
         takeProfitPrice=minTPPrice;
     }
   else // if (type==OP_SELL)
     {
      double maxTPPrice=tick.ask-m_StopLevel*_Point;
      if(takeProfitPrice>maxTPPrice)
         takeProfitPrice=maxTPPrice;
     }

   return (NormalizeEntryPrice(takeProfitPrice));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ActionTrade5::CorrectStopLossPrice(int type,double stopLossPrice)
  {
   if(stopLossPrice<Epsilon)
      return (0);

   MqlTick tick;
   SymbolInfoTick(_Symbol,tick);

   if(type==OP_BUY)
     {
      double minSLPrice=tick.bid-m_StopLevel*_Point;
      if(stopLossPrice>minSLPrice)
         stopLossPrice=minSLPrice;
     }
   else // if(type==OP_SELL)
     {
      double maxSLPrice=tick.ask+m_StopLevel*_Point;
      if(stopLossPrice<maxSLPrice)
         stopLossPrice=maxSLPrice;
     }

   return (NormalizeEntryPrice(stopLossPrice));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ActionTrade5::NormalizeEntryPrice(double price)
{
   double tickSize=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   if(tickSize!=0)
      return (NormalizeDouble(MathRound(price/tickSize)*tickSize,_Digits));
   return (NormalizeDouble(price,_Digits));
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ActionTrade5::NormalizeEntrySize(double size)
  {
   double minlot  = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double maxlot  = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double lotstep = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);

   if(size<minlot-Epsilon)
      return (0);

   if(MathAbs(size-minlot)<Epsilon)
      return (minlot);

   int steps=(int) MathRound((size-minlot)/lotstep);
   size=minlot+steps*lotstep;

   if(size>=maxlot)
      size=maxlot;

   return (size);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ActionTrade5::SetMaxStopLoss()
  {
   if(m_PositionType==OP_FLAT || Protection_Max_StopLoss==0)
      return;

   double stopLossPrice=m_PositionStopLoss;
   int spread=(int)SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);
   int stopLoss=(int)MathRound(MathAbs(m_PositionOpenPrice-m_PositionStopLoss)/_Point);

   if(stopLossPrice<Epsilon || stopLoss>Protection_Max_StopLoss+spread)
     {
      stopLossPrice=(m_PositionType==OP_BUY)
         ? m_PositionOpenPrice-_Point*(Protection_Max_StopLoss+spread)
         : m_PositionOpenPrice+_Point*(Protection_Max_StopLoss+spread);

      if(Write_Log_File)
         m_Logger.WriteLogRequest("SetMaxStopLoss",
            "StopLossPrice="+DoubleToString(stopLossPrice,_Digits));

      bool result=ModifyPosition(stopLossPrice,m_PositionTakeProfit);

      if(result)
         Print("SetMaxStopLoss(",Protection_Max_StopLoss,") set StopLoss to ",
            DoubleToString(stopLossPrice,_Digits));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ActionTrade5::SetBreakEvenStop()
  {
   if(SetAggregatePosition()<=0)
      return;

   double breakeven=m_StopLevel;
   if(breakeven<m_BreakEven)
      breakeven=m_BreakEven;

   double breakprice=0; // Break Even price including commission.
   double commission=0; // Commission in points.
   if(m_PositionCommission!=0)
      commission=MathAbs(m_PositionCommission)/
          SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);

   MqlTick tick;
   SymbolInfoTick(_Symbol,tick);

   if(m_PositionType==OP_BUY)
     {
      breakprice=m_PositionOpenPrice+_Point*commission/m_PositionLots;
      if(tick.bid-breakprice>=_Point*breakeven)
        {
         if(m_PositionStopLoss<breakprice)
           {
            if(Write_Log_File)
               m_Logger.WriteLogRequest("SetBreakEvenStop",
                  "BreakPrice="+DoubleToString(breakprice,_Digits));

            ModifyPosition(breakprice,m_PositionTakeProfit);

            Print("SetBreakEvenStop(",m_BreakEven,") set StopLoss to ",
               DoubleToString(breakprice,_Digits),", Bid=",tick.bid);
           }
        }
     }
   else if(m_PositionType==OP_SELL)
     {
      breakprice=m_PositionOpenPrice-_Point*commission/m_PositionLots;
      if(breakprice-tick.ask>=_Point*breakeven)
        {
         if(m_PositionStopLoss==0||m_PositionStopLoss>breakprice)
           {
            if(Write_Log_File)
               m_Logger.WriteLogRequest("SetBreakEvenStop",
                  "BreakPrice="+DoubleToString(breakprice,_Digits));

            ModifyPosition(breakprice,m_PositionTakeProfit);

            Print("SetBreakEvenStop(",m_BreakEven,") set StopLoss to ",
               DoubleToString(breakprice,_Digits),", Ask=",tick.ask);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ActionTrade5::SetTrailingStop(bool isNewBar)
  {
   bool isCheckTS=true;

   if(isNewBar)
     {
      if(m_PositionType==OP_BUY && m_PositionTime>m_BarHighTime)
         isCheckTS=false;

      if(m_PositionType==OP_SELL && m_PositionTime>m_BarLowTime)
         isCheckTS=false;

      m_BarHighTime    = Time(_Symbol, _Period, 0);
      m_BarLowTime     = Time(_Symbol, _Period, 0);
      m_CurrentBarHigh = High(_Symbol, _Period, 0);
      m_CurrentBarLow  = Low(_Symbol, _Period, 0);
     }
   else
     {
      if(High(_Symbol,_Period,0)>m_CurrentBarHigh)
        {
         m_CurrentBarHigh = High(_Symbol, _Period, 0);
         m_BarHighTime    = Time(_Symbol, _Period, 0);
        }
      if(Low(_Symbol,_Period,0)<m_CurrentBarLow)
        {
         m_CurrentBarLow = Low(_Symbol, _Period, 0);
         m_BarLowTime    = Time(_Symbol, _Period, 0);
        }
     }

   if(SetAggregatePosition()<=0)
      return;

   if(m_TrailingMode==TrailingStopMode_Tick)
      SetTrailingStopTickMode();
   else if(m_TrailingMode==TrailingStopMode_Bar && isNewBar && isCheckTS)
      SetTrailingStopBarMode();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ActionTrade5::SetTrailingStopBarMode()
  {
   MqlTick tick;
   SymbolInfoTick(_Symbol,tick);

   if(m_PositionType==OP_BUY)
     {   // Long position
      double stopLossPrice=High(_Symbol,_Period,1)-_Point*m_TrailingStop;
      if(m_PositionStopLoss<stopLossPrice-m_PipsValue)
        {
         if(stopLossPrice<tick.bid)
           {
            if(stopLossPrice>tick.bid-_Point*m_StopLevel)
               stopLossPrice=tick.bid-_Point*m_StopLevel;

            if(Write_Log_File)
               m_Logger.WriteLogRequest("SetTrailingStopBarMode",
                  "StopLoss="+DoubleToString(stopLossPrice,_Digits));

            ModifyPosition(stopLossPrice,m_PositionTakeProfit);

            Print("Trailing Stop (",m_TrailingStop,") moved to: ",
               DoubleToString(stopLossPrice,_Digits),", Bid=",tick.bid);
           }
         else
           {
            if(Write_Log_File)
               m_Logger.WriteLogRequest("SetTrailingStopBarMode",
                  "StopLoss="+DoubleToString(stopLossPrice,_Digits));

            bool isSucceed=CloseCurrentPosition()==0;

            int lastErrorOrdClose=GetLastError();
            lastErrorOrdClose=(lastErrorOrdClose>0) ? lastErrorOrdClose : m_LastError;
           }
        }
     }
   else if(m_PositionType==OP_SELL)
     {   // Short position
      double stopLossPrice=Low(_Symbol,_Period,1)+_Point*m_TrailingStop;
      if(m_PositionStopLoss>stopLossPrice+m_PipsValue)
        {
         if(stopLossPrice>tick.ask)
           {
            if(stopLossPrice<tick.ask+_Point*m_StopLevel)
               stopLossPrice=tick.ask+_Point*m_StopLevel;

            if(Write_Log_File)
               m_Logger.WriteLogRequest("SetTrailingStopBarMode",
                  "StopLoss="+DoubleToString(stopLossPrice,_Digits));

            ModifyPosition(stopLossPrice,m_PositionTakeProfit);

            Print("Trailing Stop (",m_TrailingStop,") moved to: ",
               DoubleToString(stopLossPrice,_Digits),", Ask=",tick.ask);
           }
         else
           {
            if(Write_Log_File)
               m_Logger.WriteLogRequest("SetTrailingStopBarMode",
                  "StopLoss="+DoubleToString(stopLossPrice,_Digits));

            bool isSucceed=CloseCurrentPosition()==0;

            int lastErrorOrdClose=GetLastError();
            lastErrorOrdClose=(lastErrorOrdClose>0) ? lastErrorOrdClose : m_LastError;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ActionTrade5::SetTrailingStopTickMode()
  {
   MqlTick tick;
   SymbolInfoTick(_Symbol,tick);

   if(m_PositionType==OP_BUY)
     {   // Long position
      if(tick.bid>=m_PositionOpenPrice+m_TrailingStop*_Point)
         if(m_PositionStopLoss<tick.bid-(m_TrailingStop+TrailingStop_Moving_Step)*_Point)
           {
            double stopLossPrice=tick.bid-m_TrailingStop*_Point;
            if(Write_Log_File)
               m_Logger.WriteLogRequest("SetTrailingStopTickMode",
                  "StopLoss="+DoubleToString(stopLossPrice,_Digits));

            ModifyPosition(stopLossPrice,m_PositionTakeProfit);

            Print("Trailing Stop (",m_TrailingStop,") moved to: ",
               DoubleToString(stopLossPrice,_Digits),", Bid=",tick.bid);
           }
     }
   else if(m_PositionType==OP_SELL)
     {   // Short position
      if(m_PositionOpenPrice-tick.ask>=_Point*m_TrailingStop)
         if(m_PositionStopLoss>tick.ask+_Point *(m_TrailingStop+TrailingStop_Moving_Step))
           {
            double stopLossPrice=tick.ask+m_TrailingStop*_Point;
            if(Write_Log_File)
               m_Logger.WriteLogRequest("SetTrailingStopTickMode",
                  "StopLoss="+DoubleToString(stopLossPrice,_Digits));

            ModifyPosition(stopLossPrice,m_PositionTakeProfit);

            Print("Trailing Stop (",m_TrailingStop,") moved to: ",
               DoubleToString(stopLossPrice,_Digits),", Ask=",tick.ask);
           }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ActionTrade5::DetectSLTPActivation()
  {
// TODO
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ActionTrade5::IsTradeContextFree()
  {
   if(MQL5InfoInteger(MQL5_TRADE_ALLOWED)) return (true);

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

      if(MQL5InfoInteger(MQL5_TRADE_ALLOWED)) return (true);
      Sleep(100);
     }

   return (true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
PosDirection ActionTrade5::GetNewPositionDirection(OrderDirection ordDir,double ordLots,PosDirection posDir,double posLots)
  {
   if(ordDir!=OrderDirection_Buy && ordDir!=OrderDirection_Sell)
      return (PosDirection_None);

   PosDirection currentDir=posDir;
   double currentLots=posLots;

   switch(currentDir)
     {
      case PosDirection_Long:
         if(ordDir==OrderDirection_Buy)
         return (PosDirection_Long);
         if(currentLots>ordLots+Epsilon)
            return (PosDirection_Long);
         return currentLots < ordLots - Epsilon ? PosDirection_Short : PosDirection_None;
      case PosDirection_Short:
         if(ordDir==OrderDirection_Sell)
         return (PosDirection_Short);
         if(currentLots>ordLots+Epsilon)
            return (PosDirection_Short);
         return currentLots < ordLots - Epsilon ? PosDirection_Long : PosDirection_None;
     }

   return (ordDir == OrderDirection_Buy ? PosDirection_Long : PosDirection_Short);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ActionTrade5::InitTrade()
  {
   m_OpenTimeExec=m_Strategy.Slot[0].IndicatorPointer.ExecTime;
   m_OpenStrPriceType= StrategyPriceType_Unknown;
   if(m_OpenTimeExec == ExecutionTime_AtBarOpening)
      m_OpenStrPriceType=StrategyPriceType_Open;
   else if(m_OpenTimeExec==ExecutionTime_AtBarClosing)
      m_OpenStrPriceType=StrategyPriceType_Close;
   else
      m_OpenStrPriceType=StrategyPriceType_Indicator;

   m_CloseTimeExec=m_Strategy.Slot[m_Strategy.CloseSlotNumber()].IndicatorPointer.ExecTime;
   m_CloseStrPriceType= StrategyPriceType_Unknown;
   if(m_CloseTimeExec == ExecutionTime_AtBarOpening)
      m_CloseStrPriceType=StrategyPriceType_Open;
   else if(m_CloseTimeExec==ExecutionTime_AtBarClosing)
      m_CloseStrPriceType=StrategyPriceType_Close;
   else if(m_CloseTimeExec==ExecutionTime_CloseAndReverse)
      m_CloseStrPriceType=StrategyPriceType_CloseAndReverse;
   else
      m_CloseStrPriceType=StrategyPriceType_Indicator;

   m_UseLogicalGroups=m_Strategy.IsUsingLogicalGroups();

   if(m_UseLogicalGroups)
     {
      m_Strategy.Slot[0].LogicalGroup="All";
      m_Strategy.Slot[m_Strategy.CloseSlotNumber()].LogicalGroup="All";

      for(int slot=0; slot<m_Strategy.CloseSlotNumber(); slot++)
        {
         if(!m_GroupsAllowLong.ContainsKey(m_Strategy.Slot[slot].LogicalGroup))
            m_GroupsAllowLong.Add(m_Strategy.Slot[slot].LogicalGroup,false);
         if(!m_GroupsAllowShort.ContainsKey(m_Strategy.Slot[slot].LogicalGroup))
            m_GroupsAllowShort.Add(m_Strategy.Slot[slot].LogicalGroup,false);
        }

      // List of logical groups
      int longCount=m_GroupsAllowLong.Count();
      for(int i=0;i<longCount;i++)
         m_OpeningLogicGroups.Add(m_GroupsAllowLong.Key(i));

      // Logical groups of the closing conditions.
      for(int slot=m_Strategy.CloseSlotNumber()+1; slot<m_Strategy.Slots(); slot++)
        {
         string group=m_Strategy.Slot[slot].LogicalGroup;
         if(!m_ClosingLogicGroups.Contains(group) && group!="all")
            m_ClosingLogicGroups.Add(group); // Adds all groups except "all"
        }

      if(m_ClosingLogicGroups.Count()==0)
         m_ClosingLogicGroups.Add("all"); // If all the slots are in "all" group, adds "all" to the list.
     }

// Search if N Bars Exit is present as CloseFilter, could be any slot after first closing slot.
   m_NBarExit=0;
   for(int slot=m_Strategy.CloseSlotNumber(); slot<m_Strategy.Slots(); slot++)
     {
      if(m_Strategy.Slot[slot].IndicatorName!="N Bars Exit") continue;
      m_NBarExit=(int) m_Strategy.Slot[slot].IndicatorPointer.NumParam[0].Value;
      break;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TradeDirection ActionTrade5::AnalyzeEntryPrice()
  {
   int bar=m_DataSet[0].Bars-1;

   double buyPrice  = 0;
   double sellPrice = 0;
   for(int i=0; i<m_Strategy.Slot[0].IndicatorPointer.Components(); i++)
     {
      IndicatorComp *component=m_Strategy.Slot[0].IndicatorPointer.Component[i];
      IndComponentType compType=component.DataType;
      if(compType==IndComponentType_OpenLongPrice)
         buyPrice=component.Value[bar];
      else if(compType==IndComponentType_OpenShortPrice)
         sellPrice=component.Value[bar];
      else if(compType==IndComponentType_OpenPrice || compType==IndComponentType_OpenClosePrice)
         buyPrice=sellPrice=component.Value[bar];
      component=NULL;
     }

   double basePrice= m_DataMarket.Close;
   double oldPrice = m_DataMarket.OldClose;

   bool canOpenLong=(buyPrice>oldPrice+Epsilon  && buyPrice<basePrice+Epsilon) ||
                    (buyPrice>basePrice-Epsilon && buyPrice<oldPrice -Epsilon);

   bool canOpenShort=(sellPrice>oldPrice+Epsilon  && sellPrice<basePrice+Epsilon) ||
                     (sellPrice>basePrice-Epsilon && sellPrice<oldPrice -Epsilon);

   TradeDirection direction=TradeDirection_None;

   if(canOpenLong && canOpenShort)
      direction=TradeDirection_Both;
   else if(canOpenLong)
      direction=TradeDirection_Long;
   else if(canOpenShort)
      direction=TradeDirection_Short;

   return (direction);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TradeDirection ActionTrade5::AnalyzeEntryDirection()
  {
   int bar=m_DataSet[0].Bars-1;

// Do not send entry order when we are not on time
   if(m_OpenTimeExec==ExecutionTime_AtBarOpening)
      for(int i=0; i<m_Strategy.Slot[0].IndicatorPointer.Components(); i++)
        {
         IndicatorComp *component=m_Strategy.Slot[0].IndicatorPointer.Component[i];
         if(component.DataType!=IndComponentType_OpenLongPrice &&
            component.DataType!=IndComponentType_OpenShortPrice &&
            component.DataType!=IndComponentType_OpenPrice) continue;
         if(component.Value[bar]<Epsilon)
            return (TradeDirection_None);
         component=NULL;
        }

   for(int i=0; i<m_Strategy.Slots(); i++)
     {
      if(m_Strategy.Slot[i].IndicatorName=="Enter Once")
        {
         if(m_Strategy.Slot[i].IndicatorPointer.ListParam[0].Text=="Enter no more than once a bar")
           {
            if(m_DataSet[0].Time[bar]==m_TimeLastEntryBar)
               return (TradeDirection_None);
           }
         else if(m_Strategy.Slot[i].IndicatorPointer.ListParam[0].Text=="Enter no more than once a day")
           {
            if(TimeDayOfYear(m_DataSet[0].Time[bar])==TimeDayOfYear(m_TimeLastEntryBar))
               return (TradeDirection_None);
           }
         else if(m_Strategy.Slot[i].IndicatorPointer.ListParam[0].Text=="Enter no more than once a week")
           {
            if(TimeDayOfWeek(m_DataSet[0].Time[bar])>=TimeDayOfWeek(m_TimeLastEntryBar) &&
               m_DataSet[0].Time[bar]<m_TimeLastEntryBar+7*24*60*60)
               return (TradeDirection_None);
           }
         else if(m_Strategy.Slot[i].IndicatorPointer.ListParam[0].Text=="Enter no more than once a month")
           {
            if(TimeMonth(m_DataSet[0].Time[bar])==TimeMonth(m_TimeLastEntryBar))
               return (TradeDirection_None);
           }
        }
     }

// Determining of the buy/sell entry prices.
   double buyPrice=0;
   double sellPrice=0;
   for(int i=0; i<m_Strategy.Slot[0].IndicatorPointer.Components(); i++)
     {
      IndicatorComp *component=m_Strategy.Slot[0].IndicatorPointer.Component[i];
      IndComponentType compType=component.DataType;
      if(compType==IndComponentType_OpenLongPrice)
         buyPrice=component.Value[bar];
      else if(compType==IndComponentType_OpenShortPrice)
         sellPrice=component.Value[bar];
      else if(compType==IndComponentType_OpenPrice || compType==IndComponentType_OpenClosePrice)
         buyPrice=sellPrice=component.Value[bar];
      component=NULL;
     }

// Decide whether to open
   bool canOpenLong  = buyPrice  > Epsilon;
   bool canOpenShort = sellPrice > Epsilon;

   if(m_UseLogicalGroups)
     {
      for(int i=0; i<m_OpeningLogicGroups.Count(); i++)
        {
         string group=m_OpeningLogicGroups.Get(i);

         bool groupOpenLong  = canOpenLong;
         bool groupOpenShort = canOpenShort;

         AnalyzeEntryLogicConditions(bar,group,buyPrice,sellPrice,groupOpenLong,groupOpenShort);

         m_GroupsAllowLong.Set(group,groupOpenLong);
         m_GroupsAllowShort.Set(group,groupOpenShort);
        }

      bool groupLongEntry=false;
      for(int i=0;i<m_GroupsAllowLong.Count();i++)
        {
         string key   = m_GroupsAllowLong.Key(i);
         bool   value = m_GroupsAllowLong.Value(key);
         if((m_GroupsAllowLong.Count()>1 && key!="All") || m_GroupsAllowLong.Count()==1)
            groupLongEntry=groupLongEntry || value;
        }

      bool groupShortEntry=false;
      for(int i=0;i<m_GroupsAllowShort.Count();i++)
        {
         string key   = m_GroupsAllowShort.Key(i);
         bool   value = m_GroupsAllowShort.Value(key);
         if((m_GroupsAllowShort.Count()>1 && key!="All") || m_GroupsAllowShort.Count()==1)
            groupShortEntry=groupShortEntry || value;
        }

      canOpenLong  = canOpenLong  && groupLongEntry  && m_GroupsAllowLong.Value("All");
      canOpenShort = canOpenShort && groupShortEntry && m_GroupsAllowShort.Value("All");
     }
   else
     {
      AnalyzeEntryLogicConditions(bar,"A",buyPrice,sellPrice,canOpenLong,canOpenShort);
     }

   TradeDirection direction=TradeDirection_None;
   if(canOpenLong && canOpenShort)
      direction=TradeDirection_Both;
   else if(canOpenLong)
      direction=TradeDirection_Long;
   else if(canOpenShort)
      direction=TradeDirection_Short;

   return (direction);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ActionTrade5::AnalyzeEntryLogicConditions(int bar,string group,double buyPrice,double sellPrice,bool &canOpenLong,bool &canOpenShort)
  {
   for(int slotIndex=0; slotIndex<=m_Strategy.CloseSlotNumber(); slotIndex++)
     {
      if(m_UseLogicalGroups && m_Strategy.Slot[slotIndex].LogicalGroup!=group && m_Strategy.Slot[slotIndex].LogicalGroup!="All")
         continue;

      for(int i=0; i<m_Strategy.Slot[slotIndex].IndicatorPointer.Components(); i++)
        {
         IndicatorComp *component=m_Strategy.Slot[slotIndex].IndicatorPointer.Component[i];
         if(component.DataType==IndComponentType_AllowOpenLong && component.Value[bar]<0.5)
            canOpenLong=false;

         if(component.DataType==IndComponentType_AllowOpenShort && component.Value[bar]<0.5)
            canOpenShort=false;

         if(component.PosPriceDependence!=PositionPriceDependence_None)
           {
            double indicatorValue=component.Value[bar-component.UsePreviousBar];
            switch(component.PosPriceDependence)
              {
               case PositionPriceDependence_PriceBuyHigher:
                  canOpenLong=canOpenLong && buyPrice>indicatorValue+Epsilon;
                  break;
               case PositionPriceDependence_PriceBuyLower:
                  canOpenLong=canOpenLong && buyPrice<indicatorValue-Epsilon;
                  break;
               case PositionPriceDependence_PriceSellHigher:
                  canOpenShort=canOpenShort && sellPrice>indicatorValue+Epsilon;
                  break;
               case PositionPriceDependence_PriceSellLower:
                  canOpenShort=canOpenShort && sellPrice<indicatorValue-Epsilon;
                  break;
               case PositionPriceDependence_BuyHigherSellLower:
                  canOpenLong=canOpenLong && buyPrice>indicatorValue+Epsilon;
                  canOpenShort=canOpenShort && sellPrice<indicatorValue-Epsilon;
                  break;
               case PositionPriceDependence_BuyLowerSelHigher:
                  canOpenLong=canOpenLong && buyPrice<indicatorValue-Epsilon;
                  canOpenShort=canOpenShort && sellPrice>indicatorValue+Epsilon;
                  break;
              }
           }
         component=NULL;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ActionTrade5::AnalyzeEntrySize(OrderDirection ordDir,PosDirection &newPosDir)
  {
   double size=0;
   PosDirection posDir=m_DataMarket.PositionDirection;
// Orders modification on a fly
// Checks whether we are on the market
   if(posDir==PosDirection_Long || posDir==PosDirection_Short)
     {
      // We are on the market and have Same Dir Signal
      if((ordDir==OrderDirection_Buy && posDir==PosDirection_Long) ||
         (ordDir==OrderDirection_Sell && posDir==PosDirection_Short))
        {
         size=0;
         newPosDir=posDir;
         if(m_DataMarket.PositionLots+TradingSize(m_Strategy.AddingLots)<m_Strategy.MaxOpenLots+Epsilon)
           {
            switch(m_Strategy.SameSignalAction)
              {
               case SameDirSignalAction_Add:
                  size=TradingSize(m_Strategy.AddingLots);
                  break;
               case SameDirSignalAction_Winner:
                  if(m_DataMarket.PositionProfit>Epsilon)
                     size=TradingSize(m_Strategy.AddingLots);
                  break;
               case SameDirSignalAction_Loser:
                  if(m_DataMarket.PositionProfit<-Epsilon)
                     size=TradingSize(m_Strategy.AddingLots);
                  break;
              }
           }
        }
      else if((ordDir==OrderDirection_Buy && posDir==PosDirection_Short) || (ordDir==OrderDirection_Sell && posDir==PosDirection_Long))
        {
         // In case of an Opposite Dir Signal
         switch(m_Strategy.OppSignalAction)
           {
            case OppositeDirSignalAction_Reduce:
               if(m_DataMarket.PositionLots>TradingSize(m_Strategy.ReducingLots))
                 {
                  // Reducing
                  size=TradingSize(m_Strategy.ReducingLots);
                  newPosDir=posDir;
                 }
               else
                 {
                  // Closing
                  size=m_DataMarket.PositionLots;
                  newPosDir=PosDirection_Closed;
                 }
               break;
            case OppositeDirSignalAction_Close:
               size=m_DataMarket.PositionLots;
               newPosDir=PosDirection_Closed;
               break;
            case OppositeDirSignalAction_Reverse:
               size=m_DataMarket.PositionLots+TradingSize(m_Strategy.EntryLots);
               newPosDir=(posDir==PosDirection_Long) ? PosDirection_Short : PosDirection_Long;
               break;
            case OppositeDirSignalAction_Nothing:
               size=0;
               newPosDir=posDir;
               break;
           }
        }
     }
   else
     {
      // We are flat
      size=TradingSize(m_Strategy.EntryLots);
      if(m_Strategy.UseMartingale && m_DataMarket.ConsecutiveLosses>0)
        {
         double correctedAmount = size*MathPow(m_Strategy.MartingaleMultiplier, m_DataMarket.ConsecutiveLosses);
         double normalizedAmount = NormalizeEntrySize(correctedAmount);
         size = MathMax(normalizedAmount, SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN));
        }
      size=MathMin(size,m_Strategy.MaxOpenLots);
      newPosDir=ordDir==OrderDirection_Buy ? PosDirection_Long : PosDirection_Short;
     }

   return (size);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TradeDirection ActionTrade5::AnalyzeExitPrice()
  {
   IndicatorSlot *slot=m_Strategy.Slot[m_Strategy.CloseSlotNumber()];
   int bar=m_DataSet[0].Bars-1;

// Searching the exit price in the exit indicator slot.
   double buyPrice  = 0;
   double sellPrice = 0;
   for(int i=0; i<slot.IndicatorPointer.Components(); i++)
     {
      IndicatorComp *comp=slot.IndicatorPointer.Component[i];
      IndComponentType compType=comp.DataType;

      if(compType==IndComponentType_CloseLongPrice)
         sellPrice=comp.Value[bar];
      else if(compType==IndComponentType_CloseShortPrice)
         buyPrice=comp.Value[bar];
      else if(compType==IndComponentType_ClosePrice || compType==IndComponentType_OpenClosePrice)
         buyPrice=sellPrice=comp.Value[bar];

      comp=NULL;
     }

// We can close if the closing price is higher than zero.
   bool canCloseLong =sellPrice>Epsilon;
   bool canCloseShort=buyPrice>Epsilon;

// Check if the closing price was reached.
   if(canCloseLong)
      canCloseLong=(sellPrice>m_DataMarket.OldBid+Epsilon && sellPrice<m_DataMarket.Bid+Epsilon) ||
                   (sellPrice>m_DataMarket.Bid-Epsilon    && sellPrice<m_DataMarket.OldBid-Epsilon);
   if(canCloseShort)
      canCloseShort=(buyPrice>m_DataMarket.OldBid+Epsilon && buyPrice<m_DataMarket.Bid+Epsilon) ||
                    (buyPrice>m_DataMarket.Bid-Epsilon    && buyPrice<m_DataMarket.OldBid-Epsilon);

// Determine the trading direction.
   TradeDirection direction=TradeDirection_None;

   if(canCloseLong && canCloseShort)
      direction=TradeDirection_Both;
   else if(canCloseLong)
      direction=TradeDirection_Short;
   else if(canCloseShort)
      direction=TradeDirection_Long;

   slot=NULL;
   return (direction);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TradeDirection ActionTrade5::AnalyzeExitDirection()
  {
   int bar=m_DataSet[0].Bars-1;
   int closeSlot=m_Strategy.CloseSlotNumber();

   if(m_CloseTimeExec==ExecutionTime_AtBarClosing)
      for(int i=0; i<m_Strategy.Slot[closeSlot].IndicatorPointer.Components(); i++)
        {
         if(m_Strategy.Slot[closeSlot].IndicatorPointer.Component[i].DataType != IndComponentType_CloseLongPrice &&
            m_Strategy.Slot[closeSlot].IndicatorPointer.Component[i].DataType != IndComponentType_CloseShortPrice &&
            m_Strategy.Slot[closeSlot].IndicatorPointer.Component[i].DataType != IndComponentType_ClosePrice) continue;
         if(m_Strategy.Slot[closeSlot].IndicatorPointer.Component[i].Value[bar]<Epsilon)
            return (TradeDirection_None);
        }

   if(m_Strategy.CloseSlots()==0)
      return (TradeDirection_Both);

   if(m_NBarExit>0 && (m_DataMarket.PositionOpenTime+(m_NBarExit*((int) m_DataSet[0].Period*60))<m_DataSet[0].ServerTime))
      return (TradeDirection_Both);

   TradeDirection direction=TradeDirection_None;

   if(m_UseLogicalGroups)
     {
      for(int i=0; i<m_ClosingLogicGroups.Count(); i++)
        {
         string group=m_ClosingLogicGroups.Get(i);
         TradeDirection groupDirection=TradeDirection_Both;

         // Determining of the slot direction
         for(int slot=m_Strategy.CloseSlotNumber()+1; slot<m_Strategy.Slots(); slot++)
           {
            TradeDirection slotDirection=TradeDirection_None;
            if(m_Strategy.Slot[slot].LogicalGroup==group || m_Strategy.Slot[slot].LogicalGroup=="all")
              {
               for(int c=0; c<m_Strategy.Slot[slot].IndicatorPointer.Components(); c++)
                  if(m_Strategy.Slot[slot].IndicatorPointer.Component[c].Value[bar]>0)
                     slotDirection=GetClosingDirection(slotDirection,m_Strategy.Slot[slot].IndicatorPointer.Component[c].DataType);

               groupDirection=ReduceDirectionStatus(groupDirection,slotDirection);
              }
           }

         direction=IncreaseDirectionStatus(direction,groupDirection);
        }
     }
   else
     {   // Search close filters for a closing signal.
      for(int slot= m_Strategy.CloseSlotNumber()+1; slot<m_Strategy.Slots(); slot++)
         for(int c=0; c<m_Strategy.Slot[slot].IndicatorPointer.Components(); c++)
            if(m_Strategy.Slot[slot].IndicatorPointer.Component[c].Value[bar]>Epsilon)
               direction=GetClosingDirection(direction,m_Strategy.Slot[slot].IndicatorPointer.Component[c].DataType);
     }

   return (direction);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TradeDirection ActionTrade5::ReduceDirectionStatus(TradeDirection baseDirection,TradeDirection direction)
  {
   if(baseDirection==direction || direction==TradeDirection_Both)
      return (baseDirection);

   if(baseDirection==TradeDirection_Both)
      return (direction);

   return (TradeDirection_None);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TradeDirection ActionTrade5::IncreaseDirectionStatus(TradeDirection baseDirection,TradeDirection direction)
  {
   if(baseDirection==direction || direction==TradeDirection_None)
      return (baseDirection);

   if(baseDirection==TradeDirection_None)
      return (direction);

   return (TradeDirection_Both);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TradeDirection ActionTrade5::GetClosingDirection(TradeDirection baseDirection,IndComponentType compDataType)
  {
   TradeDirection newDirection=baseDirection;

   if(compDataType==IndComponentType_ForceClose)
     {
      newDirection=TradeDirection_Both;
     }
   else if(compDataType==IndComponentType_ForceCloseShort)
     {
      if(baseDirection==TradeDirection_None)
         newDirection=TradeDirection_Long;
      else if(baseDirection==TradeDirection_Short)
         newDirection=TradeDirection_Both;
     }
   else if(compDataType==IndComponentType_ForceCloseLong)
     {
      if(baseDirection==TradeDirection_None)
         newDirection=TradeDirection_Short;
      else if(baseDirection==TradeDirection_Long)
         newDirection=TradeDirection_Both;
     }

   return (newDirection);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ActionTrade5::GetStopLossPoints(double lots)
  {
   double indStop = DBL_MAX;
   bool isIndStop = true;
   int closeSlot=m_Strategy.CloseSlotNumber();
   string name=m_Strategy.Slot[closeSlot].IndicatorName;

   if(name=="Account Percent Stop")
      indStop=AccountPercentStopPoints(m_Strategy.Slot[closeSlot].IndicatorPointer.NumParam[0].Value,lots);
   else if(name=="ATR Stop")
      indStop=m_Strategy.Slot[closeSlot].IndicatorPointer.Component[0].Value[m_DataSet[0].Bars-1]/m_DataSet[0].Point;
   else if(name=="Stop Loss" || name=="Stop Limit")
      indStop=m_Strategy.Slot[closeSlot].IndicatorPointer.NumParam[0].Value;
   else if(name=="Trailing Stop" || name=="Trailing Stop Limit")
      indStop=m_Strategy.Slot[closeSlot].IndicatorPointer.NumParam[0].Value;
   else
      isIndStop=false;

   double permStop = m_Strategy.UsePermanentSL ? m_Strategy.PermanentSL : DBL_MAX;
   double stopLoss = 0;

   if(isIndStop || m_Strategy.UsePermanentSL)
     {
      stopLoss=MathMin(indStop,permStop);
      if(stopLoss<m_DataSet[0].StopLevel)
         stopLoss=m_DataSet[0].StopLevel;
      stopLoss=MathRound(stopLoss);
     }

   return (stopLoss);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ActionTrade5::GetTakeProfitPoints()
  {
   double takeprofit = 0;
   double permLimit  = m_Strategy.UsePermanentTP ? m_Strategy.PermanentTP : DBL_MAX;
   double indLimit   = DBL_MAX;
   bool   isIndLimit = true;
   int    closeSlot  = m_Strategy.CloseSlotNumber();
   string name       = m_Strategy.Slot[closeSlot].IndicatorName;

   if(name=="Take Profit")
      indLimit=m_Strategy.Slot[closeSlot].IndicatorPointer.NumParam[0].Value;
   else if(name=="Stop Limit" || name=="Trailing Stop Limit")
      indLimit=m_Strategy.Slot[closeSlot].IndicatorPointer.NumParam[1].Value;
   else
      isIndLimit=false;

   if(isIndLimit || m_Strategy.UsePermanentTP)
     {
      takeprofit=MathMin(indLimit,permLimit);
      if(takeprofit<m_DataSet[0].StopLevel)
         takeprofit=m_DataSet[0].StopLevel;
      takeprofit=MathRound(takeprofit);
     }

   return (takeprofit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ActionTrade5::DoEntryTrade(TradeDirection tradeDir)
  {
   double price;
   OrderDirection  ordDir;
   OperationType   opType;
   TraderOrderType type;

   if(m_TimeLastEntryBar!=m_BarTime)
      m_IsEnteredLong=m_IsEnteredShort=false;

   switch(tradeDir)
     {
      case TradeDirection_Long: // Buy
         if(m_IsEnteredLong)return;
         price  = m_DataMarket.Ask;
         ordDir = OrderDirection_Buy;
         opType = OperationType_Buy;
         type   = TraderOrderType_Buy;
         break;
      case TradeDirection_Short: // Sell
         if(m_IsEnteredShort)return;
         price  = m_DataMarket.Bid;
         ordDir = OrderDirection_Sell;
         opType = OperationType_Sell;
         type   = TraderOrderType_Sell;
         break;
      default: // Wrong direction of trade.
         return;
     }

   PosDirection newPosDir=PosDirection_None;
   double size=AnalyzeEntrySize(ordDir,newPosDir);

   if(size<m_DataSet[0].MinLot-Epsilon)
      return;  // The entry trade is cancelled.

   string symbol     = m_DataSet[0].Symbol;
   double lots       = size;
   double stoploss   = GetStopLossPoints(size);
   double takeprofit = GetTakeProfitPoints();
   double point      = m_DataSet[0].Point;

   if(stoploss>0)
     {
      double stopLossPrice=0;
      if(newPosDir==PosDirection_Long)
         stopLossPrice=m_DataMarket.Bid-stoploss*point;
      else if(newPosDir== PosDirection_Short)
         stopLossPrice = m_DataMarket.Ask+stoploss*point;
     }

   if(takeprofit>0)
     {
      double takeProfitPrice=0;
      if(newPosDir==PosDirection_Long)
         takeProfitPrice=m_DataMarket.Bid+takeprofit*point;
      else if(newPosDir==PosDirection_Short)
         takeProfitPrice=m_DataMarket.Ask-takeprofit*point;
     }

   int trlStop=0;
   TrailingStopMode trlMode=TrailingStopMode_Bar;
   int closeSlot=m_Strategy.CloseSlotNumber();
   string name=m_Strategy.Slot[closeSlot].IndicatorName;

   if(name=="Trailing Stop" || name=="Trailing Stop Limit")
     {
      trlStop=(int) m_Strategy.Slot[closeSlot].IndicatorPointer.NumParam[0].Value;
      string mode=m_Strategy.Slot[closeSlot].IndicatorPointer.ListParam[1].Text;
      if(mode!="New bar") trlMode=TrailingStopMode_Tick;
     }

   int breakEven=m_Strategy.UseBreakEven ? m_Strategy.BreakEven : 0;

   m_TrailingMode = trlMode;
   m_TrailingStop = trlStop;
   m_BreakEven    = breakEven;

   bool response=ManageOrderSend(type,lots,stoploss,takeprofit);

   if(response)
     { // The order was executed successfully.
      m_TimeLastEntryBar=m_BarTime;
      if(type==TraderOrderType_Buy)
         m_IsEnteredLong=true;
      else
         m_IsEnteredShort=true;

      m_DataMarket.WrongStopLoss   = 0;
      m_DataMarket.WrongTakeProf   = 0;
      m_DataMarket.WrongStopsRetry = 0;
     }
   else
     {  // Error in operation execution.
      m_DataMarket.WrongStopLoss = (int) stoploss;
      m_DataMarket.WrongTakeProf = (int) takeprofit;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ActionTrade5::DoExitTrade()
  {
   if(!m_DataMarket.IsFailedCloseOrder)
      m_DataMarket.IsSentCloseOrder=true;
   m_DataMarket.CloseOrderTickCounter=0;

   bool orderResponse=CloseCurrentPosition();

   m_DataMarket.WrongStopLoss   = 0;
   m_DataMarket.WrongTakeProf   = 0;
   m_DataMarket.WrongStopsRetry = 0;

   return (orderResponse);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TickType ActionTrade5::GetTickType(DataSet *dataSet,bool isNewBar)
  {
   DataPeriod period      = dataSet.Period;
   int        bars        = dataSet.Bars;
   datetime   serverTime  = dataSet.ServerTime;
   datetime   barOpenTime = dataSet.Time[bars-1];

   TickType type=TickType_Regular;

   if(isNewBar)
     {
      m_BarOpenTimeForLastCloseTick=-1;
      type=TickType_Open;
     }

   bool isClose=((barOpenTime+period*60)-serverTime)<Bar_Close_Advance;
   if(isClose)
     {
      if(m_BarOpenTimeForLastCloseTick==barOpenTime)
        {
         type=TickType_AfterClose;
        }
      else
        {
         m_BarOpenTimeForLastCloseTick=barOpenTime;
         type=isNewBar ? TickType_OpenClose : TickType_Close;
        }
     }

   return (type);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ActionTrade5::CalculateTrade(TickType ticktype)
  {
// Exit
   bool closeOk=false;

   if(m_CloseStrPriceType!=StrategyPriceType_CloseAndReverse && m_DataMarket.PositionTicket!=0)
     {
      if(ticktype==TickType_Open && m_CloseStrPriceType==StrategyPriceType_Close && m_OpenStrPriceType!=StrategyPriceType_Close)
        {  // We have missed close at the previous Bar Close
         TradeDirection direction=AnalyzeExitDirection();
         if(direction==TradeDirection_Both ||
            (direction == TradeDirection_Long  && m_DataMarket.PositionDirection == PosDirection_Short) ||
            (direction == TradeDirection_Short && m_DataMarket.PositionDirection == PosDirection_Long))
            {  // we have a missed close Order
               if(DoExitTrade())
                  UpdateDataMarket(m_DataMarket);
            }
        }
      else if(((m_CloseStrPriceType==StrategyPriceType_Open)  && (ticktype==TickType_Open  || ticktype==TickType_OpenClose)) ||
              ((m_CloseStrPriceType==StrategyPriceType_Close) && (ticktype==TickType_Close || ticktype==TickType_OpenClose)))
        {  // Exit at Bar Open or Bar Close.
         TradeDirection direction=AnalyzeExitDirection();
         if(direction==TradeDirection_Both ||
            (direction == TradeDirection_Long  && m_DataMarket.PositionDirection == PosDirection_Short) ||
            (direction == TradeDirection_Short && m_DataMarket.PositionDirection == PosDirection_Long))
            { // Close the current position.
               closeOk=DoExitTrade();
               if(closeOk)
                  UpdateDataMarket(m_DataMarket);
            }
        }
      else if((m_CloseStrPriceType==StrategyPriceType_Close && m_OpenStrPriceType!=StrategyPriceType_Close) && ticktype==TickType_AfterClose)
        {  // Exit at after close tick.
         TradeDirection direction=AnalyzeExitDirection();
         if(direction==TradeDirection_Both ||
            (direction == TradeDirection_Long  && m_DataMarket.PositionDirection == PosDirection_Short) ||
            (direction == TradeDirection_Short && m_DataMarket.PositionDirection == PosDirection_Long))
            closeOk=DoExitTrade(); // Close the current position.
        }
      else if(m_CloseStrPriceType==StrategyPriceType_Indicator)
        { // Exit at an indicator value.
         TradeDirection priceReached=AnalyzeExitPrice();
         if(priceReached==TradeDirection_Long)
           {
            TradeDirection direction=AnalyzeExitDirection();
            if(direction==TradeDirection_Long || direction==TradeDirection_Both)
               if(m_DataMarket.PositionDirection==PosDirection_Short)
                  closeOk=DoExitTrade(); // Close a short position.
           }
         else if(priceReached==TradeDirection_Short)
           {
            TradeDirection direction=AnalyzeExitDirection();
            if(direction==TradeDirection_Short || direction==TradeDirection_Both)
               if(m_DataMarket.PositionDirection==PosDirection_Long)
                  closeOk=DoExitTrade(); // Close a long position.
           }
         else if(priceReached==TradeDirection_Both)
           {
            TradeDirection direction=AnalyzeExitDirection();
            if(direction==TradeDirection_Long || direction==TradeDirection_Short ||
               direction==TradeDirection_Both)
               closeOk=DoExitTrade(); // Close the current position.
           }
        }
     }

// Checks if we closed a position successfully.
   if(closeOk && !(m_OpenStrPriceType==StrategyPriceType_Close && ticktype==TickType_Close))
      return;

// This is to prevent new entry after Bar Closing has been executed.
   if(m_CloseStrPriceType==StrategyPriceType_Close && ticktype==TickType_AfterClose)
      return;

   if(((m_OpenStrPriceType==StrategyPriceType_Open)  && (ticktype==TickType_Open  || ticktype==TickType_OpenClose)) ||
      ((m_OpenStrPriceType==StrategyPriceType_Close) && (ticktype==TickType_Close || ticktype==TickType_OpenClose)))
     { // Entry at Bar Open or Bar Close.
      TradeDirection direction=AnalyzeEntryDirection();
      if(direction==TradeDirection_Long || direction==TradeDirection_Short)
         DoEntryTrade(direction);
     }
   else if(m_OpenStrPriceType==StrategyPriceType_Indicator)
     { // Entry at an indicator value.
      TradeDirection priceReached=AnalyzeEntryPrice();
      if(priceReached==TradeDirection_Long)
        {
         TradeDirection direction=AnalyzeEntryDirection();
         if(direction==TradeDirection_Long || direction==TradeDirection_Both)
            DoEntryTrade(TradeDirection_Long);
        }
      else if(priceReached==TradeDirection_Short)
        {
         TradeDirection direction=AnalyzeEntryDirection();
         if(direction==TradeDirection_Short || direction==TradeDirection_Both)
            DoEntryTrade(TradeDirection_Short);
        }
      else if(priceReached==TradeDirection_Both)
        {
         TradeDirection direction=AnalyzeEntryDirection();
         if(direction==TradeDirection_Long || direction==TradeDirection_Short)
            DoEntryTrade(direction);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ActionTrade5::IsWrongStopsExecution()
  {
   const int maxRetry=4;

   if(m_DataMarket.PositionDirection==PosDirection_Closed ||
      m_DataMarket.PositionLots<Epsilon ||
      m_DataMarket.WrongStopsRetry>=maxRetry)
     {
      m_DataMarket.WrongStopLoss  =0;
      m_DataMarket.WrongTakeProf  =0;
      m_DataMarket.WrongStopsRetry=0;
      return (false);
     }

   bool isWrongStop=(m_DataMarket.WrongStopLoss>0 && m_DataMarket.PositionStopLoss<Epsilon) ||
                    (m_DataMarket.WrongTakeProf>0 && m_DataMarket.PositionTakeProfit<Epsilon);
   return (isWrongStop);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ActionTrade5::ResendWrongStops()
  {
   double lots       = m_DataMarket.PositionLots;
   double price      = m_DataMarket.PositionDirection == PosDirection_Long ? m_DataMarket.Bid : m_DataMarket.Ask;
   int    ticket     = m_DataMarket.PositionTicket;
   double stoploss   = m_DataMarket.WrongStopLoss;
   double takeprofit = m_DataMarket.WrongTakeProf;

   if(stoploss>0)
     {
      double stopLossPrice=0;
      if(m_DataMarket.PositionDirection==PosDirection_Long)
         stopLossPrice=m_DataMarket.Bid-stoploss*m_DataSet[0].Point;
      else if(m_DataMarket.PositionDirection==PosDirection_Short)
         stopLossPrice=m_DataMarket.Ask+stoploss*m_DataSet[0].Point;
     }
   if(takeprofit>0)
     {
      double takeProfitPrice=0;
      if(m_DataMarket.PositionDirection==PosDirection_Long)
         takeProfitPrice=m_DataMarket.Bid+takeprofit*m_DataSet[0].Point;
      else if(m_DataMarket.PositionDirection==PosDirection_Short)
         takeProfitPrice=m_DataMarket.Ask-takeprofit*m_DataSet[0].Point;
     }

   bool responseOk=ModifyPosition(stoploss,takeprofit);
   if(responseOk)
     {
      m_DataMarket.WrongStopLoss   = 0;
      m_DataMarket.WrongTakeProf   = 0;
      m_DataMarket.WrongStopsRetry = 0;
     }
   else
      m_DataMarket.WrongStopsRetry++;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ActionTrade5::TradingSize(double size)
  {
   if(m_Strategy.UseAccountPercentEntry)
      size=(size/100)*m_DataMarket.AccountEquity/m_DataSet[0].MarginRequired;
   return NormalizeEntrySize(size);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ActionTrade5::AccountPercentStopPoints(double percent,double lots)
  {
   double balance   = m_DataMarket.AccountBalance;
   double moneyrisk = balance*percent/100;
   double spread    = m_DataSet[0].Spread;
   double tickvalue = m_DataSet[0].TickValue;
   double stoploss  = moneyrisk/(lots*tickvalue) - spread;
   return (stoploss);
  }
