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
class VidyaMovingAverage : public Indicator
  {
public:
                     VidyaMovingAverage(SlotTypes slotType);
   virtual void      Calculate(DataSet &dataSet);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void VidyaMovingAverage::VidyaMovingAverage(SlotTypes slotType)
  {
   SlotType          = slotType;
   IndicatorName     = "Vidya Moving Average";
   WarningMessage    = "";
   IsAllowLTF        = true;
   ExecTime          = ExecutionTime_DuringTheBar;
   IsSeparateChart   = false;
   IsDiscreteValues  = false;
   IsDefaultGroupAll = false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void VidyaMovingAverage::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

   BasePrice basePrice=(BasePrice)ListParam[2].Index;
   int period    = (int)NumParam[0].Value;
   int smoothing = (int)NumParam[1].Value;
   int previous  = CheckParam[0].Checked ? 1 : 0;

   int firstBar=period+smoothing+previous+2;

   double adBasePrice[];
   Price(basePrice,adBasePrice);

   double adCMO1[]; ArrayResize(adCMO1,Data.Bars); ArrayInitialize(adCMO1,0);
   double adCMO2[]; ArrayResize(adCMO2,Data.Bars); ArrayInitialize(adCMO2,0);

   for(int bar=1; bar<Data.Bars; bar++)
     {
      adCMO1[bar] = 0;
      adCMO1[bar] = 0;
      if(adBasePrice[bar]>adBasePrice[bar-1])
         adCMO1[bar]=adBasePrice[bar]-adBasePrice[bar-1];
      if(adBasePrice[bar]<adBasePrice[bar-1])
         adCMO2[bar]=adBasePrice[bar-1]-adBasePrice[bar];
     }

   double adCMO1Sum[]; ArrayResize(adCMO1Sum,Data.Bars); ArrayInitialize(adCMO1Sum,0);
   double adCMO2Sum[]; ArrayResize(adCMO2Sum,Data.Bars); ArrayInitialize(adCMO2Sum,0);

   for(int bar=0; bar<period; bar++)
     {
      adCMO1Sum[period - 1] += adCMO1[bar];
      adCMO2Sum[period - 1] += adCMO2[bar];
     }

   double adCMO[]; ArrayResize(adCMO,Data.Bars); ArrayInitialize(adCMO,0);

   for(int bar=period; bar<Data.Bars; bar++)
     {
      adCMO1Sum[bar] = adCMO1Sum[bar - 1] + adCMO1[bar] - adCMO1[bar - period];
      adCMO2Sum[bar] = adCMO2Sum[bar - 1] + adCMO2[bar] - adCMO2[bar - period];

      if(adCMO1Sum[bar]+adCMO2Sum[bar]==0)
         adCMO[bar]=100;
      else
         adCMO[bar]=100 *(adCMO1Sum[bar]-adCMO2Sum[bar])/(adCMO1Sum[bar]+adCMO2Sum[bar]);
     }

   double adMA[]; ArrayResize(adMA,Data.Bars); ArrayInitialize(adMA,0);
   double SC=2.0/(smoothing+1);

   for(int bar=0; bar<period; bar++)
      adMA[bar]=adBasePrice[bar];

   for(int bar=period; bar<Data.Bars; bar++)
     {
      double dAbsCMO=MathAbs(adCMO[bar])/100;
      adMA[bar]=SC*dAbsCMO*adBasePrice[bar]+(1-SC*dAbsCMO)*adMA[bar-1];
     }

   if(SlotType==SlotTypes_Open || SlotType==SlotTypes_Close)
     {
      ArrayResize(Component[1].Value,Data.Bars);

      for(int bar=2; bar<Data.Bars; bar++)
        {   // Covers the cases when the price can pass through the MA without a signal
         double dValue   = adMA[bar - previous];     // Current value
         double dValue1  = adMA[bar - previous - 1]; // Previous value
         double dTempVal = dValue;
         if((dValue1>Data.High[bar-1] && dValue<Data.Open[bar]) || // It jumps below the current bar
            (dValue1<Data.Low[bar-1] && dValue>Data.Open[bar]) || // It jumps above the current bar
            (Data.Close[bar - 1] < dValue && dValue < Data.Open[bar]) || // Positive gap
            (Data.Close[bar - 1] > dValue && dValue > Data.Open[bar]))   // Negative gap
            dTempVal=Data.Open[bar];
         Component[1].Value[bar]=dTempVal;
        }
     }
   else
     {
      ArrayResize(Component[1].Value,Data.Bars);
      Component[1].FirstBar=firstBar;

      ArrayResize(Component[2].Value,Data.Bars);
      Component[2].FirstBar=firstBar;
     }

   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName   = "MA Value";
   Component[0].DataType   = IndComponentType_IndicatorValue;
   Component[0].FirstBar   = firstBar;
   ArrayCopy(Component[0].Value,adMA);

   if(SlotType==SlotTypes_Open)
     {
      Component[1].CompName = "Position opening price";
      Component[1].DataType = IndComponentType_OpenPrice;
     }
   else if(SlotType==SlotTypes_OpenFilter)
     {
      Component[1].DataType = IndComponentType_AllowOpenLong;
      Component[1].CompName = "Is long entry allowed";
      Component[2].DataType = IndComponentType_AllowOpenShort;
      Component[2].CompName = "Is short entry allowed";
     }
   else if(SlotType==SlotTypes_Close)
     {
      Component[1].CompName = "Position closing price";
      Component[1].DataType = IndComponentType_ClosePrice;
     }
   else if(SlotType==SlotTypes_CloseFilter)
     {
      Component[1].DataType = IndComponentType_ForceCloseLong;
      Component[1].CompName = "Close out long position";
      Component[2].DataType = IndComponentType_ForceCloseShort;
      Component[2].CompName = "Close out short position";
     }

   if(SlotType==SlotTypes_OpenFilter || SlotType==SlotTypes_CloseFilter)
     {
      if(ListParam[0].Text=="The Vidya Moving Average rises")
         IndicatorRisesLogic(firstBar,previous,adMA,Component[1],Component[2]);
      else if(ListParam[0].Text=="The Vidya Moving Average falls")
         IndicatorFallsLogic(firstBar,previous,adMA,Component[1],Component[2]);
      else if(ListParam[0].Text=="The bar opens above the Vidya Moving Average")
         BarOpensAboveIndicatorLogic(firstBar,previous,adMA,Component[1],Component[2]);
      else if(ListParam[0].Text=="The bar opens below the Vidya Moving Average")
         BarOpensBelowIndicatorLogic(firstBar,previous,adMA,Component[1],Component[2]);
      else if(ListParam[0].Text=="The bar opens above the Vidya Moving Average after opening below it")
         BarOpensAboveIndicatorAfterOpeningBelowLogic(firstBar,previous,adMA,Component[1],Component[2]);
      else if(ListParam[0].Text=="The bar opens below the Vidya Moving Average after opening above it")
         BarOpensBelowIndicatorAfterOpeningAboveLogic(firstBar,previous,adMA,Component[1],Component[2]);
      else if(ListParam[0].Text=="The position opens above the Vidya Moving Average")
        {
         Component[0].PosPriceDependence=PositionPriceDependence_BuyHigherSellLower;
         Component[0].UsePreviousBar=previous;
         Component[1].DataType=IndComponentType_Other;
         Component[1].ShowInDynInfo=false;
         Component[2].DataType=IndComponentType_Other;
         Component[2].ShowInDynInfo=false;
        }
      else if(ListParam[0].Text=="The position opens below the Vidya Moving Average")
        {
         Component[0].PosPriceDependence=PositionPriceDependence_BuyLowerSelHigher;
         Component[0].UsePreviousBar=previous;
         Component[1].DataType=IndComponentType_Other;
         Component[1].ShowInDynInfo=false;
         Component[2].DataType=IndComponentType_Other;
         Component[2].ShowInDynInfo=false;
        }
      else if(ListParam[0].Text=="The bar closes below the Vidya Moving Average")
         BarClosesBelowIndicatorLogic(firstBar,previous,adMA,Component[1],Component[2]);
      else if(ListParam[0].Text=="The bar closes above the Vidya Moving Average")
         BarClosesAboveIndicatorLogic(firstBar,previous,adMA,Component[1],Component[2]);
     }
  }
//+------------------------------------------------------------------+
