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
class WilliamsPercentRange : public Indicator
  {
public:
                     WilliamsPercentRange(SlotTypes slotType);
   virtual void      Calculate(DataSet &dataSet);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WilliamsPercentRange::WilliamsPercentRange(SlotTypes slotType)
     {
      SlotType          = slotType;
      IndicatorName     = "Williams' Percent Range";
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
void WilliamsPercentRange::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

   MAMethod method=(MAMethod) ListParam[1].Index;
   int period=(int) NumParam[0].Value;
   int smoothing=(int) NumParam[1].Value;
   int level=(int) NumParam[2].Value;
   int previous=CheckParam[0].Checked ? 1 : 0;

   int firstBar=MathMax(period,smoothing)+previous+2;

   double adR[]; ArrayResize(adR,Data.Bars); ArrayInitialize(adR,0);
   for(int bar=period; bar<Data.Bars; bar++)
     {
      double min = DBL_MAX;
      double max = DBL_MIN;
      for(int index=0; index<period; index++)
        {
         if(Data.High[bar - index]> max) max = Data.High[bar - index];
         if(Data.Low[bar - index] < min) min = Data.Low[bar - index];
        }
      adR[bar]=-100*(max-Data.Close[bar])/(max-min);
     }

   double adRSmoothed[];
   MovingAverage(smoothing,0,method,adR,adRSmoothed);

   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "%R";
   Component[0].DataType = IndComponentType_IndicatorValue;
   Component[0].FirstBar = firstBar;
   ArrayCopy(Component[0].Value,adRSmoothed);

   ArrayResize(Component[1].Value,Data.Bars);
   Component[1].FirstBar=firstBar;

   ArrayResize(Component[2].Value,Data.Bars);
   Component[2].FirstBar=firstBar;

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

   if(ListParam[0].Text=="WPR rises")
      indLogic=IndicatorLogic_The_indicator_rises;
   else if(ListParam[0].Text=="WPR falls")
      indLogic=IndicatorLogic_The_indicator_falls;
   else if(ListParam[0].Text=="WPR is higher than the Level line")
      indLogic=IndicatorLogic_The_indicator_is_higher_than_the_level_line;
   else if(ListParam[0].Text=="WPR is lower than the Level line")
      indLogic=IndicatorLogic_The_indicator_is_lower_than_the_level_line;
   else if(ListParam[0].Text=="WPR crosses the Level line upward")
      indLogic=IndicatorLogic_The_indicator_crosses_the_level_line_upward;
   else if(ListParam[0].Text=="WPR crosses the Level line downward")
      indLogic=IndicatorLogic_The_indicator_crosses_the_level_line_downward;
   else if(ListParam[0].Text=="WPR changes its direction upward")
      indLogic=IndicatorLogic_The_indicator_changes_its_direction_upward;
   else if(ListParam[0].Text=="WPR changes its direction downward")
      indLogic=IndicatorLogic_The_indicator_changes_its_direction_downward;

   OscillatorLogic(firstBar,previous,adRSmoothed,level,-100-level,Component[1],Component[2],indLogic);
  }
//+------------------------------------------------------------------+
