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
class BarRange : public Indicator
  {
public:
                     BarRange(SlotTypes slotType);
   virtual void      Calculate(DataSet &dataSet);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BarRange::BarRange(SlotTypes slotType)
  {
   SlotType          = slotType;
   IndicatorName     = "Bar Range";
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
void BarRange::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

   int period=(int) NumParam[0].Value;
   double level=NumParam[1].Value;
   int previous=CheckParam[0].Checked ? 1 : 0;
   int firstBar=period + previous + 2;

   double range[]; ArrayResize(range,Data.Bars); ArrayInitialize(range,0);

   for(int bar=firstBar; bar<Data.Bars; bar++)
     {
      double maxHigh= DBL_MIN;
      double minLow = DBL_MAX;
      for(int i=0; i<period; i++)
        {
         if(Data.High[bar-i]>maxHigh)
            maxHigh=Data.High[bar-i];
         if(Data.Low[bar-i]<minLow)
            minLow=Data.Low[bar-i];
        }
      range[bar]=maxHigh-minLow;
     }

   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "Bar Range";
   Component[0].DataType = IndComponentType_IndicatorValue;
   Component[0].FirstBar = firstBar;
   for(int i=0; i<Data.Bars; i++)
     {
      Component[0].Value[i]=MathRound(range[i]/Data.Point);
     }

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

   if(ListParam[0].Text=="Bar Range rises")
      indLogic=IndicatorLogic_The_indicator_rises;
   else if(ListParam[0].Text=="Bar Range falls")
      indLogic=IndicatorLogic_The_indicator_falls;
   else if(ListParam[0].Text=="Bar Range is higher than the Level line")
      indLogic=IndicatorLogic_The_indicator_is_higher_than_the_level_line;
   else if(ListParam[0].Text=="Bar Range is lower than the Level line")
      indLogic=IndicatorLogic_The_indicator_is_lower_than_the_level_line;

   NoDirectionOscillatorLogic(firstBar,previous,range,level*Data.Point,Component[1],indLogic);
   ArrayCopy(Component[2].Value,Component[1].Value);
  }
//+------------------------------------------------------------------+
