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
#include <Forexsb.com/Indicators/RSI.mqh>
//## Requires RSI.mqh

class OscillatorofRSI : public Indicator
  {
public:
   OscillatorofRSI(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="Oscillator of RSI";

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
void OscillatorofRSI::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

// Reading the parameters
   int previous=CheckParam[0].Checked ? 1 : 0;

// Calculation
   double oscillator[];
   ArrayResize(oscillator,Data.Bars);
   ArrayInitialize(oscillator,0);

// ----------------------------------------------------
   RSI *rsi1=new RSI(SlotType);
   rsi1.ListParam[1].Index = ListParam[1].Index;
   rsi1.ListParam[2].Index = ListParam[2].Index;
   rsi1.NumParam[0].Value=NumParam[0].Value;
   rsi1.CheckParam[0].Checked=CheckParam[0].Checked;
   rsi1.Calculate(dataSet);

   RSI *rsi2=new RSI(SlotType);
   rsi2.ListParam[1].Index = ListParam[1].Index;
   rsi2.ListParam[2].Index = ListParam[2].Index;
   rsi2.NumParam[0].Value=NumParam[1].Value;
   rsi2.CheckParam[0].Checked=CheckParam[0].Checked;
   rsi2.Calculate(dataSet);

   double indicator1[];
   ArrayResize(indicator1,Data.Bars);
   ArrayCopy(indicator1,rsi1.Component[0].Value);
   double indicator2[];
   ArrayResize(indicator2,Data.Bars);
   ArrayCopy(indicator2,rsi2.Component[0].Value);
// -----------------------------------------------------

   int firstBar=0;
   for(int c=0; c<rsi1.Components(); c++)
   {
       if (firstBar<rsi1.Component[c].FirstBar)
           firstBar=rsi1.Component[c].FirstBar;
       if (firstBar<rsi2.Component[c].FirstBar)
           firstBar=rsi2.Component[c].FirstBar;
   }
   firstBar+=3;

   for(int bar=firstBar; bar<Data.Bars; bar++)
      oscillator[bar]=indicator1[bar]-indicator2[bar];

   delete rsi1;
   delete rsi2;

// Saving the components
   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "Oscillator";
   Component[0].DataType = IndComponentType_IndicatorValue;
   Component[0].FirstBar = firstBar;
   ArrayCopy(Component[0].Value,oscillator);

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

   if(ListParam[0].Text=="Oscillator rises")
      indLogic=IndicatorLogic_The_indicator_rises;
   else if(ListParam[0].Text=="Oscillator falls")
      indLogic=IndicatorLogic_The_indicator_falls;
   else if(ListParam[0].Text=="Oscillator is higher than the zero line")
      indLogic=IndicatorLogic_The_indicator_is_higher_than_the_level_line;
   else if(ListParam[0].Text=="Oscillator is lower than the zero line")
      indLogic=IndicatorLogic_The_indicator_is_lower_than_the_level_line;
   else if(ListParam[0].Text=="Oscillator crosses the zero line upward")
      indLogic=IndicatorLogic_The_indicator_crosses_the_level_line_upward;
   else if(ListParam[0].Text=="Oscillator crosses the zero line downward")
      indLogic=IndicatorLogic_The_indicator_crosses_the_level_line_downward;
   else if(ListParam[0].Text=="Oscillator changes its direction upward")
      indLogic=IndicatorLogic_The_indicator_changes_its_direction_upward;
   else if(ListParam[0].Text=="Oscillator changes its direction downward")
      indLogic=IndicatorLogic_The_indicator_changes_its_direction_downward;

   OscillatorLogic(firstBar,previous,oscillator,0,0,Component[1],Component[2],indLogic);
  }
//+------------------------------------------------------------------+
