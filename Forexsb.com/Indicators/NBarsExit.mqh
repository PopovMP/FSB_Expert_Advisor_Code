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
class NBarsExit : public Indicator
  {
public:
    NBarsExit(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="N Bars Exit";

      WarningMessage    = "";
      IsAllowLTF        = true;
      ExecTime          = ExecutionTime_AtBarClosing;
      IsSeparateChart   = false;
      IsDiscreteValues  = false;
      IsDefaultGroupAll = false;
     }

   virtual void Calculate(DataSet &dataSet);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void NBarsExit::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);
   int nExit=(int) NumParam[0].Value;

// Saving the components
   ArrayResize(Component[0].Value,Data.Bars);
   ArrayInitialize(Component[0].Value,0);
   Component[0].CompName = "N Bars Exit";
   Component[0].DataType = IndComponentType_ForceClose;
   Component[0].ShowInDynInfo=true;
   Component[0].FirstBar=1;
  }
//+------------------------------------------------------------------+
