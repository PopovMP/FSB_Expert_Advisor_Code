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

#include <Forexsb.com\DataMarket.mqh>
#include <Forexsb.com\Strategy.mqh>
#include <Forexsb.com\Enumerations.mqh>
#include <Forexsb.com\IndicatorSlot.mqh>
#include <Forexsb.com\Helpers.mqh>
#include <Forexsb.com\HelperMq5.mqh>

//## Import Start

class ActionTrade;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class StrategyTrader
  {
private:
   ActionTrade      *actionTrade;
   Strategy         *strategy;
   DataMarket       *market;

   double            epsilon;
   bool              isEnteredLong;
   bool              isEnteredShort;
   datetime          timeLastEntryBar;
   datetime          barOpenTimeForLastCloseTick;

   StrategyPriceType openStrPriceType;
   StrategyPriceType closeStrPriceType;
   int               nBarExit;

   ExecutionTime     openTimeExec;
   ExecutionTime     closeTimeExec;
   bool              useLogicalGroups;
   DictStringBool   *groupsAllowLong;
   DictStringBool   *groupsAllowShort;
   ListString       *openingLogicGroups;
   ListString       *closingLogicGroups;

   PosDirection      GetNewPositionDirection(OrderDirection ordDir,double ordLots,PosDirection posDir,double posLots);
   TradeDirection    AnalyzeEntryPrice(void);
   TradeDirection    AnalyzeEntryDirection(void);
   void              AnalyzeEntryLogicConditions(string group,double buyPrice,double sellPrice,bool &canOpenLong,bool &canOpenShort);
   double            AnalyzeEntrySize(OrderDirection ordDir,PosDirection &newPosDir);
   TradeDirection    AnalyzeExitPrice(void);
   double            TradingSize(double size);
   int               AccountPercentStopPoint(double percent,double lots);
   TradeDirection    AnalyzeExitDirection(void);
   TradeDirection    ReduceDirectionStatus(TradeDirection baseDirection,TradeDirection direction);
   TradeDirection    IncreaseDirectionStatus(TradeDirection baseDirection,TradeDirection direction);
   TradeDirection    GetClosingDirection(TradeDirection baseDirection,IndComponentType compDataType);
   int               GetStopLossPoints(double lots);
   int               GetTakeProfitPoints(void);
   void              DoEntryTrade(TradeDirection tradeDir);
   bool              DoExitTrade(void);

public:
   // Constructor, deconstructor
                     StrategyTrader(ActionTrade *actTrade);
                    ~StrategyTrader(void);

   // Methods
   void              OnInit(Strategy *strat,DataMarket *dataMarket);
   void              OnDeinit();
   void              InitTrade(void);
   TickType          GetTickType(bool isNewBar,int closeAdvance);
   void              CalculateTrade(TickType ticktype);

   bool              IsWrongStopsExecution(void);
   void              ResendWrongStops(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void StrategyTrader::StrategyTrader(ActionTrade *actTrade)
  {
   actionTrade=actTrade;
   epsilon=0.000001;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void StrategyTrader::~StrategyTrader(void)
  {
   actionTrade = NULL;
   strategy    = NULL;
   market      = NULL;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void StrategyTrader::OnInit(Strategy *strat,DataMarket *dataMarket)
  {
   strategy = strat;
   market   = dataMarket;

   groupsAllowLong    = new DictStringBool();
   groupsAllowShort   = new DictStringBool();
   openingLogicGroups = new ListString();
   closingLogicGroups = new ListString();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void StrategyTrader::OnDeinit(void)
  {
   delete groupsAllowLong;
   delete groupsAllowShort;
   delete openingLogicGroups;
   delete closingLogicGroups;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TickType StrategyTrader::GetTickType(bool isNewBar,int closeAdvance)
  {
   TickType tickType     = TickType_Regular;
   datetime barCloseTime = market.BarTime + market.Period*60;

   if(isNewBar)
     {
      barOpenTimeForLastCloseTick=-1;
      tickType=TickType_Open;
     }

   if(market.TickServerTime>barCloseTime-closeAdvance)
     {
      if(barOpenTimeForLastCloseTick==market.BarTime)
        {
         tickType=TickType_AfterClose;
        }
      else
        {
         barOpenTimeForLastCloseTick=market.BarTime;
         tickType=isNewBar ? TickType_OpenClose : TickType_Close;
        }
     }

   return (tickType);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void StrategyTrader::CalculateTrade(TickType ticktype)
  {
// Exift
   bool closeOk=false;

   if(closeStrPriceType!=StrategyPriceType_CloseAndReverse && 
      (market.PositionDirection==PosDirection_Short || market.PositionDirection==PosDirection_Long))
     {
      if(ticktype==TickType_Open && closeStrPriceType==StrategyPriceType_Close && openStrPriceType!=StrategyPriceType_Close)
        {  // We have missed close at the previous Bar Close
         TradeDirection direction=AnalyzeExitDirection();
         if(direction==TradeDirection_Both || 
            (direction == TradeDirection_Long  && market.PositionDirection == PosDirection_Short) ||
            (direction == TradeDirection_Short && market.PositionDirection == PosDirection_Long))
           {  // we have a missed close Order
            if(DoExitTrade())
               actionTrade.UpdateDataMarket(market);
           }
        }
      else if(((closeStrPriceType==StrategyPriceType_Open)  && (ticktype==TickType_Open  || ticktype==TickType_OpenClose)) || 
              ((closeStrPriceType==StrategyPriceType_Close) && (ticktype==TickType_Close || ticktype==TickType_OpenClose)))
        {  // Exit at Bar Open or Bar Close.
         TradeDirection direction=AnalyzeExitDirection();
         if(direction==TradeDirection_Both || 
            (direction == TradeDirection_Long  && market.PositionDirection == PosDirection_Short) ||
            (direction == TradeDirection_Short && market.PositionDirection == PosDirection_Long))
           { // Close the current position.
            closeOk=DoExitTrade();
            if(closeOk)
               actionTrade.UpdateDataMarket(market);
           }
        }
      else if(closeStrPriceType==StrategyPriceType_Close && openStrPriceType!=StrategyPriceType_Close && ticktype==TickType_AfterClose)
        {  // Exit at after close tick.
         TradeDirection direction=AnalyzeExitDirection();
         if(direction==TradeDirection_Both || 
            (direction == TradeDirection_Long  && market.PositionDirection == PosDirection_Short) ||
            (direction == TradeDirection_Short && market.PositionDirection == PosDirection_Long))
            closeOk=DoExitTrade(); // Close the current position.
        }
      else if(closeStrPriceType==StrategyPriceType_Indicator)
        { // Exit at an indicator value.
         TradeDirection priceReached=AnalyzeExitPrice();
         if(priceReached==TradeDirection_Long)
           {
            TradeDirection direction=AnalyzeExitDirection();
            if(direction==TradeDirection_Long || direction==TradeDirection_Both)
              {
               if(market.PositionDirection==PosDirection_Short)
                  closeOk=DoExitTrade(); // Close a short position.
              }
           }
         else if(priceReached==TradeDirection_Short)
           {
            TradeDirection direction=AnalyzeExitDirection();
            if(direction==TradeDirection_Short || direction==TradeDirection_Both)
              {
               if(market.PositionDirection==PosDirection_Long)
                 closeOk=DoExitTrade(); // Close a long position.
              }   
           }
         else if(priceReached==TradeDirection_Both)
           {
            TradeDirection direction=AnalyzeExitDirection();
            if(direction==TradeDirection_Long || direction==TradeDirection_Short || direction==TradeDirection_Both)
               closeOk=DoExitTrade(); // Close the current position.
           }
        }
     }

// Checks if we closed a position successfully.
   if(closeOk && !(openStrPriceType==StrategyPriceType_Close && ticktype==TickType_Close))
      return;

// This is to prevent new entry after Bar Closing has been executed.
   if(closeStrPriceType==StrategyPriceType_Close && ticktype==TickType_AfterClose)
      return;

   if(((openStrPriceType==StrategyPriceType_Open) && (ticktype==TickType_Open || ticktype==TickType_OpenClose)) ||
      ((openStrPriceType==StrategyPriceType_Close) && (ticktype==TickType_Close || ticktype==TickType_OpenClose)))
     { // Entry at Bar Open or Bar Close.
      TradeDirection direction=AnalyzeEntryDirection();
      if(direction==TradeDirection_Long || direction==TradeDirection_Short)
         DoEntryTrade(direction);
     }
   else if(openStrPriceType==StrategyPriceType_Indicator)
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
PosDirection StrategyTrader::GetNewPositionDirection(OrderDirection ordDir,double ordLots,
                                                     PosDirection posDir,double posLots)
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
         if(currentLots>ordLots+epsilon)
            return (PosDirection_Long);
         return (currentLots < ordLots - epsilon ? PosDirection_Short : PosDirection_None);
      case PosDirection_Short:
         if(ordDir==OrderDirection_Sell)
            return (PosDirection_Short);
         if(currentLots>ordLots+epsilon)
            return (PosDirection_Short);
         return (currentLots < ordLots - epsilon ? PosDirection_Long : PosDirection_None);
     }

   return (ordDir == OrderDirection_Buy ? PosDirection_Long : PosDirection_Short);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void StrategyTrader::InitTrade()
  {
   openTimeExec=strategy.Slot[0].IndicatorPointer.ExecTime;
   openStrPriceType=StrategyPriceType_Unknown;
   if(openTimeExec==ExecutionTime_AtBarOpening)
      openStrPriceType=StrategyPriceType_Open;
   else if(openTimeExec==ExecutionTime_AtBarClosing)
      openStrPriceType=StrategyPriceType_Close;
   else
      openStrPriceType=StrategyPriceType_Indicator;

   closeTimeExec=strategy.Slot[strategy.CloseSlotNumber()].IndicatorPointer.ExecTime;
   closeStrPriceType=StrategyPriceType_Unknown;
   if(closeTimeExec==ExecutionTime_AtBarOpening)
      closeStrPriceType=StrategyPriceType_Open;
   else if(closeTimeExec==ExecutionTime_AtBarClosing)
      closeStrPriceType=StrategyPriceType_Close;
   else if(closeTimeExec==ExecutionTime_CloseAndReverse)
      closeStrPriceType=StrategyPriceType_CloseAndReverse;
   else
      closeStrPriceType=StrategyPriceType_Indicator;

   useLogicalGroups=strategy.IsUsingLogicalGroups();

   if(useLogicalGroups)
     {
      strategy.Slot[0].LogicalGroup="All";
      strategy.Slot[strategy.CloseSlotNumber()].LogicalGroup="All";

      for(int slot=0; slot<strategy.CloseSlotNumber(); slot++)
        {
         if(!groupsAllowLong.ContainsKey(strategy.Slot[slot].LogicalGroup))
            groupsAllowLong.Add(strategy.Slot[slot].LogicalGroup, false);
         if(!groupsAllowShort.ContainsKey(strategy.Slot[slot].LogicalGroup))
            groupsAllowShort.Add(strategy.Slot[slot].LogicalGroup, false);
        }

      // List of logical groups
      int longCount=groupsAllowLong.Count();
      for(int i=0; i<longCount; i++)
        {
         openingLogicGroups.Add(groupsAllowLong.Key(i));
        }

      // Logical groups of the closing conditions.
      for(int slot=strategy.CloseSlotNumber()+1; slot<strategy.Slots(); slot++)
        {
         string group=strategy.Slot[slot].LogicalGroup;
         if(!closingLogicGroups.Contains(group) && group!="all")
            closingLogicGroups.Add(group); // Adds all groups except "all"
        }

      if(closingLogicGroups.Count()==0)
         closingLogicGroups.Add("all");
     }

// Search if N Bars Exit is present as CloseFilter,
// could be any slot after first closing slot.
   nBarExit=0;
   for(int slot=strategy.CloseSlotNumber(); slot<strategy.Slots(); slot++)
     {
      if(strategy.Slot[slot].IndicatorName!="N Bars Exit")
         continue;
      nBarExit=(int) strategy.Slot[slot].IndicatorPointer.NumParam[0].Value;
      break;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TradeDirection StrategyTrader::AnalyzeEntryPrice(void)
  {
   double buyPrice  = 0;
   double sellPrice = 0;
   for(int i=0; i<strategy.Slot[0].IndicatorPointer.Components(); i++)
     {
      IndicatorComp *component=strategy.Slot[0].IndicatorPointer.Component[i];
      IndComponentType compType=component.DataType;
      if(compType==IndComponentType_OpenLongPrice)
         buyPrice=component.GetLastValue();
      else if(compType==IndComponentType_OpenShortPrice)
         sellPrice=component.GetLastValue();
      else if(compType==IndComponentType_OpenPrice || compType==IndComponentType_OpenClosePrice)
         buyPrice=sellPrice=component.GetLastValue();
      component=NULL;
     }

   double basePrice = market.Close;
   double oldPrice  = market.OldClose;
   bool canOpenLong  = false;
   bool canOpenShort = false;

   if(oldPrice<epsilon)
     {  // OldClose==0 for the first tick.
      canOpenLong  = MathAbs(buyPrice - basePrice) < epsilon;
      canOpenShort = MathAbs(sellPrice - basePrice) < epsilon;
     }
   else
     {
      canOpenLong=(buyPrice>oldPrice+epsilon && buyPrice<basePrice+epsilon) || 
                  (buyPrice>basePrice-epsilon && buyPrice<oldPrice-epsilon);
      canOpenShort=(sellPrice>oldPrice+epsilon && sellPrice<basePrice+epsilon) || 
                   (sellPrice>basePrice-epsilon && sellPrice<oldPrice-epsilon);
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
TradeDirection StrategyTrader::AnalyzeEntryDirection()
  {
// Do not send entry order when we are not on time
   if(openTimeExec==ExecutionTime_AtBarOpening)
      for(int i=0; i<strategy.Slot[0].IndicatorPointer.Components(); i++)
        {
         IndicatorComp *component=strategy.Slot[0].IndicatorPointer.Component[i];
         if(component.DataType != IndComponentType_OpenLongPrice && 
            component.DataType != IndComponentType_OpenShortPrice &&
            component.DataType != IndComponentType_OpenPrice)
            continue;
         if(component.GetLastValue()<epsilon)
            return (TradeDirection_None);
         component=NULL;
        }

   for(int i=0; i<strategy.Slots(); i++)
     {
      if(strategy.Slot[i].IndicatorName=="Enter Once")
        {
         string logicText=strategy.Slot[i].IndicatorPointer.ListParam[0].Text;
         if(logicText=="Enter no more than once a bar")
           {
            if(market.BarTime==timeLastEntryBar)
               return (TradeDirection_None);
           }
         else if(logicText=="Enter no more than once a day")
           {
            if(TimeDayOfYear(market.BarTime)==TimeDayOfYear(timeLastEntryBar))
               return (TradeDirection_None);
           }
         else if(logicText=="Enter no more than once a week")
           {
            if(TimeDayOfWeek(market.BarTime)>=TimeDayOfWeek(timeLastEntryBar) && 
               market.BarTime<timeLastEntryBar+7*24*60*60)
               return (TradeDirection_None);
           }
         else if(logicText=="Enter no more than once a month")
           {
            if(TimeMonth(market.BarTime)==TimeMonth(timeLastEntryBar))
               return (TradeDirection_None);
           }
        }
     }

// Determining of the buy/sell entry prices.
   double buyPrice=0;
   double sellPrice=0;
   for(int i=0; i<strategy.Slot[0].IndicatorPointer.Components(); i++)
     {
      IndicatorComp *component=strategy.Slot[0].IndicatorPointer.Component[i];
      IndComponentType compType=component.DataType;
      if(compType==IndComponentType_OpenLongPrice)
         buyPrice=component.GetLastValue();
      else if(compType==IndComponentType_OpenShortPrice)
         sellPrice=component.GetLastValue();
      else if(compType==IndComponentType_OpenPrice || compType==IndComponentType_OpenClosePrice)
         buyPrice=sellPrice=component.GetLastValue();
      component=NULL;
     }

// Decide whether to open
   bool canOpenLong=buyPrice>epsilon;
   bool canOpenShort=sellPrice>epsilon;

   if(useLogicalGroups)
     {
      for(int i=0; i<openingLogicGroups.Count(); i++)
        {
         string group=openingLogicGroups.Get(i);

         bool groupOpenLong=canOpenLong;
         bool groupOpenShort=canOpenShort;

         AnalyzeEntryLogicConditions(group,buyPrice,sellPrice,groupOpenLong,groupOpenShort);

         groupsAllowLong.Set(group,groupOpenLong);
         groupsAllowShort.Set(group,groupOpenShort);
        }

      bool groupLongEntry=false;
      for(int i=0; i<groupsAllowLong.Count(); i++)
        {
         string key = groupsAllowLong.Key(i);
         bool value = groupsAllowLong.Value(key);
         if((groupsAllowLong.Count()>1 && key!="All") || groupsAllowLong.Count()==1)
            groupLongEntry=groupLongEntry || value;
        }

      bool groupShortEntry=false;
      for(int i=0; i<groupsAllowShort.Count(); i++)
        {
         string key = groupsAllowShort.Key(i);
         bool value = groupsAllowShort.Value(key);
         if((groupsAllowShort.Count()>1 && key!="All") || groupsAllowShort.Count()==1)
            groupShortEntry=groupShortEntry || value;
        }

      canOpenLong=canOpenLong && groupLongEntry && groupsAllowLong.Value("All");
      canOpenShort=canOpenShort && groupShortEntry && groupsAllowShort.Value("All");
     }
   else
     {
      AnalyzeEntryLogicConditions("A",buyPrice,sellPrice,canOpenLong,canOpenShort);
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
void StrategyTrader::AnalyzeEntryLogicConditions(string group,double buyPrice,double sellPrice,
                                                 bool &canOpenLong,bool &canOpenShort)
  {
   for(int slotIndex=0; slotIndex<=strategy.CloseSlotNumber(); slotIndex++)
     {
      if(useLogicalGroups && 
         strategy.Slot[slotIndex].LogicalGroup != group &&
         strategy.Slot[slotIndex].LogicalGroup != "All")
         continue;

      for(int i=0; i<strategy.Slot[slotIndex].IndicatorPointer.Components(); i++)
        {
         IndicatorComp *component=strategy.Slot[slotIndex].IndicatorPointer.Component[i];
         if(component.PosPriceDependence==PositionPriceDependence_None)
           {
            if(component.DataType==IndComponentType_AllowOpenLong && 
               component.GetLastValue()<0.5)
               canOpenLong=false;

            if(component.DataType==IndComponentType_AllowOpenShort && 
               component.GetLastValue()<0.5)
               canOpenShort=false;
           }
         else
           {
            int previous=strategy.Slot[slotIndex].GetUsePreviousBarValue() ? 1 : 0;
            if(strategy.IsLongerTimeFrame(slotIndex))
               previous=0;

            double indicatorValue=component.GetLastValue(previous);
            switch(component.PosPriceDependence)
              {
               case PositionPriceDependence_PriceBuyHigher:
                  canOpenLong=canOpenLong && buyPrice>indicatorValue+epsilon;
                  break;
               case PositionPriceDependence_PriceBuyLower:
                  canOpenLong=canOpenLong && buyPrice<indicatorValue-epsilon;
                  break;
               case PositionPriceDependence_PriceSellHigher:
                  canOpenShort=canOpenShort && sellPrice>indicatorValue+epsilon;
                  break;
               case PositionPriceDependence_PriceSellLower:
                  canOpenShort=canOpenShort && sellPrice<indicatorValue-epsilon;
                  break;
               case PositionPriceDependence_BuyHigherSellLower:
                  canOpenLong  = canOpenLong  && buyPrice  > indicatorValue + epsilon;
                  canOpenShort = canOpenShort && sellPrice < indicatorValue - epsilon;
                  break;
               case PositionPriceDependence_BuyLowerSelHigher: // Deprecated
               case PositionPriceDependence_BuyLowerSellHigher:
                  canOpenLong  = canOpenLong  && buyPrice  < indicatorValue - epsilon;
                  canOpenShort = canOpenShort && sellPrice > indicatorValue + epsilon;
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
double StrategyTrader::AnalyzeEntrySize(OrderDirection ordDir,PosDirection &newPosDir)
  {
   double size=0;
   PosDirection posDir=market.PositionDirection;
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
         if(market.PositionLots+TradingSize(strategy.AddingLots)<
            strategy.MaxOpenLots+market.LotStep/2)
           {
            switch(strategy.SameSignalAction)
              {
               case SameDirSignalAction_Add:
                  size=TradingSize(strategy.AddingLots);
                  break;
               case SameDirSignalAction_Winner:
                  if(market.PositionProfit>epsilon)
                  size=TradingSize(strategy.AddingLots);
                  break;
               case SameDirSignalAction_Loser:
                  if(market.PositionProfit<-epsilon)
                  size=TradingSize(strategy.AddingLots);
                  break;
              }
           }
        }
      else if((ordDir==OrderDirection_Buy && posDir==PosDirection_Short) || 
         (ordDir==OrderDirection_Sell && posDir==PosDirection_Long))
           {
            // In case of an Opposite Dir Signal
            switch(strategy.OppSignalAction)
              {
               case OppositeDirSignalAction_Reduce:
                  if(market.PositionLots>TradingSize(strategy.ReducingLots))
                    { // Reducing
                     size=TradingSize(strategy.ReducingLots);
                     newPosDir=posDir;
                    }
                  else
                    { // Closing
                     size=market.PositionLots;
                     newPosDir=PosDirection_Closed;
                    }
                  break;
               case OppositeDirSignalAction_Close:
                  size=market.PositionLots;
                  newPosDir=PosDirection_Closed;
                  break;
               case OppositeDirSignalAction_Reverse:
                  size=market.PositionLots+TradingSize(strategy.EntryLots);
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
         // We are square on the market
         size=TradingSize(strategy.EntryLots);
         if(strategy.UseMartingale && market.ConsecutiveLosses>0)
           {
            double correctedAmount=size*MathPow(strategy.MartingaleMultiplier,market.ConsecutiveLosses);
            double normalizedAmount=actionTrade.NormalizeEntrySize(correctedAmount);
            size=MathMax(normalizedAmount,market.MinLot);
           }
         size=MathMin(size,strategy.MaxOpenLots);

         newPosDir=(ordDir==OrderDirection_Buy) ? PosDirection_Long : PosDirection_Short;
        }
      return (size);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   TradeDirection StrategyTrader::AnalyzeExitPrice()
     {
      IndicatorSlot *slot=strategy.Slot[strategy.CloseSlotNumber()];

      // Searching the exit price in the exit indicator slot.
      double buyPrice=0;
      double sellPrice=0;
      for(int i=0; i<slot.IndicatorPointer.Components(); i++)
        {
         IndicatorComp *comp=slot.IndicatorPointer.Component[i];
         IndComponentType compType=comp.DataType;

         if(compType==IndComponentType_CloseLongPrice)
            sellPrice=comp.GetLastValue();
         else if(compType==IndComponentType_CloseShortPrice)
            buyPrice=comp.GetLastValue();
         else if(compType==IndComponentType_ClosePrice || 
            compType==IndComponentType_OpenClosePrice)
            buyPrice=sellPrice=comp.GetLastValue();

         comp=NULL;
        }

      // We can close if the closing price is higher than zero.
      bool canCloseLong=sellPrice>epsilon;
      bool canCloseShort=buyPrice>epsilon;

      // Check if the closing price was reached.
      if(canCloseLong)
        {
         canCloseLong=(sellPrice>market.OldBid+epsilon && sellPrice<market.Bid+epsilon) || 
                      (sellPrice<market.OldBid-epsilon && sellPrice>market.Bid-epsilon);
        }
      if(canCloseShort)
        {
         canCloseShort=(buyPrice>market.OldBid+epsilon && buyPrice<market.Bid+epsilon) || 
                       (buyPrice<market.OldBid-epsilon && buyPrice>market.Bid-epsilon);
        }                 

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
   TradeDirection StrategyTrader::AnalyzeExitDirection()
     {
      int closeSlot=strategy.CloseSlotNumber();

      if(closeTimeExec==ExecutionTime_AtBarClosing)
         for(int i=0; i<strategy.Slot[closeSlot].IndicatorPointer.Components(); i++)
           {
            IndComponentType dataType=strategy.Slot[closeSlot].IndicatorPointer.Component[i].DataType;
            double value = strategy.Slot[closeSlot].IndicatorPointer.Component[i].GetLastValue();
            if(dataType != IndComponentType_CloseLongPrice &&
               dataType != IndComponentType_CloseShortPrice &&
               dataType != IndComponentType_ClosePrice)
               continue;
            if(value<epsilon)
               return (TradeDirection_None);
           }

      if(strategy.CloseSlots()==0)
         return (TradeDirection_Both);

      if(nBarExit>0 && 
         (market.PositionOpenTime+(nBarExit *((int) market.Period*60))<market.TickServerTime))
         return (TradeDirection_Both);

      TradeDirection direction=TradeDirection_None;

      if(useLogicalGroups)
        {
         for(int i=0; i<closingLogicGroups.Count(); i++)
           {
            string group=closingLogicGroups.Get(i);
            TradeDirection groupDirection=TradeDirection_Both;

            // Determining of the slot direction
            for(int slot=strategy.CloseSlotNumber()+1; slot<strategy.Slots(); slot++)
              {
               TradeDirection slotDirection=TradeDirection_None;
               if(strategy.Slot[slot].LogicalGroup==group || strategy.Slot[slot].LogicalGroup=="all")
                 {
                  for(int c=0; c<strategy.Slot[slot].IndicatorPointer.Components(); c++)
                    {
                     if(strategy.Slot[slot].IndicatorPointer.Component[c].GetLastValue()>0)
                        slotDirection=GetClosingDirection(slotDirection,strategy.Slot[slot].IndicatorPointer.Component[c].DataType);
                    }      

                  groupDirection=ReduceDirectionStatus(groupDirection,slotDirection);
                 }
              }

            direction=IncreaseDirectionStatus(direction,groupDirection);
           }
        }
      else
        {   // Search close filters for a closing signal.
         for(int slot=strategy.CloseSlotNumber()+1; slot<strategy.Slots(); slot++)
           {
            for(int c=0; c<strategy.Slot[slot].IndicatorPointer.Components(); c++)
              {
               if(strategy.Slot[slot].IndicatorPointer.Component[c].GetLastValue()>epsilon)
                  direction=GetClosingDirection(direction,strategy.Slot[slot].IndicatorPointer.Component[c].DataType);
              }
           }     
        }

      return (direction);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   TradeDirection StrategyTrader::ReduceDirectionStatus(TradeDirection baseDirection,TradeDirection direction)
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
   TradeDirection StrategyTrader::IncreaseDirectionStatus(TradeDirection baseDirection,TradeDirection direction)
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
   TradeDirection StrategyTrader::GetClosingDirection(TradeDirection baseDirection,IndComponentType compDataType)
     {
      TradeDirection newDirection=baseDirection;

      if(compDataType==IndComponentType_ForceClose)
        {
         newDirection=TradeDirection_Both;
        }
      else if(compDataType==IndComponentType_ForceCloseShort)
        {
         if(baseDirection == TradeDirection_None)
            newDirection = TradeDirection_Long;
         else if(baseDirection==TradeDirection_Short)
            newDirection=TradeDirection_Both;
        }
      else if(compDataType==IndComponentType_ForceCloseLong)
        {
         if(baseDirection == TradeDirection_None)
            newDirection = TradeDirection_Short;
         else if(baseDirection==TradeDirection_Long)
            newDirection=TradeDirection_Both;
        }

      return (newDirection);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   int StrategyTrader::GetStopLossPoints(double lots)
     {
      int  indStop   = INT_MAX;
      bool isIndStop = true;
      int  closeSlot = strategy.CloseSlotNumber();
      string name=strategy.Slot[closeSlot].IndicatorName;

      if(name=="Account Percent Stop")
         indStop=AccountPercentStopPoint(strategy.Slot[closeSlot].IndicatorPointer.NumParam[0].Value,lots);
      else if(name== "ATR Stop")
         indStop =(int) MathRound(strategy.Slot[closeSlot].IndicatorPointer.Component[0].GetLastValue()/market.Point);
      else if(name== "Stop Loss"|| name == "Stop Limit")
         indStop =(int) strategy.Slot[closeSlot].IndicatorPointer.NumParam[0].Value;
      else if(name== "Trailing Stop"|| name == "Trailing Stop Limit")
         indStop =(int) strategy.Slot[closeSlot].IndicatorPointer.NumParam[0].Value;
      else
         isIndStop=false;

      int permStop = strategy.UsePermanentSL ? strategy.PermanentSL : INT_MAX;
      int stopLoss = 0;

      if(isIndStop || strategy.UsePermanentSL)
        {
         stopLoss=MathMin(indStop,permStop);
         if(stopLoss<market.StopLevel)
            stopLoss=market.StopLevel;
        }

      return (stopLoss);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   int StrategyTrader::GetTakeProfitPoints()
     {
      int    takeprofit = 0;
      int    permLimit  = strategy.UsePermanentTP ? strategy.PermanentTP : INT_MAX;
      int    indLimit   = INT_MAX;
      bool   isIndLimit = true;
      int    closeSlot  = strategy.CloseSlotNumber();
      string name       = strategy.Slot[closeSlot].IndicatorName;

      if(name=="Take Profit")
         indLimit = (int) strategy.Slot[closeSlot].IndicatorPointer.NumParam[0].Value;
      else if(name == "Stop Limit" || name == "Trailing Stop Limit")
         indLimit = (int) strategy.Slot[closeSlot].IndicatorPointer.NumParam[1].Value;
      else
         isIndLimit=false;

      if(isIndLimit || strategy.UsePermanentTP)
        {
         takeprofit=MathMin(indLimit,permLimit);
         if(takeprofit<market.StopLevel)
            takeprofit=market.StopLevel;
        }

      return (takeprofit);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   void StrategyTrader::DoEntryTrade(TradeDirection tradeDir)
     {
      OrderDirection  ordDir;
      OperationType   opType;
      TraderOrderType type;

      if(timeLastEntryBar!=market.BarTime)
         isEnteredLong=isEnteredShort=false;

      switch(tradeDir)
        {
         case TradeDirection_Long: // Buy
            if(isEnteredLong)
               return;
            ordDir = OrderDirection_Buy;
            opType = OperationType_Buy;
            type   = TraderOrderType_Buy;
            break;
         case TradeDirection_Short: // Sell
            if(isEnteredShort)
               return;
            ordDir = OrderDirection_Sell;
            opType = OperationType_Sell;
            type   = TraderOrderType_Sell;
            break;
         default: // Wrong direction of trade.
            return;
        }

      PosDirection newPosDir=PosDirection_None;
      double size=AnalyzeEntrySize(ordDir,newPosDir);

      if(size<market.MinLot-epsilon)
         return;  // The entry trade is cancelled.

      TrailingStopMode trlMode=TrailingStopMode_Bar;
      int    trlStop   = 0;
      int    closeSlot = strategy.CloseSlotNumber();
      string name      = strategy.Slot[closeSlot].IndicatorName;

      if(name=="Trailing Stop" || name=="Trailing Stop Limit")
        {
         trlStop=(int) strategy.Slot[closeSlot].IndicatorPointer.NumParam[0].Value;
         string mode=strategy.Slot[closeSlot].IndicatorPointer.ListParam[1].Text;
         if(mode!="New bar")
            trlMode=TrailingStopMode_Tick;
        }

      int stopLoss   = GetStopLossPoints(size);
      int takeProfit = GetTakeProfitPoints();
      int breakEven  = strategy.UseBreakEven ? strategy.BreakEven : 0;

      bool response=actionTrade.ManageOrderSend(type,size,stopLoss,takeProfit,trlMode,trlStop,breakEven);

      if(response)
        { // The order was executed successfully.
         timeLastEntryBar=market.BarTime;
         if(type==TraderOrderType_Buy)
            isEnteredLong=true;
         else
            isEnteredShort=true;

         market.WrongStopLoss   = 0;
         market.WrongTakeProf   = 0;
         market.WrongStopsRetry = 0;
        }
      else
        {  // Error in operation execution.
         market.WrongStopLoss = stopLoss;
         market.WrongTakeProf = takeProfit;
        }
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   bool StrategyTrader::DoExitTrade()
     {
      if(!market.IsFailedCloseOrder)
         market.IsSentCloseOrder=true;
      market.CloseOrderTickCounter=0;

      bool orderResponse=actionTrade.CloseCurrentPosition();

      market.WrongStopLoss   = 0;
      market.WrongTakeProf   = 0;
      market.WrongStopsRetry = 0;

      return (orderResponse);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   bool StrategyTrader::IsWrongStopsExecution()
     {
      const int maxRetry=4;

      if(market.PositionDirection==PosDirection_Closed || 
         market.PositionLots < epsilon ||
         market.WrongStopsRetry>=maxRetry)
        {
         market.WrongStopLoss   = 0;
         market.WrongTakeProf   = 0;
         market.WrongStopsRetry = 0;
         return (false);
        }

      bool isWrongStop=(market.WrongStopLoss>0 && market.PositionStopLoss<epsilon) || 
                       (market.WrongTakeProf>0 && market.PositionTakeProfit<epsilon);

      return (isWrongStop);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   void StrategyTrader::ResendWrongStops()
     {
      double stopLossPrice=0;
      int stopLoss=market.WrongStopLoss;
      if(stopLoss>0)
        {
         if(market.PositionDirection==PosDirection_Long)
            stopLossPrice=market.Bid-stopLoss*market.Point;
         else if(market.PositionDirection==PosDirection_Short)
            stopLossPrice=market.Ask+stopLoss*market.Point;
        }

      double takeProfitPrice=0;
      int takeProfit=market.WrongTakeProf;
      if(takeProfit>0)
        {
         if(market.PositionDirection==PosDirection_Long)
            takeProfitPrice=market.Bid+takeProfit*market.Point;
         else if(market.PositionDirection==PosDirection_Short)
            takeProfitPrice=market.Ask-takeProfit*market.Point;
        }

      bool isSucess=actionTrade.ModifyPosition(stopLossPrice,takeProfitPrice);

      if(isSucess)
        {
         market.WrongStopLoss   = 0;
         market.WrongTakeProf   = 0;
         market.WrongStopsRetry = 0;
        }
      else
        {
         market.WrongStopsRetry++;
        }
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   double StrategyTrader::TradingSize(double size)
     {
      if(strategy.UseAccountPercentEntry)
         size=(size/100)*market.AccountEquity/market.MarginRequired;
      if(size>strategy.MaxOpenLots)
         size=strategy.MaxOpenLots;
      return (actionTrade.NormalizeEntrySize(size));
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   int StrategyTrader::AccountPercentStopPoint(double percent,double lots)
     {
      double balance   = market.AccountBalance;
      double moneyrisk = balance * percent / 100;
      double spread    = market.Spread;
      double tickvalue = market.TickValue;
      double stoploss  = moneyrisk / (lots * tickvalue) - spread;
      return ((int) MathRound(stoploss));
     }
//+------------------------------------------------------------------+
