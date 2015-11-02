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
class VidyaMovingAverage : public Indicator
  {
public:
   VidyaMovingAverage(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="Vidya Moving Average";

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
void VidyaMovingAverage::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

// Reading the parameters
   BasePrice basePrice=(BasePrice)ListParam[2].Index;
   int iPeriod  = (int)NumParam[0].Value;
   int iSmooth  = (int)NumParam[1].Value;
   int iPrvs    = CheckParam[0].Checked ? 1 : 0;

// Calculation
   int iFirstBar=iPeriod+iSmooth+1+iPrvs;

// Calculating Chande Momentum Oscillator
   double adBasePrice[];
   Price(basePrice,adBasePrice);

   double adCMO1[]; ArrayResize(adCMO1,Data.Bars); ArrayInitialize(adCMO1,0);
   double adCMO2[]; ArrayResize(adCMO2,Data.Bars); ArrayInitialize(adCMO2,0);

   for(int iBar=1; iBar<Data.Bars; iBar++)
     {
      adCMO1[iBar] = 0;
      adCMO1[iBar] = 0;
      if(adBasePrice[iBar]>adBasePrice[iBar-1])
         adCMO1[iBar]=adBasePrice[iBar]-adBasePrice[iBar-1];
      if(adBasePrice[iBar]<adBasePrice[iBar-1])
         adCMO2[iBar]=adBasePrice[iBar-1]-adBasePrice[iBar];
     }

   double adCMO1Sum[]; ArrayResize(adCMO1Sum,Data.Bars); ArrayInitialize(adCMO1Sum,0);
   double adCMO2Sum[]; ArrayResize(adCMO2Sum,Data.Bars); ArrayInitialize(adCMO2Sum,0);

   for(int iBar=0; iBar<iPeriod; iBar++)
     {
      adCMO1Sum[iPeriod - 1] += adCMO1[iBar];
      adCMO2Sum[iPeriod - 1] += adCMO2[iBar];
     }

   double adCMO[]; ArrayResize(adCMO,Data.Bars); ArrayInitialize(adCMO,0);

   for(int iBar=iPeriod; iBar<Data.Bars; iBar++)
     {
      adCMO1Sum[iBar] = adCMO1Sum[iBar - 1] + adCMO1[iBar] - adCMO1[iBar - iPeriod];
      adCMO2Sum[iBar] = adCMO2Sum[iBar - 1] + adCMO2[iBar] - adCMO2[iBar - iPeriod];

      if(adCMO1Sum[iBar]+adCMO2Sum[iBar]==0)
         adCMO[iBar]=100;
      else
         adCMO[iBar]=100 *(adCMO1Sum[iBar]-adCMO2Sum[iBar])/(adCMO1Sum[iBar]+adCMO2Sum[iBar]);
     }

   double adMA[]; ArrayResize(adMA,Data.Bars); ArrayInitialize(adMA,0);
   double SC=2.0/(iSmooth+1);

   for(int iBar=0; iBar<iPeriod; iBar++)
      adMA[iBar]=adBasePrice[iBar];

   for(int iBar=iPeriod; iBar<Data.Bars; iBar++)
     {
      double dAbsCMO=MathAbs(adCMO[iBar])/100;
      adMA[iBar]=SC*dAbsCMO*adBasePrice[iBar]+(1-SC*dAbsCMO)*adMA[iBar-1];
     }

// Saving the components
   if(SlotType==SlotTypes_Open || SlotType==SlotTypes_Close)
     {

      ArrayResize(Component[1].Value,Data.Bars);

      for(int iBar=2; iBar<Data.Bars; iBar++)
        {   // Covers the cases when the price can pass through the MA without a signal
         double dValue   = adMA[iBar - iPrvs];     // Current value
         double dValue1  = adMA[iBar - iPrvs - 1]; // Previous value
         double dTempVal = dValue;
         if((dValue1>Data.High[iBar-1] && dValue<Data.Open[iBar]) || // It jumps below the current bar
            (dValue1<Data.Low[iBar-1] && dValue>Data.Open[iBar]) || // It jumps above the current bar
            (Data.Close[iBar - 1] < dValue && dValue < Data.Open[iBar]) || // Positive gap
            (Data.Close[iBar - 1] > dValue && dValue > Data.Open[iBar]))   // Negative gap
            dTempVal=Data.Open[iBar];
         Component[1].Value[iBar]=dTempVal;
        }
     }
   else
     {
      ArrayResize(Component[1].Value,Data.Bars);
      Component[1].FirstBar=iFirstBar;

      ArrayResize(Component[2].Value,Data.Bars);
      Component[2].FirstBar=iFirstBar;
     }

   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName   = "MA Value";
   Component[0].DataType   = IndComponentType_IndicatorValue;
   Component[0].FirstBar   = iFirstBar;
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
         IndicatorRisesLogic(iFirstBar,iPrvs,adMA,Component[1],Component[2]);
      else if(ListParam[0].Text=="The Vidya Moving Average falls")
         IndicatorFallsLogic(iFirstBar,iPrvs,adMA,Component[1],Component[2]);
      else if(ListParam[0].Text=="The bar opens above the Vidya Moving Average")
         BarOpensAboveIndicatorLogic(iFirstBar,iPrvs,adMA,Component[1],Component[2]);
      else if(ListParam[0].Text=="The bar opens below the Vidya Moving Average")
         BarOpensBelowIndicatorLogic(iFirstBar,iPrvs,adMA,Component[1],Component[2]);
      else if(ListParam[0].Text=="The bar opens above the Vidya Moving Average after opening below it")
         BarOpensAboveIndicatorAfterOpeningBelowLogic(iFirstBar,iPrvs,adMA,Component[1],Component[2]);
      else if(ListParam[0].Text=="The bar opens below the Vidya Moving Average after opening above it")
         BarOpensBelowIndicatorAfterOpeningAboveLogic(iFirstBar,iPrvs,adMA,Component[1],Component[2]);
      else if(ListParam[0].Text=="The position opens above the Vidya Moving Average")
        {
         Component[0].PosPriceDependence=PositionPriceDependence_BuyHigherSellLower;
         Component[0].UsePreviousBar=iPrvs;
         Component[1].DataType=IndComponentType_Other;
         Component[1].ShowInDynInfo=false;
         Component[2].DataType=IndComponentType_Other;
         Component[2].ShowInDynInfo=false;
        }
      else if(ListParam[0].Text=="The position opens below the Vidya Moving Average")
        {
         Component[0].PosPriceDependence=PositionPriceDependence_BuyLowerSelHigher;
         Component[0].UsePreviousBar=iPrvs;
         Component[1].DataType=IndComponentType_Other;
         Component[1].ShowInDynInfo=false;
         Component[2].DataType=IndComponentType_Other;
         Component[2].ShowInDynInfo=false;
        }
      else if(ListParam[0].Text=="The bar closes below the Vidya Moving Average")
         BarClosesBelowIndicatorLogic(iFirstBar,iPrvs,adMA,Component[1],Component[2]);
      else if(ListParam[0].Text=="The bar closes above the Vidya Moving Average")
         BarClosesAboveIndicatorLogic(iFirstBar,iPrvs,adMA,Component[1],Component[2]);
     }
  }
//+------------------------------------------------------------------+
