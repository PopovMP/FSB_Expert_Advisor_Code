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
class ADX : public Indicator
  {
public:
   ADX(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="ADX";

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
void ADX::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

// Reading the parameters
   MAMethod maMethod =(MAMethod) ListParam[1].Index;
   int      period   = (int) NumParam[0].Value;
   double   level    = NumParam[1].Value;
   int      previous = CheckParam[0].Checked ? 1 : 0;

// Calculation
   int firstBar=2*period+2;

   double positive[]; ArrayResize(positive,Data.Bars);  ArrayInitialize(positive,0);
   double negative[]; ArrayResize(negative,Data.Bars);  ArrayInitialize(negative,0);

   for(int bar=1; bar<Data.Bars; bar++)
     {
      double trueRange=MathMax(Data.High[bar],Data.Close[bar-1])-MathMin(Data.Low[bar],Data.Close[bar-1]);

      if(trueRange<Data.Point)
         trueRange=Data.Point;

      double deltaHigh= Data.High[bar] -Data.High[bar-1];
      double deltaLow = Data.Low[bar-1]-Data.Low[bar];

      if(deltaHigh>0 && deltaHigh>deltaLow)
         positive[bar]=100*deltaHigh/trueRange;

      if(deltaLow>0 && deltaLow>deltaHigh)
         negative[bar]=100*deltaLow/trueRange;
     }

   double averagePositive[];
   MovingAverage(period,0,maMethod,positive,averagePositive);
   double averageNegative[];
   MovingAverage(period,0,maMethod,negative,averageNegative);

   double directionalIndex[]; ArrayResize(directionalIndex,Data.Bars); ArrayInitialize(directionalIndex,0);

   for(int bar=0; bar<Data.Bars; bar++)
      if(MathAbs(averagePositive[bar]-averageNegative[bar])>Epsilon())
         directionalIndex[bar]=100*MathAbs((averagePositive[bar]-averageNegative[bar])/
                                           (averagePositive[bar]+averageNegative[bar]));

   double averageDirectionalIndex[];
   MovingAverage(period,0,maMethod,directionalIndex,averageDirectionalIndex);

// Saving the components
   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "ADX";
   Component[0].DataType = IndComponentType_IndicatorValue;
   Component[0].FirstBar = firstBar;
   ArrayCopy(Component[0].Value,averageDirectionalIndex);

   ArrayResize(Component[1].Value,Data.Bars);
   Component[1].CompName = "ADI+";
   Component[1].DataType = IndComponentType_IndicatorValue;
   Component[1].FirstBar = firstBar;
   ArrayCopy(Component[1].Value,averagePositive);

   ArrayResize(Component[2].Value,Data.Bars);
   Component[2].CompName = "ADI-";
   Component[2].DataType = IndComponentType_IndicatorValue;
   Component[2].FirstBar = firstBar;
   ArrayCopy(Component[2].Value,averageNegative);

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
   if(SlotType==SlotTypes_CloseFilter)
     {
      Component[3].DataType = IndComponentType_ForceCloseLong;
      Component[3].CompName = "Close out long position";
      Component[4].DataType = IndComponentType_ForceCloseShort;
      Component[4].CompName = "Close out short position";
     }

// Calculation of the logic
   IndicatorLogic logicRule=IndicatorLogic_It_does_not_act_as_a_filter;

   if(ListParam[0].Text=="ADX rises")
      logicRule=IndicatorLogic_The_indicator_rises;
   else if(ListParam[0].Text=="ADX falls")
      logicRule=IndicatorLogic_The_indicator_falls;
   else if(ListParam[0].Text=="ADX is higher than the Level line")
      logicRule=IndicatorLogic_The_indicator_is_higher_than_the_level_line;
   else if(ListParam[0].Text=="ADX is lower than the Level line")
      logicRule=IndicatorLogic_The_indicator_is_lower_than_the_level_line;
   else if(ListParam[0].Text=="ADX crosses the Level line upward")
      logicRule=IndicatorLogic_The_indicator_crosses_the_level_line_upward;
   else if(ListParam[0].Text=="ADX crosses the Level line downward")
      logicRule=IndicatorLogic_The_indicator_crosses_the_level_line_downward;
   else if(ListParam[0].Text=="ADX changes its direction upward")
      logicRule=IndicatorLogic_The_indicator_changes_its_direction_upward;
   else if(ListParam[0].Text=="ADX changes its direction downward")
      logicRule=IndicatorLogic_The_indicator_changes_its_direction_downward;

// ADX rises equal signals in both directions!
   NoDirectionOscillatorLogic(firstBar,previous,averageDirectionalIndex,level,Component[3],logicRule);
   ArrayCopy(Component[4].Value,Component[3].Value);
  }
//+------------------------------------------------------------------+
