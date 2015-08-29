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
class DayOpening : public Indicator
  {
public:
    DayOpening(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="Day Opening";

      WarningMessage    = "";
      IsAllowLTF        = true;
      ExecTime          = ExecutionTime_AtBarOpening;
      IsSeparateChart   = false;
      IsDiscreteValues  = false;
      IsDeafultGroupAll = false;
     }

   virtual void Calculate(DataSet &dataSet);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DayOpening::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

// Calculation
   double openPrice[]; ArrayResize(openPrice,Data.Bars); ArrayInitialize(openPrice, 0);

   for(int bar=1; bar<Data.Bars; bar++)
     {
      MqlDateTime time0; TimeToStruct(Data.Time[bar-0], time0);
      MqlDateTime time1; TimeToStruct(Data.Time[bar-1], time1);
      if(time0.day!=time1.day)
         openPrice[bar]=Data.Open[bar];
     }

// Saving the components
   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "Opening price of the day";
   Component[0].DataType = IndComponentType_OpenPrice;
   Component[0].FirstBar = 2;
   ArrayCopy(Component[0].Value,openPrice);
  }
//+------------------------------------------------------------------+
