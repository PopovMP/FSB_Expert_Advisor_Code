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
    MACD(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="MACD";

      WarningMessage    = "";
      IsAllowLTF        = true;
      ExecTime          = ExecutionTime_DuringTheBar;
      IsSeparateChart   = true;
      IsDiscreteValues  = false;
      IsDefaultGroupAll = false;
     }

   virtual void Calculate(DataSet &dataSet);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MACD::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

// Reading the parameters
   MAMethod maMethod = (MAMethod) ListParam[1].Index;
   MAMethod slMethod = (MAMethod) ListParam[3].Index;
   BasePrice basePrice=(BasePrice) ListParam[2].Index;
   int slowPeriod = (int) NumParam[0].Value;
   int fastPeriod = (int) NumParam[1].Value;
   int signalLinePeriod=(int) NumParam[2].Value;
   int previous=CheckParam[0].Checked ? 1 : 0;

// Calculation
   int firstBar=slowPeriod+fastPeriod+3;

   double basePrc[];  Price(basePrice,basePrc);
   double adMASlow[]; MovingAverage(slowPeriod,0,maMethod,basePrc,adMASlow);
   double adMAFast[]; MovingAverage(fastPeriod,0,maMethod,basePrc,adMAFast);
   double adMACD[];   ArrayResize(adMACD,Data.Bars); ArrayInitialize(adMACD,0);

   for(int bar=slowPeriod-1; bar<Data.Bars; bar++)
      adMACD[bar]=adMAFast[bar]-adMASlow[bar];

   double maSignalLine[];
   MovingAverage(signalLinePeriod,0,slMethod,adMACD,maSignalLine);

// adHistogram represents MACD oscillator
   double adHistogram[]; ArrayResize(adHistogram,Data.Bars);ArrayInitialize(adHistogram,0);

   for(int bar=slowPeriod+signalLinePeriod-1; bar<Data.Bars; bar++)
      adHistogram[bar]=adMACD[bar]-maSignalLine[bar];

// Saving the components

   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "Histogram";
   Component[0].DataType = IndComponentType_IndicatorValue;
   Component[0].FirstBar = firstBar;
   ArrayCopy(Component[0].Value,adHistogram);

   ArrayResize(Component[1].Value,Data.Bars);
   Component[1].CompName = "Signal line";
   Component[1].DataType = IndComponentType_IndicatorValue;
   Component[1].FirstBar = firstBar;
   ArrayCopy(Component[1].Value,maSignalLine);

   ArrayResize(Component[2].Value,Data.Bars);
   Component[2].CompName = "MACD line";
   Component[2].DataType = IndComponentType_IndicatorValue;
   Component[2].FirstBar = firstBar;
   ArrayCopy(Component[2].Value,adMACD);

   ArrayResize(Component[3].Value,Data.Bars);

   ArrayResize(Component[4].Value,Data.Bars);

// Sets the Component's type
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
      OscillatorLogic(firstBar,previous,adMACD,0,0,Component[3],Component[4],IndicatorLogic_The_indicator_rises);
   else if(ListParam[0].Text=="MACD line falls")
      OscillatorLogic(firstBar,previous,adMACD,0,0,Component[3],Component[4],IndicatorLogic_The_indicator_falls);
   else if(ListParam[0].Text=="MACD line is higher than zero")
      OscillatorLogic(firstBar,previous,adMACD,0,0,Component[3],Component[4],IndicatorLogic_The_indicator_is_higher_than_the_level_line);
   else if(ListParam[0].Text=="MACD line is lower than zero")
      OscillatorLogic(firstBar,previous,adMACD,0,0,Component[3],Component[4],IndicatorLogic_The_indicator_is_lower_than_the_level_line);
   else if(ListParam[0].Text=="MACD line crosses the zero line upward")
      OscillatorLogic(firstBar,previous,adMACD,0,0,Component[3],Component[4],IndicatorLogic_The_indicator_crosses_the_level_line_upward);
   else if(ListParam[0].Text=="MACD line crosses the zero line downward")
      OscillatorLogic(firstBar,previous,adMACD,0,0,Component[3],Component[4],IndicatorLogic_The_indicator_crosses_the_level_line_downward);
   else if(ListParam[0].Text=="MACD line changes its direction upward")
      OscillatorLogic(firstBar,previous,adMACD,0,0,Component[3],Component[4],IndicatorLogic_The_indicator_changes_its_direction_upward);
   else if(ListParam[0].Text=="MACD line changes its direction downward")
      OscillatorLogic(firstBar,previous,adMACD,0,0,Component[3],Component[4],IndicatorLogic_The_indicator_changes_its_direction_downward);
   else if(ListParam[0].Text=="MACD line crosses the Signal line upward")
      OscillatorLogic(firstBar,previous,adHistogram,0,0,Component[3],Component[4],IndicatorLogic_The_indicator_crosses_the_level_line_upward);
   else if(ListParam[0].Text=="MACD line crosses the Signal line downward")
      OscillatorLogic(firstBar,previous,adHistogram,0,0,Component[3],Component[4],IndicatorLogic_The_indicator_crosses_the_level_line_downward);
   else if(ListParam[0].Text=="MACD line is higher than the Signal line")
      OscillatorLogic(firstBar,previous,adHistogram,0,0,Component[3],Component[4],IndicatorLogic_The_indicator_is_higher_than_the_level_line);
   else if(ListParam[0].Text=="MACD line is lower than the Signal line")
      OscillatorLogic(firstBar,previous,adHistogram,0,0,Component[3],Component[4],IndicatorLogic_The_indicator_is_lower_than_the_level_line);
  }
//+------------------------------------------------------------------+
