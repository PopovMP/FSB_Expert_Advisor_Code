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
class Alligator : public Indicator
  {
public:
                     Alligator(SlotTypes slotType);
   virtual void      Calculate(DataSet &dataSet);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Alligator::Alligator(SlotTypes slotType)
  {
   SlotType          = slotType;
   IndicatorName     = "Alligator";
   WarningMessage    = "";
   IsAllowLTF        = true;
   ExecTime          = ExecutionTime_DuringTheBar;
   IsSeparateChart   = false;
   IsDiscreteValues  = false;
   IsDefaultGroupAll = false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Alligator::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

   MAMethod maMethod=(MAMethod) ListParam[1].Index;
   BasePrice basePrice=(BasePrice) ListParam[2].Index;
   int periodJaws=(int) NumParam[0].Value;
   int shiftJaws=(int) NumParam[1].Value;
   int periodTeeth=(int) NumParam[2].Value;
   int shiftTeeth =(int) NumParam[3].Value;
   int periodLips=(int) NumParam[4].Value;
   int shiftLips=(int) NumParam[5].Value;
   int previous=CheckParam[0].Checked ? 1 : 0;

   int firstBar=MathMax(periodJaws+shiftJaws,periodTeeth+shiftTeeth);
   firstBar = MathMax(firstBar,periodLips+shiftLips);
   firstBar+= 2;

   double price[]; Price(basePrice,price);
   double jaws[]; MovingAverage(periodJaws,shiftJaws,maMethod,price,jaws);
   double teeth[]; MovingAverage(periodTeeth,shiftTeeth,maMethod,price,teeth);
   double lips[]; MovingAverage(periodLips,shiftLips,maMethod,price,lips);

   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "Jaws";
   Component[0].DataType = IndComponentType_IndicatorValue;
   Component[0].FirstBar = firstBar;
   ArrayCopy(Component[0].Value,jaws);

   ArrayResize(Component[1].Value,Data.Bars);
   Component[1].CompName = "Teeth";
   Component[1].DataType = IndComponentType_IndicatorValue;
   Component[1].FirstBar = firstBar;
   ArrayCopy(Component[1].Value,teeth);

   ArrayResize(Component[2].Value,Data.Bars);
   Component[2].CompName = "Lips";
   Component[2].DataType = IndComponentType_IndicatorValue;
   Component[2].FirstBar = firstBar;
   ArrayCopy(Component[2].Value,lips);

   ArrayResize(Component[3].Value,Data.Bars);
   Component[3].FirstBar=firstBar;

   ArrayResize(Component[4].Value,Data.Bars);
   Component[3].FirstBar=firstBar;

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

   if(ListParam[0].Text=="The Jaws rises")
      IndicatorRisesLogic(firstBar,previous,jaws,Component[3],Component[4]);
   else if(ListParam[0].Text=="The Jaws falls")
      IndicatorFallsLogic(firstBar,previous,jaws,Component[3],Component[4]);
   else if(ListParam[0].Text=="The Teeth rises")
      IndicatorRisesLogic(firstBar,previous,teeth,Component[3],Component[4]);
   else if(ListParam[0].Text=="The Teeth falls")
      IndicatorFallsLogic(firstBar,previous,teeth,Component[3],Component[4]);
   else if(ListParam[0].Text=="The Lips rises")
      IndicatorRisesLogic(firstBar,previous,lips,Component[3],Component[4]);
   else if(ListParam[0].Text=="The Lips falls")
      IndicatorFallsLogic(firstBar,previous,lips,Component[3],Component[4]);
   else if(ListParam[0].Text=="The Lips crosses the Teeth upward")
      IndicatorCrossesAnotherIndicatorUpwardLogic(firstBar,previous,lips,teeth,Component[3],Component[4]);
   else if(ListParam[0].Text=="The Lips crosses the Teeth downward")
      IndicatorCrossesAnotherIndicatorDownwardLogic(firstBar,previous,lips,teeth,Component[3],Component[4]);
   else if(ListParam[0].Text=="The Lips crosses the Jaws upward")
      IndicatorCrossesAnotherIndicatorUpwardLogic(firstBar,previous,lips,jaws,Component[3],Component[4]);
   else if(ListParam[0].Text=="The Lips crosses the Jaws downward")
      IndicatorCrossesAnotherIndicatorDownwardLogic(firstBar,previous,lips,jaws,Component[3],Component[4]);
   else if(ListParam[0].Text=="The Teeth crosses the Jaws upward")
      IndicatorCrossesAnotherIndicatorUpwardLogic(firstBar,previous,teeth,jaws,Component[3],Component[4]);
   else if(ListParam[0].Text=="The Teeth crosses the Jaws downward")
      IndicatorCrossesAnotherIndicatorDownwardLogic(firstBar,previous,teeth,jaws,Component[3],Component[4]);
  }
//+------------------------------------------------------------------+
