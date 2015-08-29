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
class TopBottomPrice : public Indicator
  {
private:
   bool IsPeriodChanged(int bar);
public:
    TopBottomPrice(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="Top Bottom Price";

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
bool TopBottomPrice::IsPeriodChanged(int bar)
  {
   bool isPeriodChanged=false;
   MqlDateTime time0; TimeToStruct(Data.Time[bar-0], time0);
   MqlDateTime time1; TimeToStruct(Data.Time[bar-1], time1);
   switch(ListParam[2].Index)
     {
      case 0: // Previous bar
         isPeriodChanged=true;
         break;
      case 1: // Previous day
         isPeriodChanged=(time0.day!=time1.day);
         break;
      case 2: // Previous week
         isPeriodChanged=(Data.Period==DataPeriod_W1) || (time0.day_of_week<=3 && time1.day_of_week>3);
         break;
      case 3: // Previous month
         isPeriodChanged=(time0.mon!=time1.mon);
         break;
     }

   return isPeriodChanged;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TopBottomPrice::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

// Reading the parameters
   double shift=NumParam[0].Value*Data.Point;
   const int firstBar=1;

// Calculation
   double topPrice[];    ArrayResize(topPrice,Data.Bars);    ArrayInitialize(topPrice,0);
   double bottomPrice[]; ArrayResize(bottomPrice,Data.Bars); ArrayInitialize(bottomPrice,0);

   double top=DBL_MIN;
   double bottom=DBL_MAX;

   for(int bar=1; bar<Data.Bars; bar++)
     {
      if(Data.High[bar-1]>top)
         top=Data.High[bar-1];
      if(Data.Low[bar-1]<bottom)
         bottom=Data.Low[bar-1];

      if(IsPeriodChanged(bar))
        {
         topPrice[bar]=top;
         bottomPrice[bar]=bottom;
         top=DBL_MIN;
         bottom=DBL_MAX;
        }
      else
        {
         topPrice[bar]=topPrice[bar-1];
         bottomPrice[bar]=bottomPrice[bar-1];
        }
     }

   double upperBand[]; ArrayResize(upperBand,Data.Bars); ArrayInitialize(upperBand,0);
   double lowerBand[]; ArrayResize(lowerBand,Data.Bars); ArrayInitialize(lowerBand,0);
   for(int bar=firstBar; bar<Data.Bars; bar++)
     {
      upperBand[bar] = topPrice[bar] + shift;
      lowerBand[bar] = bottomPrice[bar] - shift;
     }

// Saving the components
   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "Top price";
   Component[0].DataType = IndComponentType_IndicatorValue;
   Component[0].FirstBar = firstBar;
   ArrayCopy(Component[0].Value,topPrice);

   ArrayResize(Component[1].Value,Data.Bars);
   Component[1].CompName = "Bottom price";
   Component[1].DataType = IndComponentType_IndicatorValue;
   Component[1].FirstBar = firstBar;
   ArrayCopy(Component[1].Value,bottomPrice);

   ArrayResize(Component[2].Value,Data.Bars);
   Component[2].FirstBar=firstBar;

   ArrayResize(Component[3].Value,Data.Bars);
   Component[3].FirstBar=firstBar;

// Sets the Component's type
   if(SlotType==SlotTypes_Open)
     {
      Component[2].CompName = "Long entry price";
      Component[2].DataType = IndComponentType_OpenLongPrice;
      Component[3].CompName = "Short entry price";
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
      Component[2].CompName = "Long closing price";
      Component[2].DataType = IndComponentType_CloseLongPrice;
      Component[3].CompName = "Short closing price";
      Component[3].DataType = IndComponentType_CloseShortPrice;
     }
   else if(SlotType==SlotTypes_CloseFilter)
     {
      Component[2].CompName = "Close out long position";
      Component[2].DataType = IndComponentType_ForceCloseLong;
      Component[3].CompName = "Close out short position";
      Component[3].DataType = IndComponentType_ForceCloseShort;
     }

   if(ListParam[0].Text=="Enter long at the top price" || ListParam[0].Text=="Exit long at the top price")
     {
      ArrayCopy(Component[2].Value, upperBand);
      ArrayCopy(Component[3].Value, lowerBand);
     }
   else if(ListParam[0].Text=="Enter long at the bottom price" || ListParam[0].Text=="Exit long at the bottom price")
     {
      ArrayCopy(Component[2].Value, lowerBand);
      ArrayCopy(Component[3].Value, upperBand);
     }
   else if(ListParam[0].Text=="The bar opens below the top price")
      BandIndicatorLogic(firstBar,0,upperBand,lowerBand,Component[2],Component[3],BandIndLogic_The_bar_opens_below_the_Upper_Band);
   else if(ListParam[0].Text=="The bar opens above the top price")
      BandIndicatorLogic(firstBar,0,upperBand,lowerBand,Component[2],Component[3],BandIndLogic_The_bar_opens_above_the_Upper_Band);
   else if(ListParam[0].Text=="The bar opens below the bottom price")
      BandIndicatorLogic(firstBar,0,upperBand,lowerBand,Component[2],Component[3],BandIndLogic_The_bar_opens_below_the_Lower_Band);
   else if(ListParam[0].Text=="The bar opens above the bottom price")
      BandIndicatorLogic(firstBar,0,upperBand,lowerBand,Component[2],Component[3],BandIndLogic_The_bar_opens_above_the_Lower_Band);
   else if(ListParam[0].Text=="The bar closes below the top price")
      BandIndicatorLogic(firstBar,0,upperBand,lowerBand,Component[2],Component[3],BandIndLogic_The_bar_opens_below_the_Upper_Band);
   else if(ListParam[0].Text=="The bar closes above the top price")
      BandIndicatorLogic(firstBar,0,upperBand,lowerBand,Component[2],Component[3],BandIndLogic_The_bar_closes_above_the_Upper_Band);
   else if(ListParam[0].Text=="The bar closes below the bottom price")
      BandIndicatorLogic(firstBar,0,upperBand,lowerBand,Component[2],Component[3],BandIndLogic_The_bar_closes_below_the_Lower_Band);
   else if(ListParam[0].Text=="The bar closes above the bottom price")
      BandIndicatorLogic(firstBar,0,upperBand,lowerBand,Component[2],Component[3],BandIndLogic_The_bar_closes_above_the_Lower_Band);
   else if(ListParam[0].Text=="The position opens above the top price")
     {
      Component[0].DataType = IndComponentType_Other;
      Component[1].DataType = IndComponentType_Other;
      Component[2].CompName = "Shifted top price";
      Component[2].DataType = IndComponentType_OpenLongPrice;
      Component[2].PosPriceDependence=PositionPriceDependence_PriceBuyHigher;
      Component[3].CompName = "Shifted bottom price";
      Component[3].DataType = IndComponentType_OpenShortPrice;
      Component[3].PosPriceDependence=PositionPriceDependence_PriceSellLower;
      ArrayCopy(Component[2].Value, upperBand);
      ArrayCopy(Component[3].Value, lowerBand);
     }
   else if(ListParam[0].Text=="The position opens below the top price")
     {
      Component[0].DataType = IndComponentType_Other;
      Component[1].DataType = IndComponentType_Other;
      Component[2].CompName = "Shifted top price";
      Component[2].DataType = IndComponentType_OpenLongPrice;
      Component[2].PosPriceDependence=PositionPriceDependence_PriceBuyLower;
      Component[3].CompName = "Shifted bottom price";
      Component[3].DataType = IndComponentType_OpenShortPrice;
      Component[3].PosPriceDependence=PositionPriceDependence_PriceSellHigher;
      ArrayCopy(Component[2].Value, upperBand);
      ArrayCopy(Component[3].Value, lowerBand);
     }
   else if(ListParam[0].Text=="The position opens above the bottom price")
     {
      Component[0].DataType = IndComponentType_Other;
      Component[1].DataType = IndComponentType_Other;
      Component[2].CompName = "Shifted bottom price";
      Component[2].DataType = IndComponentType_OpenLongPrice;
      Component[2].PosPriceDependence=PositionPriceDependence_PriceBuyHigher;
      Component[3].CompName = "Shifted top price";
      Component[3].DataType = IndComponentType_OpenShortPrice;
      Component[3].PosPriceDependence=PositionPriceDependence_PriceSellLower;
      ArrayCopy(Component[2].Value, lowerBand);
      ArrayCopy(Component[3].Value, upperBand);
     }
   else if(ListParam[0].Text=="The position opens below the bottom price")
     {
      Component[0].DataType = IndComponentType_Other;
      Component[1].DataType = IndComponentType_Other;
      Component[2].CompName = "Shifted bottom price";
      Component[2].DataType = IndComponentType_OpenLongPrice;
      Component[2].PosPriceDependence=PositionPriceDependence_PriceBuyLower;
      Component[3].CompName = "Shifted top price";
      Component[3].DataType = IndComponentType_OpenShortPrice;
      Component[3].PosPriceDependence=PositionPriceDependence_PriceSellHigher;
      ArrayCopy(Component[2].Value, lowerBand);
      ArrayCopy(Component[3].Value, upperBand);
     }
  }
//+------------------------------------------------------------------+
