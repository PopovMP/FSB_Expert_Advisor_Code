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
class AwesomeOscillator : public Indicator
  {
public:
                     AwesomeOscillator(SlotTypes slotType);
   virtual void      Calculate(DataSet &dataSet);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AwesomeOscillator::AwesomeOscillator(SlotTypes slotType)
  {
   SlotType          = slotType;
   IndicatorName     = "Awesome Oscillator";
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
void AwesomeOscillator::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

   MAMethod maMethod=(MAMethod) ListParam[1].Index;
   BasePrice basePrice=(BasePrice) ListParam[2].Index;
   int periodSlow = (int) NumParam[0].Value;
   int periodFast = (int) NumParam[1].Value;
   double level=NumParam[3].Value;
   int previous=CheckParam[0].Checked ? 1 : 0;

   int firstBar=MathMax(periodSlow,periodFast)+previous+2;

   double price[]; Price(basePrice,price);
   double maSlow[]; MovingAverage(periodSlow,0,maMethod,price,maSlow);
   double maFast[]; MovingAverage(periodFast,0,maMethod,price,maFast);
   double ao[]; ArrayResize(ao,Data.Bars); ArrayInitialize(ao,0);

   for(int bar=periodSlow-1; bar<Data.Bars; bar++)
     {
      ao[bar]=maFast[bar]-maSlow[bar];
     }

   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "AO";
   Component[0].DataType = IndComponentType_IndicatorValue;
   Component[0].FirstBar = firstBar;
   ArrayCopy(Component[0].Value,ao);

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

   IndicatorLogic indicatorLogic=IndicatorLogic_It_does_not_act_as_a_filter;

   if(ListParam[0].Text=="AO rises")
      indicatorLogic=IndicatorLogic_The_indicator_rises;
   else if(ListParam[0].Text=="AO falls")
      indicatorLogic=IndicatorLogic_The_indicator_falls;
   else if(ListParam[0].Text=="AO is higher than the Level line")
      indicatorLogic=IndicatorLogic_The_indicator_is_higher_than_the_level_line;
   else if(ListParam[0].Text=="AO is lower than the Level line")
      indicatorLogic=IndicatorLogic_The_indicator_is_lower_than_the_level_line;
   else if(ListParam[0].Text=="AO crosses the Level line upward")
      indicatorLogic=IndicatorLogic_The_indicator_crosses_the_level_line_upward;
   else if(ListParam[0].Text=="AO crosses the Level line downward")
      indicatorLogic=IndicatorLogic_The_indicator_crosses_the_level_line_downward;
   else if(ListParam[0].Text=="AO changes its direction upward")
      indicatorLogic=IndicatorLogic_The_indicator_changes_its_direction_upward;
   else if(ListParam[0].Text=="AO changes its direction downward")
      indicatorLogic=IndicatorLogic_The_indicator_changes_its_direction_downward;

   OscillatorLogic(firstBar,previous,ao,level,-level,Component[1],Component[2],indicatorLogic);
  }
//+------------------------------------------------------------------+
