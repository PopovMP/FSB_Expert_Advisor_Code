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
#property version   "2.1"
#property strict

#include <Forexsb.com/Indicator.mqh>
#include <Forexsb.com/Enumerations.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class RoundNumber : public Indicator
  {
public:
    RoundNumber(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="Round Number";

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
void RoundNumber::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

// Reading the parameters
   double shift=NumParam[0].Value*Data.Point;
   int digids=(int) NumParam[1].Value;

// Calculation
   double upperRn[]; ArrayResize(upperRn,Data.Bars); ArrayInitialize(upperRn,0);
   double lowerRn[]; ArrayResize(lowerRn,Data.Bars); ArrayInitialize(lowerRn,0);

   const int firstBar=2;

   for(int bar=1; bar<Data.Bars; bar++)
     {
      double dNearestRound;

      int iCutDigids = Data.Digits - digids;
      if(iCutDigids >= 0)
         dNearestRound=NormalizeDouble(Data.Open[bar],iCutDigids);
      else
         dNearestRound=MathRound(Data.Open[bar]*MathPow(10,iCutDigids))/MathPow(10,iCutDigids);

      if(dNearestRound<Data.Open[bar])
        {
         upperRn[bar] = dNearestRound + (Data.Point*MathPow(10, digids));
         lowerRn[bar] = dNearestRound;
        }
      else
        {
         upperRn[bar] = dNearestRound;
         lowerRn[bar] = dNearestRound - (Data.Point*MathPow(10, digids));
        }
     }

// Saving the components
   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "Higher round number";
   Component[0].DataType = IndComponentType_IndicatorValue;
   Component[0].FirstBar = firstBar;
   ArrayCopy(Component[0].Value,upperRn);

   ArrayResize(Component[1].Value,Data.Bars);
   Component[1].CompName = "Lower round number";
   Component[1].DataType = IndComponentType_IndicatorValue;
   Component[1].FirstBar = firstBar;
   ArrayCopy(Component[1].Value,lowerRn);

   ArrayResize(Component[2].Value,Data.Bars);
   Component[2].FirstBar=firstBar;

   ArrayResize(Component[3].Value,Data.Bars);
   Component[3].FirstBar=firstBar;

   if(SlotType==SlotTypes_Open)
     {
      Component[2].CompName = "Long position entry price";
      Component[2].DataType = IndComponentType_OpenLongPrice;
      Component[3].CompName = "Short position entry price";
      Component[3].DataType = IndComponentType_OpenShortPrice;
     }
   else if(SlotType==SlotTypes_Close)
     {
      Component[2].CompName = "Long position closing price";
      Component[2].DataType = IndComponentType_CloseLongPrice;
      Component[3].CompName = "Short position closing price";
      Component[3].DataType = IndComponentType_CloseShortPrice;
     }

   if(ListParam[0].Text=="Enter long at the higher round number" || ListParam[0].Text=="Exit long at the higher round number")
      for(int bar=firstBar; bar<Data.Bars; bar++)
        {
         Component[2].Value[bar] = upperRn[bar] + shift;
         Component[3].Value[bar] = lowerRn[bar] - shift;
        }
   if(ListParam[0].Text=="Enter long at the lower round number" || ListParam[0].Text=="Exit long at the lower round number")
      for(int bar=firstBar; bar<Data.Bars; bar++)
        {
         Component[2].Value[bar] = lowerRn[bar] - shift;
         Component[3].Value[bar] = upperRn[bar] + shift;
        }
  }
//+------------------------------------------------------------------+
