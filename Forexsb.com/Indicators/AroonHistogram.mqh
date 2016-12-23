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
class AroonHistogram : public Indicator
  {
public:
                     AroonHistogram(SlotTypes slotType);
   virtual void      Calculate(DataSet &dataSet);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AroonHistogram::AroonHistogram(SlotTypes slotType)
  {
   SlotType          = slotType;
   IndicatorName     = "Aroon Histogram";
   WarningMessage    = "";
   IsAllowLTF        = true;
   ExecTime          = ExecutionTime_DuringTheBar;
   IsSeparateChart   = true;
   IsDiscreteValues  = true;
   IsDefaultGroupAll = false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AroonHistogram::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

   BasePrice basePrice=(BasePrice) ListParam[1].Index;
   int period=(int) NumParam[0].Value;
   double level=NumParam[1].Value;
   int previous=CheckParam[0].Checked ? 1 : 0;

   int firstBar=period+previous+2;
   double price[]; Price(basePrice,price);
   double up[];    ArrayResize(up,Data.Bars);    ArrayInitialize(up,0);
   double down[];  ArrayResize(down,Data.Bars);  ArrayInitialize(down,0);
   double aroon[]; ArrayResize(aroon,Data.Bars); ArrayInitialize(aroon,0);

   for(int bar=period; bar<Data.Bars; bar++)
     {
      double highestHigh=DBL_MIN;
      double lowestLow  =DBL_MAX;
      for(int i=0; i<period; i++)
        {
         int baseBar=bar-period+1+i;
         if(price[baseBar]>highestHigh)
           {
            highestHigh=price[baseBar];
            up[bar]=100.0*i/(period-1);
           }
         if(price[baseBar]<lowestLow)
           {
            lowestLow=price[baseBar];
            down[bar]=100.0*i/(period-1);
           }
        }
     }

   for(int bar=firstBar; bar<Data.Bars; bar++)
     {
      aroon[bar]=up[bar]-down[bar];
     }

   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "Aroon Histogram";
   Component[0].DataType = IndComponentType_IndicatorValue;
   Component[0].FirstBar = firstBar;
   ArrayCopy(Component[0].Value,aroon);

   ArrayResize(Component[1].Value,Data.Bars);
   Component[1].CompName = "Aroon Up";
   Component[1].DataType = IndComponentType_IndicatorValue;
   Component[1].FirstBar = firstBar;
   ArrayCopy(Component[1].Value,up);

   ArrayResize(Component[2].Value,Data.Bars);
   Component[2].CompName = "Aroon Down";
   Component[2].DataType = IndComponentType_IndicatorValue;
   Component[2].FirstBar = firstBar;
   ArrayCopy(Component[2].Value,down);

   ArrayResize(Component[3].Value,Data.Bars);
   Component[3].FirstBar=firstBar;

   ArrayResize(Component[4].Value,Data.Bars);
   Component[4].FirstBar=firstBar;

   if(SlotType==SlotTypes_OpenFilter)
     {
      Component[3].DataType = IndComponentType_AllowOpenLong;
      Component[3].CompName = "Is long entry allowed";
      Component[4].DataType = IndComponentType_AllowOpenShort;
      Component[4].CompName = "Is short entry allowed";
     }
   else if(SlotType==SlotTypes_CloseFilter)
     {
      Component[3].DataType = IndComponentType_ForceCloseLong;
      Component[3].CompName = "Close out long position";
      Component[4].DataType = IndComponentType_ForceCloseShort;
      Component[4].CompName = "Close out short position";
     }

   IndicatorLogic indLogic=IndicatorLogic_It_does_not_act_as_a_filter;

   if(ListParam[0].Text=="Aroon Histogram rises")
      indLogic=IndicatorLogic_The_indicator_rises;
   else if(ListParam[0].Text=="Aroon Histogram falls")
      indLogic=IndicatorLogic_The_indicator_falls;
   else if(ListParam[0].Text=="Aroon Histogram is higher than the Level line")
      indLogic=IndicatorLogic_The_indicator_is_higher_than_the_level_line;
   else if(ListParam[0].Text=="Aroon Histogram is lower than the Level line")
      indLogic=IndicatorLogic_The_indicator_is_lower_than_the_level_line;
   else if(ListParam[0].Text=="Aroon Histogram crosses the Level line upward")
      indLogic=IndicatorLogic_The_indicator_crosses_the_level_line_upward;
   else if(ListParam[0].Text=="Aroon Histogram crosses the Level line downward")
      indLogic=IndicatorLogic_The_indicator_crosses_the_level_line_downward;
   else if(ListParam[0].Text=="Aroon Histogram changes its direction upward")
      indLogic=IndicatorLogic_The_indicator_changes_its_direction_upward;
   else if(ListParam[0].Text=="Aroon Histogram changes its direction downward")
      indLogic=IndicatorLogic_The_indicator_changes_its_direction_downward;

   OscillatorLogic(firstBar,previous,aroon,level,-level,Component[3],Component[4],indLogic);
  }
//+------------------------------------------------------------------+
