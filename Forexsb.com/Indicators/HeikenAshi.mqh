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
class HeikenAshi : public Indicator
  {
public:
    HeikenAshi(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="Heiken Ashi";

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
void HeikenAshi::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

   int previous=CheckParam[0].Checked ? 1 : 0;

   double adHaOpen[];  ArrayResize(adHaOpen,Data.Bars);  ArrayInitialize(adHaOpen,0);
   double adHaHigh[];  ArrayResize(adHaHigh,Data.Bars);  ArrayInitialize(adHaHigh,0);
   double adHaLow[];   ArrayResize(adHaLow,Data.Bars);   ArrayInitialize(adHaLow,0);
   double adHaClose[]; ArrayResize(adHaClose,Data.Bars); ArrayInitialize(adHaClose,0);

   adHaOpen[0] = Data.Open[0];
   adHaHigh[0] = Data.High[0];
   adHaLow[0]  = Data.Low[0];
   adHaClose[0]= Data.Close[0];

   int firstBar=previous+1;

   for(int bar=1; bar<Data.Bars; bar++)
     {
      adHaClose[bar]= (Data.Open[bar]+Data.High[bar]+Data.Low[bar]+Data.Close[bar])/4;
      adHaOpen[bar] = (adHaOpen[bar-1] + adHaClose[bar-1])/2;
      adHaHigh[bar] = Data.High[bar] > adHaOpen[bar] ? Data.High[bar] : adHaOpen[bar];
      adHaHigh[bar] = adHaClose[bar] > adHaHigh[bar] ? adHaClose[bar] : adHaHigh[bar];
      adHaLow[bar]  = Data.Low[bar]  < adHaOpen[bar] ? Data.Low[bar]  : adHaOpen[bar];
      adHaLow[bar]  = adHaClose[bar] < adHaLow[bar]  ? adHaClose[bar] : adHaLow[bar];
     }

   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "H.A. Open";
   Component[0].DataType = IndComponentType_IndicatorValue;
   Component[0].FirstBar = firstBar;
   ArrayCopy(Component[0].Value,adHaOpen);

   ArrayResize(Component[1].Value,Data.Bars);
   Component[1].CompName = "H.A. High";
   Component[1].DataType = IndComponentType_IndicatorValue;
   Component[1].FirstBar = firstBar;
   ArrayCopy(Component[1].Value,adHaHigh);

   ArrayResize(Component[2].Value,Data.Bars);
   Component[2].CompName = "H.A. Low";
   Component[2].DataType = IndComponentType_IndicatorValue;
   Component[2].FirstBar = firstBar;
   ArrayCopy(Component[2].Value,adHaLow);

   ArrayResize(Component[3].Value,Data.Bars);
   Component[3].CompName = "H.A. Close";
   Component[3].DataType = IndComponentType_IndicatorValue;
   Component[3].FirstBar = firstBar;
   ArrayCopy(Component[3].Value,adHaClose);

   ArrayResize(Component[4].Value,Data.Bars);
   Component[4].FirstBar=firstBar;

   ArrayResize(Component[5].Value,Data.Bars);
   Component[5].FirstBar=firstBar;

   if(SlotType==SlotTypes_Open)
     {
      Component[4].DataType = IndComponentType_OpenLongPrice;
      Component[4].CompName = "Long position entry price";
      Component[5].DataType = IndComponentType_OpenShortPrice;
      Component[5].CompName = "Short position entry price";
     }
   else if(SlotType==SlotTypes_OpenFilter)
     {
      Component[4].DataType = IndComponentType_AllowOpenLong;
      Component[4].CompName = "Is long entry allowed";
      Component[5].DataType = IndComponentType_AllowOpenShort;
      Component[5].CompName = "Is short entry allowed";
     }
   else if(SlotType==SlotTypes_Close)
     {
      Component[4].DataType = IndComponentType_CloseLongPrice;
      Component[4].CompName = "Long position closing price";
      Component[5].DataType = IndComponentType_CloseShortPrice;
      Component[5].CompName = "Short position closing price";
     }
   else if(SlotType==SlotTypes_CloseFilter)
     {
      Component[4].DataType = IndComponentType_ForceCloseLong;
      Component[4].CompName = "Close out long position";
      Component[5].DataType = IndComponentType_ForceCloseShort;
      Component[5].CompName = "Close out short position";
     }

   if(SlotType==SlotTypes_Open || SlotType==SlotTypes_Close)
     {
      for(int bar=2; bar<Data.Bars; bar++)
        {
         if(ListParam[0].Text=="Enter long at the H.A. High" || ListParam[0].Text=="Exit long at the H.A. High")
           {
            Component[4].Value[bar] = adHaHigh[bar - previous];
            Component[5].Value[bar] = adHaLow[bar - previous];
           }
         else
           {
            Component[4].Value[bar] = adHaLow[bar - previous];
            Component[5].Value[bar] = adHaHigh[bar - previous];
           }
        }
     }
   else
     {
      if(ListParam[0].Text=="White H.A. bar without lower shadow")
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            Component[4].Value[bar]=adHaClose[bar-previous]>adHaOpen[bar-previous] && MathAbs(adHaLow[bar-previous]-adHaOpen[bar-previous])< Epsilon() ? 1 : 0;
            Component[5].Value[bar]=adHaClose[bar-previous]<adHaOpen[bar-previous] && MathAbs(adHaHigh[bar-previous]-adHaOpen[bar-previous])< Epsilon() ? 1 : 0;
           }
      else if(ListParam[0].Text=="White H.A. bar")
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            Component[4].Value[bar] = adHaClose[bar - previous] > adHaOpen[bar - previous] ? 1 : 0;
            Component[5].Value[bar] = adHaClose[bar - previous] < adHaOpen[bar - previous] ? 1 : 0;
           }
      else if(ListParam[0].Text=="Black H.A. bar")
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            Component[4].Value[bar] = adHaClose[bar - previous] < adHaOpen[bar - previous] ? 1 : 0;
            Component[5].Value[bar] = adHaClose[bar - previous] > adHaOpen[bar - previous] ? 1 : 0;
           }
      else if(ListParam[0].Text=="Black H.A. bar without upper shadow")
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            Component[4].Value[bar]=adHaClose[bar-previous]<adHaOpen[bar-previous] && MathAbs(adHaHigh[bar-previous]-adHaOpen[bar-previous])< Epsilon() ? 1 : 0;
            Component[5].Value[bar]=adHaClose[bar-previous]>adHaOpen[bar-previous] && MathAbs(adHaLow[bar-previous]-adHaOpen[bar-previous])< Epsilon() ? 1 : 0;
           }
     }
  }
//+------------------------------------------------------------------+
