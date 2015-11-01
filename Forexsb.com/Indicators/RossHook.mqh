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
class RossHook : public Indicator
  {
public:
   RossHook(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="Ross Hook";

      WarningMessage    = "";
      IsAllowLTF        = true;
      ExecTime          = ExecutionTime_DuringTheBar;
      IsSeparateChart   = false;
      IsDiscreteValues  = false;
      IsDefaultGroupAll = false;
     }

   virtual void Calculate(DataSet &dataSet);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RossHook::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

   double adRhUp[];  ArrayResize(adRhUp,Data.Bars); ArrayInitialize(adRhUp,0);
   double adRhDn[];  ArrayResize(adRhDn,Data.Bars); ArrayInitialize(adRhDn,0);

   for(int bar=5; bar<Data.Bars-1; bar++)
     {
      if(Data.High[bar]<Data.High[bar-1])
         if(Data.High[bar-3]<Data.High[bar-1] && Data.High[bar-2]<Data.High[bar-1])
            adRhUp[bar+1]=Data.High[bar-1];

      if(Data.Low[bar]>Data.Low[bar-1])
         if(Data.Low[bar-3]>Data.Low[bar-1] && Data.Low[bar-2]>Data.Low[bar-1])
            adRhDn[bar+1]=Data.Low[bar-1];
     }

// Is visible
   for(int bar=5; bar<Data.Bars; bar++)
     {
      if(adRhUp[bar-1]>0 && MathAbs(adRhUp[bar]-0)<Epsilon() && Data.High[bar-1]<adRhUp[bar-1])
         adRhUp[bar]=adRhUp[bar-1];
      if(adRhDn[bar-1]>0 && MathAbs(adRhDn[bar]-0)<Epsilon() && Data.Low[bar-1]>adRhDn[bar-1])
         adRhDn[bar]=adRhDn[bar-1];
     }

// Saving the components

   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].FirstBar=5;
   ArrayCopy(Component[0].Value,adRhUp);

   ArrayResize(Component[1].Value,Data.Bars);
   Component[1].FirstBar=5;
   ArrayCopy(Component[1].Value,adRhDn);

// Sets the Component's type
   if(SlotType==SlotTypes_Open)
     {
      if(ListParam[0].Text=="Enter long at Up Ross hook")
        {
         Component[0].DataType = IndComponentType_OpenLongPrice;
         Component[1].DataType = IndComponentType_OpenShortPrice;
        }
      else
        {
         Component[0].DataType = IndComponentType_OpenShortPrice;
         Component[1].DataType = IndComponentType_OpenLongPrice;
        }
      Component[0].CompName = "Up Ross hook";
      Component[1].CompName = "Down Ross hook";
     }
   else if(SlotType==SlotTypes_Close)
     {
      if(ListParam[0].Text=="Exit long at Up Ross hook")
        {
         Component[0].DataType = IndComponentType_CloseLongPrice;
         Component[1].DataType = IndComponentType_CloseShortPrice;
        }
      else
        {
         Component[0].DataType = IndComponentType_CloseShortPrice;
         Component[1].DataType = IndComponentType_CloseLongPrice;
        }
      Component[0].CompName = "Up Ross hook";
      Component[1].CompName = "Down Ross hook";
     }
  }
//+------------------------------------------------------------------+
