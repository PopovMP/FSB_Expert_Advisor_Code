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
class EntryHour : public Indicator
  {
public:
                     EntryHour(SlotTypes slotType);
   virtual void      Calculate(DataSet &dataSet);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EntryHour::EntryHour(SlotTypes slotType)
  {
   SlotType          = slotType;
   IndicatorName     = "Entry Hour";
   WarningMessage    = "";
   IsAllowLTF        = true;
   ExecTime          = ExecutionTime_DuringTheBar;
   IsSeparateChart   = false;
   IsDiscreteValues  = false;
   IsDefaultGroupAll = true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EntryHour::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

   int entryHour   = (int) NumParam[0].Value;
   int entryMinute = (int) NumParam[1].Value;

   const int firstBar=2;
   double adBars[]; ArrayResize(adBars,Data.Bars);ArrayInitialize(adBars,0);

   for(int bar=firstBar; bar<Data.Bars; bar++)
     {
      MqlDateTime mqlTime; TimeToStruct(Data.Time[bar],mqlTime);
      bool isTime = (mqlTime.hour == entryHour && mqlTime.min == entryMinute);
      adBars[bar] = isTime ? Data.Open[bar] : 0;
     }

   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "Entry hour";
   Component[0].DataType = IndComponentType_OpenPrice;
   Component[0].ShowInDynInfo=false;
   Component[0].FirstBar=firstBar;
   ArrayCopy(Component[0].Value,adBars);
  }
//+------------------------------------------------------------------+
