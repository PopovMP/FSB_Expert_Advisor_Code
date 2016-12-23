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
#property version   "2.1"
#property strict

#include <Forexsb.com/Indicator.mqh>
#include <Forexsb.com/Enumerations.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MovingAvrg : public Indicator
  {
public:
                     MovingAvrg(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="Moving Average";

      WarningMessage    = "";
      IsAllowLTF        = true;
      ExecTime          = ExecutionTime_DuringTheBar;
      IsSeparateChart   = false;
      IsDiscreteValues  = false;
      IsDefaultGroupAll = false;
     }

   virtual void      Calculate(DataSet &dataSet);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MovingAvrg::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

   MAMethod  maMethod =(MAMethod) ListParam[1].Index;
   BasePrice basePrice=(BasePrice) ListParam[2].Index;
   int period=(int) NumParam[0].Value;
   int shift =(int) NumParam[1].Value;
   int previous=CheckParam[0].Checked ? 1 : 0;

   if(period==1 && shift==0)
     {
      if(basePrice== BasePrice_Open)
         ExecTime = ExecutionTime_AtBarOpening;
      else if(basePrice==BasePrice_Close)
         ExecTime=ExecutionTime_AtBarClosing;
     }
   else
     {
	   ExecTime=ExecutionTime_DuringTheBar;
     }

   double price[];        Price(basePrice,price);
   double movingAverage[];  MovingAverage(period,shift,maMethod,price,movingAverage);
   int firstBar=period+shift+previous+2;

   if(SlotType==SlotTypes_Open || SlotType==SlotTypes_Close)
     {
      ArrayResize(Component[1].Value,Data.Bars);
      ArrayInitialize(Component[1].Value,0);
      for(int bar=firstBar; bar<Data.Bars; bar++)
        {
         // Covers the cases when the price can pass through the MA without a signal
         double value   = movingAverage[bar-previous];   // Current value
         double value1  = movingAverage[bar-previous-1]; // Previous value
         double tempVal = value;
         if((value1 > Data.High[bar - 1] && value < Data.Open[bar]) || // The Data.Open price jumps above the indicator
            (value1 < Data.Low[bar - 1]  && value > Data.Open[bar]) || // The Data.Open price jumps below the indicator
            (Data.Close[bar-1]<value     && value < Data.Open[bar]) || // The Data.Open price is in a positive gap
            (Data.Close[bar-1]>value && value>Data.Open[bar])) // The Data.Open price is in a negative gap
            tempVal=Data.Open[bar];
         Component[1].Value[bar]=tempVal; // Entry or exit value
        }
     }
   else
     {
      ArrayResize(Component[1].Value, Data.Bars);
      ArrayResize(Component[2].Value, Data.Bars);
     }

   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "MA Value";
   Component[0].DataType = IndComponentType_IndicatorValue;
   Component[0].FirstBar = firstBar;
   ArrayCopy(Component[0].Value,movingAverage);

   if(SlotType==SlotTypes_Open)
     {
      Component[1].CompName = "Position opening price";
      Component[1].DataType = IndComponentType_OpenPrice;
     }
   if(SlotType==SlotTypes_OpenFilter)
     {
      Component[1].DataType = IndComponentType_AllowOpenLong;
      Component[1].CompName = "Is long entry allowed";
      Component[2].DataType = IndComponentType_AllowOpenShort;
      Component[2].CompName = "Is short entry allowed";
     }
   if(SlotType==SlotTypes_Close)
     {
      Component[1].CompName = "Position closing price";
      Component[1].DataType = IndComponentType_ClosePrice;
     }
   if(SlotType==SlotTypes_CloseFilter)
     {
      Component[1].DataType = IndComponentType_ForceCloseLong;
      Component[1].CompName = "Close out long position";
      Component[2].DataType = IndComponentType_ForceCloseShort;
      Component[2].CompName = "Close out short position";
     }

   if(SlotType==SlotTypes_OpenFilter || SlotType==SlotTypes_CloseFilter)
     {
      if(ListParam[0].Text=="Moving Average rises")
         IndicatorRisesLogic(firstBar,previous,movingAverage,Component[1],Component[2]);
      else if(ListParam[0].Text=="Moving Average falls")
         IndicatorFallsLogic(firstBar,previous,movingAverage,Component[1],Component[2]);
      else if(ListParam[0].Text=="The bar opens above Moving Average")
         BarOpensAboveIndicatorLogic(firstBar,previous,movingAverage,Component[1],Component[2]);
      else if(ListParam[0].Text=="The bar opens below Moving Average")
         BarOpensBelowIndicatorLogic(firstBar,previous,movingAverage,Component[1],Component[2]);
      else if(ListParam[0].Text=="The bar opens above Moving Average after opening below it")
         BarOpensAboveIndicatorAfterOpeningBelowLogic(firstBar,previous,movingAverage,Component[1],Component[2]);
      else if(ListParam[0].Text=="The bar opens below Moving Average after opening above it")
         BarOpensBelowIndicatorAfterOpeningAboveLogic(firstBar,previous,movingAverage,Component[1],Component[2]);
      else if(ListParam[0].Text=="The position opens above Moving Average")
        {
         Component[0].PosPriceDependence=PositionPriceDependence_BuyHigherSellLower;
         Component[1].DataType=IndComponentType_Other;
         Component[1].ShowInDynInfo=false;
         Component[2].DataType=IndComponentType_Other;
         Component[2].ShowInDynInfo=false;
        }
      else if(ListParam[0].Text=="The position opens below Moving Average")
        {
         Component[0].PosPriceDependence=PositionPriceDependence_BuyLowerSellHigher;
         Component[1].DataType=IndComponentType_Other;
         Component[1].ShowInDynInfo=false;
         Component[2].DataType=IndComponentType_Other;
         Component[2].ShowInDynInfo=false;
        }
      else if(ListParam[0].Text=="The bar closes below Moving Average")
         BarClosesBelowIndicatorLogic(firstBar,previous,movingAverage,Component[1],Component[2]);
      else if(ListParam[0].Text=="The bar closes above Moving Average")
         BarClosesAboveIndicatorLogic(firstBar,previous,movingAverage,Component[1],Component[2]);
     }
  }
//+------------------------------------------------------------------+
