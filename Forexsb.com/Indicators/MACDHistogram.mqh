//+--------------------------------------------------------------------+
//| Copyright:  (C) 2014 Forex Software Ltd.                           |
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

#property copyright "Copyright (C) 2014 Forex Software Ltd."
#property link      "http://forexsb.com"
#property version   "2.00"
#property strict

#include <Forexsb.com/Indicator.mqh>
#include <Forexsb.com/Enumerations.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MACDHistogram : public Indicator
  {
public:
    MACDHistogram(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="MACD Histogram";

      WarningMessage    = "";
      IsAllowLTF        = true;
      ExecTime          = ExecutionTime_DuringTheBar;
      IsSeparateChart   = true;
      IsDiscreteValues  = false;
      IsDeafultGroupAll = false;
     }

   virtual void Calculate(DataSet &dataSet);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MACDHistogram::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

// Reading the parameters
   MAMethod maMethod = (MAMethod) ListParam[1].Index;
   MAMethod slMethod = (MAMethod) ListParam[3].Index;
   BasePrice basePrice=(BasePrice) ListParam[2].Index;
   int nSlow = (int) NumParam[0].Value;
   int nFast = (int) NumParam[1].Value;
   int nSignal=(int) NumParam[2].Value;
   double dLevel=NumParam[3].Value;
   int iPrvs=CheckParam[0].Checked ? 1 : 0;

// Calculation
   int iFirstBar=nSlow+nFast+2;

   double basePrc[];  Price(basePrice,basePrc);
   double adMASlow[]; MovingAverage(nSlow,0,maMethod,basePrc,adMASlow);
   double adMAFast[]; MovingAverage(nFast,0,maMethod,basePrc,adMAFast);
   double adMACD[];   ArrayResize(adMACD,Data.Bars); ArrayInitialize(adMACD,0);

   for(int iBar=nSlow-1; iBar<Data.Bars; iBar++)
      adMACD[iBar]=adMAFast[iBar]-adMASlow[iBar];

   double maSignalLine[];
   MovingAverage(nSignal,0,slMethod,adMACD,maSignalLine);

// adHistogram represents MACD oscillator
   double adHistogram[];
   ArrayResize(adHistogram,Data.Bars);
   ArrayInitialize(adHistogram,0);
   for(int iBar=nSlow+nSignal-1; iBar<Data.Bars; iBar++)
      adHistogram[iBar]=adMACD[iBar]-maSignalLine[iBar];

// Saving the components
   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "Histogram";
   Component[0].DataType = IndComponentType_IndicatorValue;
   Component[0].FirstBar = iFirstBar;
   ArrayCopy(Component[0].Value,adHistogram);

   ArrayResize(Component[1].Value,Data.Bars);
   Component[1].CompName = "Signal line";
   Component[1].DataType = IndComponentType_IndicatorValue;
   Component[1].FirstBar = iFirstBar;
   ArrayCopy(Component[1].Value,maSignalLine);

   ArrayResize(Component[2].Value,Data.Bars);
   Component[2].CompName = "MACD line";
   Component[2].DataType = IndComponentType_IndicatorValue;
   Component[2].FirstBar = iFirstBar;
   ArrayCopy(Component[2].Value,adMACD);

   ArrayResize(Component[3].Value,Data.Bars);
   Component[3].FirstBar=iFirstBar;

   ArrayResize(Component[4].Value,Data.Bars);
   Component[4].FirstBar=iFirstBar;

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

// Calculation of the logic
   IndicatorLogic indLogic=IndicatorLogic_It_does_not_act_as_a_filter;

   if(ListParam[0].Text=="MACD histogram rises") 
      indLogic=IndicatorLogic_The_indicator_rises;
   else if(ListParam[0].Text=="MACD histogram falls") 
      indLogic=IndicatorLogic_The_indicator_falls;
   else if(ListParam[0].Text=="MACD histogram is higher than the Level line") 
      indLogic=IndicatorLogic_The_indicator_is_higher_than_the_level_line;
   else if(ListParam[0].Text=="MACD histogram is lower than the Level line") 
      indLogic=IndicatorLogic_The_indicator_is_lower_than_the_level_line;
   else if(ListParam[0].Text=="MACD histogram crosses the Level line upward") 
      indLogic=IndicatorLogic_The_indicator_crosses_the_level_line_upward;
   else if(ListParam[0].Text=="MACD histogram crosses the Level line downward") 
      indLogic=IndicatorLogic_The_indicator_crosses_the_level_line_downward;
   else if(ListParam[0].Text=="MACD histogram changes its direction upward") 
      indLogic=IndicatorLogic_The_indicator_changes_its_direction_upward;
   else if(ListParam[0].Text=="MACD histogram changes its direction downward") 
      indLogic=IndicatorLogic_The_indicator_changes_its_direction_downward;

   OscillatorLogic(iFirstBar,iPrvs,adHistogram,dLevel,-dLevel,Component[3],Component[4],indLogic);
  }
//+------------------------------------------------------------------+
