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
class CumulativeSum : public Indicator
  {
public:
                     CumulativeSum(SlotTypes slotType);
   virtual void      Calculate(DataSet &dataSet);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CumulativeSum::CumulativeSum(SlotTypes slotType)
  {
   SlotType          = slotType;
   IndicatorName     = "Cumulative Sum";
   WarningMessage    = "";
   IsAllowLTF        = true;
   ExecTime          = ExecutionTime_DuringTheBar;
   IsSeparateChart   = true;
   IsDiscreteValues  = false;
   IsDefaultGroupAll = false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CumulativeSum::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

   MAMethod maMethod=(MAMethod) ListParam[1].Index;
   BasePrice basePrice=(BasePrice) ListParam[2].Index;
   int period=(int) NumParam[0].Value;
   int smoothing=(int) NumParam[1].Value;
   int previous=CheckParam[0].Checked ? 1 : 0;

   int firstBar=period+smoothing+previous+2;

   double price[]; Price(basePrice,price);
   double cumulativeSum[]; ArrayResize(cumulativeSum,Data.Bars); ArrayInitialize(cumulativeSum,0);

   cumulativeSum[period-1]=0;

   for(int bar=0; bar<period; bar++)
     {
      cumulativeSum[period-1]+=price[bar];
     }

   for(int bar=period; bar<Data.Bars; bar++)
     {
      cumulativeSum[bar]=cumulativeSum[bar-1]-price[bar-period]+price[bar];
     }

   double cumulativeSumSmoothed[]; MovingAverage(smoothing,0,maMethod,cumulativeSum,cumulativeSumSmoothed);

   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "Cumulative Sum";
   Component[0].DataType = IndComponentType_IndicatorValue;
   Component[0].FirstBar = firstBar;
   ArrayCopy(Component[0].Value,cumulativeSumSmoothed);

   ArrayResize(Component[1].Value,Data.Bars);
   Component[1].FirstBar=firstBar;

   ArrayResize(Component[2].Value,Data.Bars);
   Component[1].FirstBar=firstBar;

   if(SlotType==SlotTypes_OpenFilter)
     {
      Component[1].DataType = IndComponentType_AllowOpenLong;
      Component[1].CompName = "Is long entry allowed";
      Component[2].DataType = IndComponentType_AllowOpenShort;
      Component[2].CompName = "Is short entry allowed";
     }
   else if(SlotType==SlotTypes_CloseFilter)
     {
      Component[1].DataType = IndComponentType_ForceCloseLong;
      Component[1].CompName = "Close out long position";
      Component[2].DataType = IndComponentType_ForceCloseShort;
      Component[2].CompName = "Close out short position";
     }

   IndicatorLogic indLogic=IndicatorLogic_It_does_not_act_as_a_filter;

   if(ListParam[0].Text=="Cumulative Sum rises")
      indLogic=IndicatorLogic_The_indicator_rises;
   if(ListParam[0].Text=="Cumulative Sum falls")
      indLogic=IndicatorLogic_The_indicator_falls;
   if(ListParam[0].Text=="Cumulative Sum changes its direction upward")
      indLogic=IndicatorLogic_The_indicator_changes_its_direction_upward;
   if(ListParam[0].Text=="Cumulative Sum changes its direction downward")
      indLogic=IndicatorLogic_The_indicator_changes_its_direction_downward;

   OscillatorLogic(firstBar,previous,cumulativeSumSmoothed,0,0,Component[1],Component[2],indLogic);
  }
//+------------------------------------------------------------------+
