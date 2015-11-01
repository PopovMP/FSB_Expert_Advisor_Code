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
class WeekClosing : public Indicator
  {
public:
    WeekClosing(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="Week Closing";

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
void WeekClosing::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

// Calculation
   const int firstBar=1;
   double adClosePrice[];
   ArrayResize(adClosePrice,Data.Bars);
   ArrayInitialize(adClosePrice,0);

// Calculation of the logic
   for(int bar=0; bar<Data.Bars-1; bar++)
     {
      MqlDateTime time0; TimeToStruct(Data.Time[bar+0], time0);
      MqlDateTime time1; TimeToStruct(Data.Time[bar+1], time1);
      if(time0.day_of_week>3 && time1.day_of_week<3)
         adClosePrice[bar]=Data.Close[bar];
     }
// Check the last bar
   datetime time=Data.Time[Data.Bars-1];
   datetime tsBarClosing = time + Data.Period*60;
   datetime tsDayClosing = (time/86400)*86400 + 86400;
   MqlDateTime mqlTime; TimeToStruct(time,mqlTime);
   if(mqlTime.day_of_week==5 && tsBarClosing==tsDayClosing)
      adClosePrice[Data.Bars-1]=Data.Close[Data.Bars-1];

// Saving the components
   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "Week Closing";
   Component[0].DataType = IndComponentType_ClosePrice;
   Component[0].ShowInDynInfo=false;
   Component[0].FirstBar=firstBar;
   ArrayCopy(Component[0].Value,adClosePrice);
  }
//+------------------------------------------------------------------+
