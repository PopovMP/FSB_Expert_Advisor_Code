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
class DirectionalIndicators : public Indicator
  {
public:
    DirectionalIndicators(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="Directional Indicators";

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
void DirectionalIndicators::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

// Reading the parameters
   MAMethod maMethod=(MAMethod) ListParam[1].Index;
   int period=(int) NumParam[0].Value;
   int prev=CheckParam[0].Checked ? 1 : 0;

// Calculation
   int firstBar=period+2;

   double diPos[]; ArrayResize(diPos,Data.Bars); ArrayInitialize(diPos,0);
   double diNeg[]; ArrayResize(diNeg,Data.Bars); ArrayInitialize(diNeg,0);

   for(int bar=1; bar<Data.Bars; bar++)
     {
      double trueRange=MathMax(Data.High[bar],Data.Close[bar-1])-MathMin(Data.Low[bar],Data.Close[bar-1]);

      if(trueRange<Data.Point)
         trueRange=Data.Point;

      double deltaHigh= Data.High[bar]-Data.High[bar-1];
      double deltaLow = Data.Low[bar-1]-Data.Low[bar];

      if(deltaHigh>0 && deltaHigh>deltaLow)
         diPos[bar]=100*deltaHigh/trueRange;
      else
         diPos[bar]=0;

      if(deltaLow>0 && deltaLow>deltaHigh)
         diNeg[bar]=100*deltaLow/trueRange;
      else
         diNeg[bar]=0;
     }

   double adiPos[]; MovingAverage(period,0,maMethod,diPos,adiPos);
   double adiNeg[]; MovingAverage(period,0,maMethod,diNeg,adiNeg);
   double adiOsc[]; ArrayResize(adiOsc,Data.Bars); ArrayInitialize(adiOsc,0);

   for(int bar=0; bar<Data.Bars; bar++)
      adiOsc[bar]=adiPos[bar]-adiNeg[bar];

// Saving the components
   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "ADI+";
   Component[0].DataType = IndComponentType_IndicatorValue;
   Component[0].FirstBar = firstBar;
   ArrayCopy(Component[0].Value,adiPos);

   ArrayResize(Component[1].Value,Data.Bars);
   Component[1].CompName = "ADI-";
   Component[1].DataType = IndComponentType_IndicatorValue;
   Component[1].FirstBar = firstBar;
   ArrayCopy(Component[1].Value,adiNeg);

   ArrayResize(Component[2].Value,Data.Bars);
   Component[2].FirstBar=firstBar;

   ArrayResize(Component[3].Value,Data.Bars);
   Component[2].FirstBar=firstBar;

// Sets the Component's type
   if(SlotType==SlotTypes_OpenFilter)
     {
      Component[2].DataType = IndComponentType_AllowOpenLong;
      Component[2].CompName = "Is long entry allowed";
      Component[3].DataType = IndComponentType_AllowOpenShort;
      Component[3].CompName = "Is short entry allowed";
     }
   else if(SlotType==SlotTypes_CloseFilter)
     {
      Component[2].DataType = IndComponentType_ForceCloseLong;
      Component[2].CompName = "Close out long position";
      Component[3].DataType = IndComponentType_ForceCloseShort;
      Component[3].CompName = "Close out short position";
     }

   if(ListParam[0].Text=="ADI+ rises") 
      OscillatorLogic(firstBar,prev,adiPos,0,0,Component[2],Component[3],IndicatorLogic_The_indicator_rises);
   else if(ListParam[0].Text=="ADI+ falls") 
      OscillatorLogic(firstBar,prev,adiPos,0,0,Component[2],Component[3],IndicatorLogic_The_indicator_falls);
   else if(ListParam[0].Text=="ADI- rises") 
      OscillatorLogic(firstBar,prev,adiNeg,0,0,Component[2],Component[3],IndicatorLogic_The_indicator_rises);
   else if(ListParam[0].Text=="ADI- falls") 
      OscillatorLogic(firstBar,prev,adiNeg,0,0,Component[2],Component[3],IndicatorLogic_The_indicator_falls);
   else if(ListParam[0].Text=="ADI+ is higher than ADI-") 
      OscillatorLogic(firstBar,prev,adiOsc,0,0,Component[2],Component[3],IndicatorLogic_The_indicator_is_higher_than_the_level_line);
   else if(ListParam[0].Text=="ADI+ is lower than ADI-") 
      OscillatorLogic(firstBar,prev,adiOsc,0,0,Component[2],Component[3],IndicatorLogic_The_indicator_is_lower_than_the_level_line);
   else if(ListParam[0].Text=="ADI+ crosses ADI- line upward") 
      OscillatorLogic(firstBar,prev,adiOsc,0,0,Component[2],Component[3],IndicatorLogic_The_indicator_crosses_the_level_line_upward);
   else if(ListParam[0].Text=="ADI+ crosses ADI- line downward") 
      OscillatorLogic(firstBar,prev,adiOsc,0,0,Component[2],Component[3],IndicatorLogic_The_indicator_crosses_the_level_line_downward);
   else if(ListParam[0].Text=="ADI+ changes its direction upward") 
      OscillatorLogic(firstBar,prev,adiPos,0,0,Component[2],Component[3],IndicatorLogic_The_indicator_changes_its_direction_upward);
   else if(ListParam[0].Text=="ADI+ changes its direction downward") 
      OscillatorLogic(firstBar,prev,adiPos,0,0,Component[2],Component[3],IndicatorLogic_The_indicator_changes_its_direction_downward);
   else if(ListParam[0].Text=="ADI- changes its direction upward") 
      OscillatorLogic(firstBar,prev,adiNeg,0,0,Component[2],Component[3],IndicatorLogic_The_indicator_changes_its_direction_upward);
   else if(ListParam[0].Text=="ADI- changes its direction downward") 
      OscillatorLogic(firstBar,prev,adiNeg,0,0,Component[2],Component[3],IndicatorLogic_The_indicator_changes_its_direction_downward);
  }
//+------------------------------------------------------------------+
