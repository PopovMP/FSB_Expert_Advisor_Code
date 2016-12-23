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
class MovingAverageOfOscillator : public Indicator
  {
public:
                     MovingAverageOfOscillator(SlotTypes slotType);
   virtual void      Calculate(DataSet &dataSet);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MovingAverageOfOscillator::MovingAverageOfOscillator(SlotTypes slotType)
  {
   SlotType          = slotType;
   IndicatorName     = "Moving Average of Oscillator";
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
void MovingAverageOfOscillator::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

   MAMethod  maMethod  = (MAMethod )ListParam[1].Index;
   MAMethod  slMethod  = (MAMethod )ListParam[3].Index;
   BasePrice basePrice = (BasePrice)ListParam[2].Index;
   int       nSlow     = (int)NumParam[0].Value;
   int       nFast     = (int)NumParam[1].Value;
   int       nSignal   = (int)NumParam[2].Value;
   double    level=NumParam[3].Value;
   int       previous=CheckParam[0].Checked ? 1 : 0;

   int firstBar=MathMax(MathMax(nFast,nSlow),nSignal)+previous+2;

   double basePrc[];
   Price(basePrice,basePrc);
   double adMASlow[]; MovingAverage(nSlow,0,maMethod,basePrc,adMASlow);
   double adMAFast[]; MovingAverage(nFast,0,maMethod,basePrc,adMAFast);

   double adMACD[];
   ArrayResize(adMACD,Data.Bars);
   ArrayInitialize(adMACD,0);

   for(int bar=0; bar<Data.Bars; bar++)
     {
      adMACD[bar]=adMAFast[bar]-adMASlow[bar];
     }
 
   double maSignalLine[];
   MovingAverage(nSignal,0,slMethod,adMACD,maSignalLine);

   double adHistogram[];
   ArrayResize(adHistogram,Data.Bars);
   ArrayInitialize(adHistogram,0);

   for(int bar=0; bar<Data.Bars; bar++)
     {
      adHistogram[bar]=adMACD[bar]-maSignalLine[bar];
     }

   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName   = "OsMA";
   Component[0].DataType   = IndComponentType_IndicatorValue;
   Component[0].FirstBar   = firstBar;
   ArrayCopy(Component[0].Value,adHistogram);

   ArrayResize(Component[1].Value,Data.Bars);
   Component[1].FirstBar=firstBar;

   ArrayResize(Component[2].Value,Data.Bars);
   Component[2].FirstBar=firstBar;

// Sets the Component's type
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

// Calculation of the logic
   IndicatorLogic indLogic=IndicatorLogic_It_does_not_act_as_a_filter;

   if(ListParam[0].Text=="The OsMA rises")
      indLogic=IndicatorLogic_The_indicator_rises;
   else if(ListParam[0].Text=="The OsMA falls")
      indLogic=IndicatorLogic_The_indicator_falls;
   else if(ListParam[0].Text=="The OsMA is higher than the Level line")
      indLogic=IndicatorLogic_The_indicator_is_higher_than_the_level_line;
   else if(ListParam[0].Text=="The OsMA is lower than the Level line")
      indLogic=IndicatorLogic_The_indicator_is_lower_than_the_level_line;
   else if(ListParam[0].Text=="The OsMA crosses the Level line upward")
      indLogic=IndicatorLogic_The_indicator_crosses_the_level_line_upward;
   else if(ListParam[0].Text=="The OsMA crosses the Level line downward")
      indLogic=IndicatorLogic_The_indicator_crosses_the_level_line_downward;
   else if(ListParam[0].Text=="The OsMA changes its direction upward")
      indLogic=IndicatorLogic_The_indicator_changes_its_direction_upward;
   else if(ListParam[0].Text=="The OsMA changes its direction downward")
      indLogic=IndicatorLogic_The_indicator_changes_its_direction_downward;

   OscillatorLogic(firstBar,previous,adHistogram,level,-level,Component[1],Component[2],indLogic);
  }
//+------------------------------------------------------------------+
