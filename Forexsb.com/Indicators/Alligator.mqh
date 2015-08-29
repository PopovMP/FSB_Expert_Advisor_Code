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
class Alligator : public Indicator
  {
public:
   Alligator(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="Alligator";

      WarningMessage    = "";
      IsAllowLTF        = true;
      ExecTime          = ExecutionTime_DuringTheBar;
      IsSeparateChart   = false;
      IsDiscreteValues  = false;
      IsDeafultGroupAll = false;
     }

   virtual void Calculate(DataSet &dataSet);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Alligator::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

   MAMethod maMethod=(MAMethod) ListParam[1].Index;
   BasePrice basePrice=(BasePrice) ListParam[2].Index;
   int iNJaws  = (int) NumParam[0].Value;
   int iSJaws  = (int) NumParam[1].Value;
   int iNTeeth = (int) NumParam[2].Value;
   int iSTeeth = (int) NumParam[3].Value;
   int iNLips  = (int) NumParam[4].Value;
   int iSLips  = (int) NumParam[5].Value;
   int prev    = CheckParam[0].Checked ? 1 : 0;

   int firstBar=MathMax(iNJaws+iSJaws+2,iNTeeth+iSTeeth+2);
   firstBar=MathMax(firstBar,iNLips+iSLips+2);

// Calculation
   double basePrc[];
   Price(basePrice,basePrc);
   double adJaws[];
   MovingAverage(iNJaws,iSJaws,maMethod,basePrc,adJaws);
   double adTeeth[];
   MovingAverage(iNTeeth,iSTeeth,maMethod,basePrc,adTeeth);
   double adLips[];
   MovingAverage(iNLips,iSLips,maMethod,basePrc,adLips);

// Saving the components
   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "Jaws";
   Component[0].DataType = IndComponentType_IndicatorValue;
   Component[0].FirstBar = firstBar;
   ArrayCopy(Component[0].Value,adJaws);

   ArrayResize(Component[1].Value,Data.Bars);
   Component[1].CompName = "Teeth";
   Component[1].DataType = IndComponentType_IndicatorValue;
   Component[1].FirstBar = firstBar;
   ArrayCopy(Component[1].Value,adTeeth);

   ArrayResize(Component[2].Value,Data.Bars);
   Component[2].CompName = "Lips";
   Component[2].DataType = IndComponentType_IndicatorValue;
   Component[2].FirstBar = firstBar;
   ArrayCopy(Component[2].Value,adLips);

   ArrayResize(Component[3].Value,Data.Bars);
   Component[3].FirstBar=firstBar;

   ArrayResize(Component[4].Value,Data.Bars);
   Component[3].FirstBar=firstBar;

// Sets the Component's type.
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
      IndicatorRisesLogic(firstBar,prev,adJaws,Component[3],Component[4]);
   else if(ListParam[0].Text=="The Jaws falls")
      IndicatorFallsLogic(firstBar,prev,adJaws,Component[3],Component[4]);
   else if(ListParam[0].Text=="The Teeth rises")
      IndicatorRisesLogic(firstBar,prev,adTeeth,Component[3],Component[4]);
   else if(ListParam[0].Text=="The Teeth falls")
      IndicatorFallsLogic(firstBar,prev,adTeeth,Component[3],Component[4]);
   else if(ListParam[0].Text=="The Lips rises")
      IndicatorRisesLogic(firstBar,prev,adLips,Component[3],Component[4]);
   else if(ListParam[0].Text=="The Lips falls")
      IndicatorFallsLogic(firstBar,prev,adLips,Component[3],Component[4]);
   else if(ListParam[0].Text=="The Lips crosses the Teeth upward")
      IndicatorCrossesAnotherIndicatorUpwardLogic(firstBar,prev,adLips,adTeeth,Component[3],Component[4]);
   else if(ListParam[0].Text=="The Lips crosses the Teeth downward")
      IndicatorCrossesAnotherIndicatorDownwardLogic(firstBar,prev,adLips,adTeeth,Component[3],Component[4]);
   else if(ListParam[0].Text=="The Lips crosses the Jaws upward")
      IndicatorCrossesAnotherIndicatorUpwardLogic(firstBar,prev,adLips,adJaws,Component[3],Component[4]);
   else if(ListParam[0].Text=="The Lips crosses the Jaws downward")
      IndicatorCrossesAnotherIndicatorDownwardLogic(firstBar,prev,adLips,adJaws,Component[3],Component[4]);
   else if(ListParam[0].Text=="The Teeth crosses the Jaws upward")
      IndicatorCrossesAnotherIndicatorUpwardLogic(firstBar,prev,adTeeth,adJaws,Component[3],Component[4]);
   else if(ListParam[0].Text=="The Teeth crosses the Jaws downward")
      IndicatorCrossesAnotherIndicatorDownwardLogic(firstBar,prev,adTeeth,adJaws,Component[3],Component[4]);
  }
//+------------------------------------------------------------------+
