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
class DayOfMonth : public Indicator
  {
public:
   DayOfMonth(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="Day of Month";

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
void DayOfMonth::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

// Reading the parameters
   int iFromDay  = (int)NumParam[0].Value;
   int iUntilDay = (int)NumParam[1].Value;

// Calculation
   int iFirstBar=1;
   double adBars[]; ArrayResize(adBars,Data.Bars); ArrayInitialize(adBars,0);

// Calculation of the logic
   for(int bar=iFirstBar; bar<Data.Bars; bar++)
     {
      MqlDateTime time; TimeToStruct(Data.Time[bar], time);
      if(iFromDay<iUntilDay)
         adBars[bar]=time.day>=iFromDay && time.day<iUntilDay ? 1 : 0;
      else if(iFromDay>iUntilDay)
         adBars[bar]=time.day>=iFromDay || time.day<iUntilDay ? 1 : 0;
      else
         adBars[bar]=1;
     }

// Saving the components
   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName      = "Allow long entry";
   Component[0].DataType      = IndComponentType_AllowOpenLong;
   Component[0].ShowInDynInfo = false;
   Component[0].FirstBar      = iFirstBar;
   ArrayCopy(Component[0].Value,adBars);

   ArrayResize(Component[1].Value,Data.Bars);
   Component[1].CompName      = "Allow short entry";
   Component[1].DataType      = IndComponentType_AllowOpenShort;
   Component[1].ShowInDynInfo = false;
   Component[1].FirstBar      = iFirstBar;
   ArrayCopy(Component[1].Value,adBars);
  }
//+------------------------------------------------------------------+
