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
#include <Forexsb.com/Indicators/MACD.mqh>
//## Requires MACD.mqh

class OscillatorofMACD : public Indicator
  {
public:
    OscillatorofMACD(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="Oscillator of MACD";

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
void OscillatorofMACD::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

   MACD *macd1=new MACD(SlotType);
   macd1.ListParam[1].Index = ListParam[1].Index;
   macd1.ListParam[2].Index = ListParam[2].Index;
   macd1.ListParam[3].Index = ListParam[3].Index;
   macd1.NumParam[0].Value = NumParam[0].Value;
   macd1.NumParam[1].Value = NumParam[2].Value;
   macd1.NumParam[2].Value = NumParam[4].Value;
   macd1.CheckParam[0].Checked=CheckParam[0].Checked;
   macd1.Calculate(dataSet);

   MACD *macd2=new MACD(SlotType);
   macd2.ListParam[1].Index = ListParam[1].Index;
   macd2.ListParam[2].Index = ListParam[2].Index;
   macd2.ListParam[3].Index = ListParam[3].Index;
   macd2.NumParam[0].Value = NumParam[1].Value;
   macd2.NumParam[1].Value = NumParam[3].Value;
   macd2.NumParam[2].Value = NumParam[5].Value;
   macd2.CheckParam[0].Checked=CheckParam[0].Checked;
   macd2.Calculate(dataSet);

// Calculation
   int previous= CheckParam[0].Checked ? 1 : 0;

   int firstBar=0;
   for(int c=0; c<macd1.Components(); c++)
   {
       if (firstBar<macd1.Component[c].FirstBar)
           firstBar=macd1.Component[c].FirstBar;
       if (firstBar<macd2.Component[c].FirstBar)
           firstBar=macd2.Component[c].FirstBar;
   }
   firstBar+=3;

   double adIndicator1[];  ArrayResize(adIndicator1,Data.Bars);
   double adIndicator2[];  ArrayResize(adIndicator2,Data.Bars);

   if(ListParam[0].Index==0)
     {
      ArrayCopy(adIndicator1, macd1.Component[0].Value);
      ArrayCopy(adIndicator2, macd2.Component[0].Value);
     }
   else if(ListParam[0].Index==1)
     {
      ArrayCopy(adIndicator1, macd1.Component[1].Value);
      ArrayCopy(adIndicator2, macd2.Component[1].Value);
     }
   else
     {
      ArrayCopy(adIndicator1, macd1.Component[2].Value);
      ArrayCopy(adIndicator2, macd2.Component[2].Value);
     }

   delete macd1;
   delete macd2;

   double adOscillator[];
   ArrayResize(adOscillator,Data.Bars);
   ArrayInitialize(adOscillator,0);

   for(int bar=firstBar; bar<Data.Bars; bar++)
      adOscillator[bar]=adIndicator1[bar]-adIndicator2[bar];

// Saving the components

   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "Oscillator";
   Component[0].DataType = IndComponentType_IndicatorValue;
   Component[0].FirstBar = firstBar;
   ArrayCopy(Component[0].Value,adOscillator);

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

   if(ListParam[0].Text=="Oscillator of MACD rises")
      indLogic=IndicatorLogic_The_indicator_rises;
   else if(ListParam[0].Text=="Oscillator of MACD falls")
      indLogic=IndicatorLogic_The_indicator_falls;
   else if(ListParam[0].Text=="Oscillator of MACD is higher than the zero line")
      indLogic=IndicatorLogic_The_indicator_is_higher_than_the_level_line;
   else if(ListParam[0].Text=="Oscillator of MACD is lower than the zero line")
      indLogic=IndicatorLogic_The_indicator_is_lower_than_the_level_line;
   else if(ListParam[0].Text=="Oscillator of MACD crosses the zero line upward")
      indLogic=IndicatorLogic_The_indicator_crosses_the_level_line_upward;
   else if(ListParam[0].Text=="Oscillator of MACD crosses the zero line downward")
      indLogic=IndicatorLogic_The_indicator_crosses_the_level_line_downward;
   else if(ListParam[0].Text=="Oscillator of MACD changes its direction upward")
      indLogic=IndicatorLogic_The_indicator_changes_its_direction_upward;
   else if(ListParam[0].Text=="Oscillator of MACD changes its direction downward")
      indLogic=IndicatorLogic_The_indicator_changes_its_direction_downward;

   OscillatorLogic(firstBar,previous,adOscillator,0,0,Component[1],Component[2],indLogic);
  }
//+------------------------------------------------------------------+
