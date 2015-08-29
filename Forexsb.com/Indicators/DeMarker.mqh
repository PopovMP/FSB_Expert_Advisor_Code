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
class DeMarker : public Indicator
  {
public:
    DeMarker(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="DeMarker";

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
void DeMarker::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

// Reading the parameters
   MAMethod maMethod=(MAMethod) ListParam[1].Index;
   int iPeriod=(int) NumParam[0].Value;
   double dLevel=NumParam[1].Value;
   int iPrvs=CheckParam[0].Checked ? 1 : 0;

// Calculation
   int firstBar=iPeriod+2;
   double adDeMax[];    ArrayResize(adDeMax,Data.Bars);    ArrayInitialize(adDeMax,0);
   double adDeMin[];    ArrayResize(adDeMin,Data.Bars);    ArrayInitialize(adDeMin,0);
   double adDeMarker[]; ArrayResize(adDeMarker,Data.Bars); ArrayInitialize(adDeMarker,0);

   for(int iBar=1; iBar<Data.Bars; iBar++)
     {
      adDeMax[iBar] = Data.High[iBar] > Data.High[iBar - 1] ? Data.High[iBar] - Data.High[iBar - 1] : 0;
      adDeMin[iBar] = Data.Low[iBar] < Data.Low[iBar - 1] ? Data.Low[iBar - 1] - Data.Low[iBar] : 0;
     }

   double adDeMaxMA[]; MovingAverage(iPeriod,0,maMethod,adDeMax,adDeMaxMA);
   double adDeMinMA[]; MovingAverage(iPeriod,0,maMethod,adDeMin,adDeMinMA);

   for(int iBar=firstBar; iBar<Data.Bars; iBar++)
     {
      if(MathAbs(adDeMaxMA[iBar]+adDeMinMA[iBar]-0)<Epsilon())
         adDeMarker[iBar]=0;
      else
         adDeMarker[iBar]=adDeMaxMA[iBar]/(adDeMaxMA[iBar]+adDeMinMA[iBar]);
     }

// Saving the components

   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "DeMarker";
   Component[0].DataType = IndComponentType_IndicatorValue;
   Component[0].FirstBar = firstBar;
   ArrayCopy(Component[0].Value,adDeMarker);

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
   
   if(ListParam[0].Text=="DeMarker rises") 
      indLogic=IndicatorLogic_The_indicator_rises;
   else if(ListParam[0].Text=="DeMarker falls") 
      indLogic=IndicatorLogic_The_indicator_falls;
   else if(ListParam[0].Text=="DeMarker is higher than the Level line") 
      indLogic=IndicatorLogic_The_indicator_is_higher_than_the_level_line;
   else if(ListParam[0].Text=="DeMarker is lower than the Level line") 
      indLogic=IndicatorLogic_The_indicator_is_lower_than_the_level_line;
   else if(ListParam[0].Text=="DeMarker crosses the Level line upward") 
      indLogic=IndicatorLogic_The_indicator_crosses_the_level_line_upward;
   else if(ListParam[0].Text=="DeMarker crosses the Level line downward") 
      indLogic=IndicatorLogic_The_indicator_crosses_the_level_line_downward;
   else if(ListParam[0].Text=="DeMarker changes its direction upward") 
      indLogic=IndicatorLogic_The_indicator_changes_its_direction_upward;
   else if(ListParam[0].Text=="DeMarker changes its direction downward") 
      indLogic=IndicatorLogic_The_indicator_changes_its_direction_downward;

   OscillatorLogic(firstBar,iPrvs,adDeMarker,dLevel,1-dLevel,Component[1],Component[2],indLogic);
  }
//+------------------------------------------------------------------+
