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
class MovingAveragesCrossover : public Indicator
  {
public:
                     MovingAveragesCrossover(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="Moving Averages Crossover";

      WarningMessage    = "";
      IsAllowLTF        = true;
      ExecTime          = ExecutionTime_DuringTheBar;
      IsSeparateChart   = false;
      IsDiscreteValues  = false;
      IsDefaultGroupAll = false;
     }

   virtual void      Calculate(DataSet &dataSet);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MovingAveragesCrossover::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

   BasePrice basePrice=(BasePrice) ListParam[1].Index;
   MAMethod fastMAMethod = (MAMethod) ListParam[3].Index;
   MAMethod slowMAMethod = (MAMethod) ListParam[4].Index;
   int iNFastMA = (int) NumParam[0].Value;
   int iNSlowMA = (int) NumParam[1].Value;
   int iSFastMA = (int) NumParam[2].Value;
   int iSSlowMA = (int) NumParam[3].Value;
   int previous=CheckParam[0].Checked ? 1 : 0;

   int firstBar=MathMax(iNFastMA+iSFastMA,iNSlowMA+iSSlowMA)+previous+2;
   double price[];  Price(basePrice,price);
   double maFast[]; MovingAverage(iNFastMA,iSFastMA,fastMAMethod,price,maFast);
   double maSlow[]; MovingAverage(iNSlowMA,iSSlowMA,slowMAMethod,price,maSlow);
   double oscillator[]; ArrayResize(oscillator,Data.Bars); ArrayInitialize(oscillator,0);

   for(int bar=firstBar; bar<Data.Bars; bar++)
     {
      oscillator[bar]=maFast[bar]-maSlow[bar];
     }

   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "Fast Moving Average";
   Component[0].DataType = IndComponentType_IndicatorValue;
   Component[0].FirstBar = firstBar;
   ArrayCopy(Component[0].Value,maFast);

   ArrayResize(Component[1].Value,Data.Bars);
   Component[1].CompName = "Slow Moving Average";
   Component[1].DataType = IndComponentType_IndicatorValue;
   Component[1].FirstBar = firstBar;
   ArrayCopy(Component[1].Value,maSlow);

   ArrayResize(Component[2].Value,Data.Bars);
   Component[2].FirstBar=firstBar;

   ArrayResize(Component[3].Value,Data.Bars);
   Component[3].FirstBar=firstBar;

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

   IndicatorLogic indLogic=IndicatorLogic_It_does_not_act_as_a_filter;

   if(ListParam[0].Text=="Fast MA crosses Slow MA upward")
      indLogic=IndicatorLogic_The_indicator_crosses_the_level_line_upward;
   else if(ListParam[0].Text=="Fast MA crosses Slow MA downward")
      indLogic=IndicatorLogic_The_indicator_crosses_the_level_line_downward;
   else if(ListParam[0].Text=="Fast MA is higher than Slow MA")
      indLogic=IndicatorLogic_The_indicator_is_higher_than_the_level_line;
   else if(ListParam[0].Text=="Fast MA is lower than Slow MA")
      indLogic=IndicatorLogic_The_indicator_is_lower_than_the_level_line;

   OscillatorLogic(firstBar,previous,oscillator,0,0,Component[2],Component[3],indLogic);
  }
//+------------------------------------------------------------------+
