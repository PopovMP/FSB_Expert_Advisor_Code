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
class ExitHour : public Indicator
  {
public:
    ExitHour(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="Exit Hour";

      WarningMessage="Exit Hour indicator works properly on 4H and lower time frame."+"\n"+
                     "It sends close signal when bar closes at the specified hour.";
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
void ExitHour::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

// Reading the parameters
   int exitHour=(int) NumParam[0].Value;

// Calculation
   const int firstBar=1;
   double adBars[];
   ArrayResize(adBars,Data.Bars);
   ArrayInitialize(adBars,0);

// Calculation of the logic
   for(int bar=firstBar; bar<Data.Bars; bar++)
     {
      MqlDateTime mqlTime1; TimeToStruct(Data.Time[bar-1],mqlTime1);
      MqlDateTime mqlTime0; TimeToStruct(Data.Time[bar],mqlTime0);

      if(mqlTime1.day_of_year==mqlTime0.day_of_year && mqlTime1.hour<exitHour && mqlTime0.hour>=exitHour)
         adBars[bar-1]=Data.Close[bar-1];
      else if(mqlTime1.day_of_year!=mqlTime0.day_of_year && mqlTime1.hour<exitHour)
         adBars[bar-1]=Data.Close[bar-1];
      else
         adBars[bar]=0;
     }

// Check the last bar
   MqlDateTime mqlTime1; TimeToStruct(Data.Time[Data.Bars-1],mqlTime1);
   if(mqlTime1.hour==exitHour)
      adBars[Data.Bars-1]=Data.Close[Data.Bars-1];

// Saving the components
   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "Exit hour";
   Component[0].DataType = IndComponentType_ClosePrice;
   Component[0].ShowInDynInfo=false;
   Component[0].FirstBar=firstBar;
   ArrayCopy(Component[0].Value,adBars);
  }
//+------------------------------------------------------------------+
