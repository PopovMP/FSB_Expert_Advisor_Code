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
class PreviousHighLow : public Indicator
  {
public:
    PreviousHighLow(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="Previous High Low";

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
void PreviousHighLow::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

   double dShift=NumParam[0].Value*Data.Point;

// Calculation
   double adHighPrice[]; ArrayResize(adHighPrice,Data.Bars); ArrayInitialize(adHighPrice,0);
   double adLowPrice[];  ArrayResize(adLowPrice,Data.Bars);  ArrayInitialize(adLowPrice,0);

   const int firstBar=2;

   for(int iBar=firstBar; iBar<Data.Bars; iBar++)
     {
      adHighPrice[iBar]= Data.High[iBar-1];
      adLowPrice[iBar] = Data.Low[iBar-1];
     }

   double adUpperBand[]; ArrayResize(adUpperBand,Data.Bars); ArrayInitialize(adUpperBand,0);
   double adLowerBand[]; ArrayResize(adLowerBand,Data.Bars); ArrayInitialize(adLowerBand,0);
   for(int bar=firstBar; bar<Data.Bars; bar++)
     {
      adUpperBand[bar] = adHighPrice[bar] + dShift;
      adLowerBand[bar] = adLowPrice[bar] - dShift;
     }

// Saving the components
   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "Previous High";
   Component[0].DataType = IndComponentType_IndicatorValue;
   Component[0].FirstBar = firstBar;
   ArrayCopy(Component[0].Value,adHighPrice);

   ArrayResize(Component[1].Value,Data.Bars);
   Component[1].CompName = "Previous Low";
   Component[1].DataType = IndComponentType_IndicatorValue;
   Component[1].FirstBar = firstBar;
   ArrayCopy(Component[1].Value,adLowPrice);

   ArrayResize(Component[2].Value,Data.Bars);
   Component[2].FirstBar=firstBar;

   ArrayResize(Component[3].Value,Data.Bars);
   Component[3].FirstBar=firstBar;

// Sets the Component's type
   if(SlotType==SlotTypes_Open)
     {
      Component[2].CompName = "Long position entry price";
      Component[2].DataType = IndComponentType_OpenLongPrice;
      Component[3].CompName = "Short position entry price";
      Component[3].DataType = IndComponentType_OpenShortPrice;
     }
   else if(SlotType==SlotTypes_OpenFilter)
     {
      Component[2].CompName = "Is long entry allowed";
      Component[2].DataType = IndComponentType_AllowOpenLong;
      Component[3].CompName = "Is short entry allowed";
      Component[3].DataType = IndComponentType_AllowOpenShort;
     }
   else if(SlotType==SlotTypes_Close)
     {
      Component[2].CompName = "Long position closing price";
      Component[2].DataType = IndComponentType_CloseLongPrice;
      Component[3].CompName = "Short position closing price";
      Component[3].DataType = IndComponentType_CloseShortPrice;
     }
   else if(SlotType==SlotTypes_CloseFilter)
     {
      Component[2].CompName = "Close out long position";
      Component[2].DataType = IndComponentType_ForceCloseLong;
      Component[3].CompName = "Close out short position";
      Component[3].DataType = IndComponentType_ForceCloseShort;
     }

   if(ListParam[0].Text=="Enter long at the previous high" || ListParam[0].Text=="Exit long at the previous high")
     {
      ArrayCopy(Component[2].Value, adUpperBand);
      ArrayCopy(Component[3].Value, adLowerBand);
     }
   else if(ListParam[0].Text=="Enter long at the previous low" || ListParam[0].Text=="Exit long at the previous low")
     {
      ArrayCopy(Component[2].Value, adLowerBand);
      ArrayCopy(Component[3].Value, adUpperBand);
     }
   else if(ListParam[0].Text=="The bar opens below the previous high")
      BandIndicatorLogic(firstBar,0,adUpperBand,adLowerBand,Component[2],Component[3],BandIndLogic_The_bar_opens_below_the_Upper_Band);
   else if(ListParam[0].Text=="The bar opens above the previous high")
      BandIndicatorLogic(firstBar,0,adUpperBand,adLowerBand,Component[2],Component[3],BandIndLogic_The_bar_opens_above_the_Upper_Band);
   else if(ListParam[0].Text=="The bar opens below the previous low")
      BandIndicatorLogic(firstBar,0,adUpperBand,adLowerBand,Component[2],Component[3],BandIndLogic_The_bar_opens_below_the_Lower_Band);
   else if(ListParam[0].Text=="The bar opens above the previous low")
      BandIndicatorLogic(firstBar,0,adUpperBand,adLowerBand,Component[2],Component[3],BandIndLogic_The_bar_opens_above_the_Lower_Band);
   else if(ListParam[0].Text=="The bar closes below the previous high")
      BandIndicatorLogic(firstBar,0,adUpperBand,adLowerBand,Component[2],Component[3],BandIndLogic_The_bar_closes_below_the_Upper_Band);
   else if(ListParam[0].Text=="The bar closes above the previous high")
      BandIndicatorLogic(firstBar,0,adUpperBand,adLowerBand,Component[2],Component[3],BandIndLogic_The_bar_closes_above_the_Upper_Band);
   else if(ListParam[0].Text=="The bar closes below the previous low")
      BandIndicatorLogic(firstBar,0,adUpperBand,adLowerBand,Component[2],Component[3],BandIndLogic_The_bar_closes_below_the_Lower_Band);
   else if(ListParam[0].Text=="The bar closes above the previous low")
      BandIndicatorLogic(firstBar,0,adUpperBand,adLowerBand,Component[2],Component[3],BandIndLogic_The_bar_closes_above_the_Lower_Band);
   else if(ListParam[0].Text=="The position opens above the previous high")
     {
      Component[0].DataType = IndComponentType_Other;
      Component[1].DataType = IndComponentType_Other;
      Component[2].CompName = "Shifted previous high";
      Component[2].DataType = IndComponentType_Other;
      Component[2].PosPriceDependence=PositionPriceDependence_PriceBuyHigher;
      Component[3].CompName = "Shifted previous low";
      Component[3].DataType = IndComponentType_Other;
      Component[3].PosPriceDependence=PositionPriceDependence_PriceSellLower;
      ArrayCopy(Component[2].Value, adUpperBand);
      ArrayCopy(Component[3].Value, adLowerBand);
     }
   else if(ListParam[0].Text=="The position opens below the previous high")
     {
      Component[0].DataType = IndComponentType_Other;
      Component[1].DataType = IndComponentType_Other;
      Component[2].CompName = "Shifted previous high";
      Component[2].DataType = IndComponentType_Other;
      Component[2].PosPriceDependence=PositionPriceDependence_PriceBuyLower;
      Component[3].CompName = "Shifted previous low";
      Component[3].DataType = IndComponentType_Other;
      Component[3].PosPriceDependence=PositionPriceDependence_PriceSellHigher;
      ArrayCopy(Component[2].Value, adUpperBand);
      ArrayCopy(Component[3].Value, adLowerBand);
     }
   else if(ListParam[0].Text=="The position opens above the previous low")
     {
      Component[0].DataType = IndComponentType_Other;
      Component[1].DataType = IndComponentType_Other;
      Component[2].CompName = "Shifted previous low";
      Component[2].DataType = IndComponentType_Other;
      Component[2].PosPriceDependence=PositionPriceDependence_PriceBuyHigher;
      Component[3].CompName = "Shifted previous high";
      Component[3].DataType = IndComponentType_Other;
      Component[3].PosPriceDependence=PositionPriceDependence_PriceSellLower;
      ArrayCopy(Component[2].Value, adLowerBand);
      ArrayCopy(Component[3].Value, adUpperBand);
     }
   else if(ListParam[0].Text=="The position opens below the previous low")
     {
      Component[0].DataType = IndComponentType_Other;
      Component[1].DataType = IndComponentType_Other;
      Component[2].CompName = "Shifted previous low";
      Component[2].DataType = IndComponentType_Other;
      Component[2].PosPriceDependence=PositionPriceDependence_PriceBuyLower;
      Component[3].CompName = "Shifted previous high";
      Component[3].DataType = IndComponentType_Other;
      Component[3].PosPriceDependence=PositionPriceDependence_PriceSellHigher;
      ArrayCopy(Component[2].Value, adLowerBand);
      ArrayCopy(Component[3].Value, adUpperBand);
     }
  }
//+------------------------------------------------------------------+
