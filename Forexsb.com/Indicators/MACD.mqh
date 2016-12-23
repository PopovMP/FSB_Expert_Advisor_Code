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
#property version   "2.00"
#property strict

#include <Forexsb.com/Indicator.mqh>
#include <Forexsb.com/Enumerations.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MACD : public Indicator
  {
public:
                     MACD(SlotTypes slotType);
   virtual void      Calculate(DataSet &dataSet);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MACD::MACD(SlotTypes slotType)
  {
   SlotType          = slotType;
   IndicatorName     = "MACD";
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
void MACD::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

   MAMethod maMethod = (MAMethod) ListParam[1].Index;
   MAMethod slMethod = (MAMethod) ListParam[3].Index;
   BasePrice basePrice=(BasePrice) ListParam[2].Index;
   int slowPeriod = (int) NumParam[0].Value;
   int fastPeriod = (int) NumParam[1].Value;
   int signalPeriod=(int) NumParam[2].Value;
   int previous=CheckParam[0].Checked ? 1 : 0;

   int firstBar=MathMax(MathMax(slowPeriod,fastPeriod),signalPeriod)+previous+2;

   double price[];  Price(basePrice,price);
   double maSlow[]; MovingAverage(slowPeriod,0,maMethod,price,maSlow);
   double maFast[]; MovingAverage(fastPeriod,0,maMethod,price,maFast);
   double macd[];   ArrayResize(macd,Data.Bars); ArrayInitialize(macd,0);

   for(int bar=slowPeriod-1; bar<Data.Bars; bar++)
     {
      macd[bar]=maFast[bar]-maSlow[bar];
     }

   double maSignalLine[];
   MovingAverage(signalPeriod,0,slMethod,macd,maSignalLine);

   double histogram[]; ArrayResize(histogram,Data.Bars);ArrayInitialize(histogram,0);

   for(int bar=slowPeriod+signalPeriod-1; bar<Data.Bars; bar++)
   {
      histogram[bar]=macd[bar]-maSignalLine[bar];
   }

   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "Histogram";
   Component[0].DataType = IndComponentType_IndicatorValue;
   Component[0].FirstBar = firstBar;
   ArrayCopy(Component[0].Value,histogram);

   ArrayResize(Component[1].Value,Data.Bars);
   Component[1].CompName = "Signal line";
   Component[1].DataType = IndComponentType_IndicatorValue;
   Component[1].FirstBar = firstBar;
   ArrayCopy(Component[1].Value,maSignalLine);

   ArrayResize(Component[2].Value,Data.Bars);
   Component[2].CompName = "MACD line";
   Component[2].DataType = IndComponentType_IndicatorValue;
   Component[2].FirstBar = firstBar;
   ArrayCopy(Component[2].Value,macd);

   ArrayResize(Component[3].Value,Data.Bars);
   ArrayResize(Component[4].Value,Data.Bars);

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

   if(ListParam[0].Text=="MACD line rises")
      OscillatorLogic(firstBar,previous,macd,0,0,Component[3],Component[4],IndicatorLogic_The_indicator_rises);
   else if(ListParam[0].Text=="MACD line falls")
      OscillatorLogic(firstBar,previous,macd,0,0,Component[3],Component[4],IndicatorLogic_The_indicator_falls);
   else if(ListParam[0].Text=="MACD line is higher than zero")
      OscillatorLogic(firstBar,previous,macd,0,0,Component[3],Component[4],IndicatorLogic_The_indicator_is_higher_than_the_level_line);
   else if(ListParam[0].Text=="MACD line is lower than zero")
      OscillatorLogic(firstBar,previous,macd,0,0,Component[3],Component[4],IndicatorLogic_The_indicator_is_lower_than_the_level_line);
   else if(ListParam[0].Text=="MACD line crosses the zero line upward")
      OscillatorLogic(firstBar,previous,macd,0,0,Component[3],Component[4],IndicatorLogic_The_indicator_crosses_the_level_line_upward);
   else if(ListParam[0].Text=="MACD line crosses the zero line downward")
      OscillatorLogic(firstBar,previous,macd,0,0,Component[3],Component[4],IndicatorLogic_The_indicator_crosses_the_level_line_downward);
   else if(ListParam[0].Text=="MACD line changes its direction upward")
      OscillatorLogic(firstBar,previous,macd,0,0,Component[3],Component[4],IndicatorLogic_The_indicator_changes_its_direction_upward);
   else if(ListParam[0].Text=="MACD line changes its direction downward")
      OscillatorLogic(firstBar,previous,macd,0,0,Component[3],Component[4],IndicatorLogic_The_indicator_changes_its_direction_downward);
   else if(ListParam[0].Text=="MACD line crosses the Signal line upward")
      OscillatorLogic(firstBar,previous,histogram,0,0,Component[3],Component[4],IndicatorLogic_The_indicator_crosses_the_level_line_upward);
   else if(ListParam[0].Text=="MACD line crosses the Signal line downward")
      OscillatorLogic(firstBar,previous,histogram,0,0,Component[3],Component[4],IndicatorLogic_The_indicator_crosses_the_level_line_downward);
   else if(ListParam[0].Text=="MACD line is higher than the Signal line")
      OscillatorLogic(firstBar,previous,histogram,0,0,Component[3],Component[4],IndicatorLogic_The_indicator_is_higher_than_the_level_line);
   else if(ListParam[0].Text=="MACD line is lower than the Signal line")
      OscillatorLogic(firstBar,previous,histogram,0,0,Component[3],Component[4],IndicatorLogic_The_indicator_is_lower_than_the_level_line);
  }
//+------------------------------------------------------------------+
