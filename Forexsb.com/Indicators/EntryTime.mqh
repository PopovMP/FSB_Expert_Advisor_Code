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
class EntryTime : public Indicator
  {
public:
                     EntryTime(SlotTypes slotType);
   virtual void      Calculate(DataSet &dataSet);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EntryTime::EntryTime(SlotTypes slotType)
  {
   SlotType          = slotType;
   IndicatorName     = "Entry Time";
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
void EntryTime::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

   int fromHour  = (int) NumParam[0].Value;
   int fromMin   = (int) NumParam[1].Value;
   int untilHour = (int) NumParam[2].Value;
   int untilMin  = (int) NumParam[3].Value;

   const int firstBar=2;
   double adBars[]; ArrayResize(adBars,Data.Bars);ArrayInitialize(adBars,0);

   int fromTime  = fromHour*3600+fromMin*60;
   int untilTime = untilHour*3600+untilMin*60;

   for(int bar=firstBar; bar<Data.Bars; bar++)
     {
      MqlDateTime mqlTime; TimeToStruct(Data.Time[bar],mqlTime);
      int barTime=mqlTime.hour*3600+mqlTime.min*60;

      if(fromTime<untilTime)
         adBars[bar]=barTime>=fromTime && barTime<untilTime ? 1 : 0;
      else if(fromTime>untilTime)
         adBars[bar]=barTime>=fromTime || barTime<untilTime ? 1 : 0;
      else adBars[bar]=1;
     }

   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "Is long entry allowed";
   Component[0].DataType = IndComponentType_AllowOpenLong;
   Component[0].ShowInDynInfo=false;
   Component[0].FirstBar=firstBar;
   ArrayCopy(Component[0].Value,adBars);

   ArrayResize(Component[1].Value,Data.Bars);
   Component[1].CompName = "Is short entry allowed";
   Component[1].DataType = IndComponentType_AllowOpenShort;
   Component[1].ShowInDynInfo=false;
   Component[1].FirstBar=firstBar;
   ArrayCopy(Component[1].Value,adBars);
  }
//+------------------------------------------------------------------+
