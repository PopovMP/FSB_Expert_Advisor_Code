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
class DayClosing2 : public Indicator
  {
public:
    DayClosing2(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="Day Closing 2";

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
void DayClosing2::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

// Reading the parameters
   int dayClosingHour    = (int) NumParam[0].Value;
   int dayClosingMin     = (int) NumParam[1].Value;
   int fridayClosingHour = (int) NumParam[2].Value;
   int fridayClosingMin  = (int) NumParam[3].Value;

// Calculation
   double adClosePrice[]; ArrayResize(adClosePrice,Data.Bars); ArrayInitialize(adClosePrice,0);

   for(int bar=1; bar<Data.Bars; bar++)
     {
      MqlDateTime time0; TimeToStruct(Data.Time[bar - 0], time0);
      MqlDateTime time1; TimeToStruct(Data.Time[bar - 1], time1);
      if(time1.day!=time0.day)
         adClosePrice[bar-1]=Data.Close[bar-1];
     }

   double adAllowOpenLong[];
   ArrayResize(adAllowOpenLong,Data.Bars);
   ArrayInitialize(adAllowOpenLong,1);
   double adAllowOpenShort[];
   ArrayResize(adAllowOpenShort,Data.Bars);
   ArrayInitialize(adAllowOpenShort,1);

// Check the last bar
   datetime dayOpeningTime=(Data.ServerTime/86400)*86400;

   MqlDateTime mqlCloseTime;
   TimeToStruct(Data.ServerTime,mqlCloseTime);

   datetime closeTime=mqlCloseTime.day_of_week==5
                      ? dayOpeningTime+fridayClosingHour*3600+fridayClosingMin*60
                      : dayOpeningTime+dayClosingHour*3600+dayClosingMin*60;

   if(Data.ServerTime>=closeTime)
     {
      adClosePrice[Data.Bars-1]=Data.Close[Data.Bars-1];
      adAllowOpenLong[Data.Bars-1]=0;  // Prevent entries after closing time
      adAllowOpenShort[Data.Bars-1]=0; // Prevent entries after closing time
     }

// Saving the components
   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "Closing price of the day";
   Component[0].DataType = IndComponentType_ClosePrice;
   Component[0].FirstBar = 2;
   ArrayCopy(Component[0].Value,adClosePrice);

   ArrayResize(Component[1].Value,Data.Bars);
   Component[1].DataType = IndComponentType_AllowOpenLong;
   Component[1].CompName = "Is long entry allowed";
   Component[1].ShowInDynInfo=false;
   Component[1].FirstBar=2;
   ArrayCopy(Component[1].Value,adAllowOpenLong);

   ArrayResize(Component[2].Value,Data.Bars);
   Component[2].DataType = IndComponentType_AllowOpenShort;
   Component[2].CompName = "Is short entry allowed";
   Component[2].ShowInDynInfo=false;
   Component[2].FirstBar=2;
   ArrayCopy(Component[2].Value,adAllowOpenShort);
  }
//+------------------------------------------------------------------+
