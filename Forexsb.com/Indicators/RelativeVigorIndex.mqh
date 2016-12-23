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
class RelativeVigorIndex : public Indicator
  {
public:
    RelativeVigorIndex(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="Relative Vigor Index";

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
void RelativeVigorIndex::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

   int period=(int) NumParam[0].Value;
   int previous=CheckParam[0].Checked ? 1 : 0;

   int firstBar=period+4;

   double adRvi[]; ArrayResize(adRvi,Data.Bars); ArrayInitialize(adRvi,0);
   for(int bar=period+3; bar<Data.Bars; bar++)
     {
      double dNum=0;
      double dDeNum=0;
      for(int j=bar; j>bar-period; j--)
        {
         double dValueUp=((Data.Close[j]-Data.Open[j])+2*(Data.Close[j-1]-Data.Open[j-1])+
                          2*(Data.Close[j-2]-Data.Open[j-2])+(Data.Close[j-3]-Data.Open[j-3]))/6;
         double dValueDown=((Data.High[j]-Data.Low[j])+2*(Data.High[j-1]-Data.Low[j-1])+
                            2*(Data.High[j-2]-Data.Low[j-2])+(Data.High[j-3]-Data.Low[j-3]))/6;
         dNum+=dValueUp;
         dDeNum+=dValueDown;
        }
      if(MathAbs(dDeNum-0)>Epsilon())
         adRvi[bar]=dNum/dDeNum;
      else
         adRvi[bar]=dNum;
     }

   double adMASignal[];ArrayResize(adMASignal,Data.Bars); ArrayInitialize(adMASignal,0);
   for(int bar=4; bar<Data.Bars; bar++)
      adMASignal[bar]=(adRvi[bar]+2*adRvi[bar-1]+2*adRvi[bar-2]+adRvi[bar-3])/6;

   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "RVI Line";
   Component[0].DataType = IndComponentType_IndicatorValue;
   Component[0].FirstBar = firstBar;
   ArrayCopy(Component[0].Value,adRvi);

   ArrayResize(Component[1].Value,Data.Bars);
   Component[1].CompName = "Signal line";
   Component[1].DataType = IndComponentType_IndicatorValue;
   Component[1].FirstBar = firstBar;
   ArrayCopy(Component[1].Value,adMASignal);

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

   if(ListParam[0].Text=="RVI line rises") 
      OscillatorLogic(firstBar,previous,adRvi,0,0,Component[2],Component[3], IndicatorLogic_The_indicator_rises);
   else if(ListParam[0].Text=="RVI line falls") 
      OscillatorLogic(firstBar,previous,adRvi,0,0,Component[2],Component[3], IndicatorLogic_The_indicator_falls);
   else if(ListParam[0].Text=="RVI line is higher than zero") 
      OscillatorLogic(firstBar,previous,adRvi,0,0,Component[2],Component[3], IndicatorLogic_The_indicator_is_higher_than_the_level_line);
   else if(ListParam[0].Text=="RVI line is lower than zero") 
      OscillatorLogic(firstBar,previous,adRvi,0,0,Component[2],Component[3], IndicatorLogic_The_indicator_is_lower_than_the_level_line);
   else if(ListParam[0].Text=="RVI line crosses the zero line upward") 
      OscillatorLogic(firstBar,previous,adRvi,0,0,Component[2],Component[3], IndicatorLogic_The_indicator_crosses_the_level_line_upward);
   else if(ListParam[0].Text=="RVI line crosses the zero line downward") 
      OscillatorLogic(firstBar,previous,adRvi,0,0,Component[2],Component[3], IndicatorLogic_The_indicator_crosses_the_level_line_downward);
   else if(ListParam[0].Text=="RVI line changes its direction upward") 
      OscillatorLogic(firstBar,previous,adRvi,0,0,Component[2],Component[3], IndicatorLogic_The_indicator_changes_its_direction_upward);
   else if(ListParam[0].Text=="RVI line changes its direction downward") 
      OscillatorLogic(firstBar,previous,adRvi,0,0,Component[2],Component[3], IndicatorLogic_The_indicator_changes_its_direction_downward);
   else if(ListParam[0].Text=="RVI line crosses the Signal line upward") 
      IndicatorCrossesAnotherIndicatorUpwardLogic(firstBar,previous,adRvi,adMASignal,Component[2], Component[3]);
   else if(ListParam[0].Text=="RVI line crosses the Signal line downward") 
      IndicatorCrossesAnotherIndicatorDownwardLogic(firstBar,previous,adRvi,adMASignal,Component[2], Component[3]);
   else if(ListParam[0].Text=="RVI line is higher than the Signal line") 
      IndicatorIsHigherThanAnotherIndicatorLogic(firstBar,previous,adRvi,adMASignal,Component[2], Component[3]);
   else if(ListParam[0].Text=="RVI line is lower than the Signal line") 
      IndicatorIsLowerThanAnotherIndicatorLogic(firstBar,previous,adRvi,adMASignal,Component[2], Component[3]);
  }
//+------------------------------------------------------------------+
