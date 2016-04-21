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
class HourlyHighLow : public Indicator
  {
public:
   HourlyHighLow(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="Hourly High Low";

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
void HourlyHighLow::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

   int fromHour  = (int) NumParam[0].Value;
   int fromMin   = (int) NumParam[1].Value;
   int toHour = (int) NumParam[2].Value;
   int toMin  = (int) NumParam[3].Value;

   int fromTime = fromHour*60  + fromMin;
   int toTime   = toHour*60    + toMin;

   double shift=NumParam[4].Value*Data.Point;

   const int firstBar=2;

// Calculation
   double adHighPrice[]; ArrayResize(adHighPrice,Data.Bars); ArrayInitialize(adHighPrice,0);
   double adLowPrice[];  ArrayResize(adLowPrice,Data.Bars);  ArrayInitialize(adLowPrice,0);

   double dMinPrice = DBL_MAX;
   double dMaxPrice = DBL_MIN;
   adHighPrice[0] = 0;
   adLowPrice[0]  = 0;

   bool isOnTimePrev=false;
   for(int bar=1; bar<Data.Bars; bar++)
     {
      bool isOnTime;
      MqlDateTime mqlTime;
      TimeToStruct(Data.Time[bar],mqlTime);
      int barTime=mqlTime.hour*60+mqlTime.min;
      if(fromTime<toTime)
         isOnTime=barTime>=fromTime && barTime<toTime;
      else if(fromTime>toTime)
         isOnTime=barTime>=fromTime || barTime<toTime;
      else
         isOnTime=barTime!=toTime;

      if(isOnTime)
        {
         if(dMaxPrice < Data.High[bar]) dMaxPrice = Data.High[bar];
         if(dMinPrice > Data.Low[bar])  dMinPrice = Data.Low[bar];
        }

      if(!isOnTime && isOnTimePrev)
        {
         adHighPrice[bar]= dMaxPrice;
         adLowPrice[bar] = dMinPrice;
         dMaxPrice = DBL_MIN;
         dMinPrice = DBL_MAX;
        }
      else
        {
         adHighPrice[bar] = adHighPrice[bar - 1];
         adLowPrice[bar]  = adLowPrice[bar - 1];
        }

      isOnTimePrev=isOnTime;
     }

// Shifting the price
   double adUpperBand[]; ArrayResize(adUpperBand,Data.Bars); ArrayInitialize(adUpperBand,0);
   double adLowerBand[]; ArrayResize(adLowerBand,Data.Bars); ArrayInitialize(adLowerBand,0);
   for(int bar=firstBar; bar<Data.Bars; bar++)
     {
      adUpperBand[bar] = adHighPrice[bar] + shift;
      adLowerBand[bar] = adLowPrice[bar] - shift;
     }

// Saving the components
   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "Hourly High";
   Component[0].DataType = IndComponentType_IndicatorValue;
   Component[0].FirstBar = firstBar;
   ArrayCopy(Component[0].Value,adHighPrice);

   ArrayResize(Component[1].Value,Data.Bars);
   Component[1].CompName = "Hourly Low";
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

   if(ListParam[0].Text=="Enter long at the hourly high" || ListParam[0].Text=="Exit long at the hourly high")
     {
      ArrayCopy(Component[2].Value, adUpperBand);
      ArrayCopy(Component[3].Value, adLowerBand);
     }
   else if(ListParam[0].Text=="Enter long at the hourly low" || ListParam[0].Text=="Exit long at the hourly low")
     {
      ArrayCopy(Component[2].Value, adLowerBand);
      ArrayCopy(Component[3].Value, adUpperBand);
     }
   else if(ListParam[0].Text=="The bar closes below the hourly high")
      BandIndicatorLogic(firstBar,0,adUpperBand,adLowerBand,Component[2],Component[3],BandIndLogic_The_bar_closes_below_the_Upper_Band);
   else if(ListParam[0].Text=="The bar closes above the hourly high")
      BandIndicatorLogic(firstBar,0,adUpperBand,adLowerBand,Component[2],Component[3],BandIndLogic_The_bar_closes_above_the_Upper_Band);
   else if(ListParam[0].Text=="The bar closes below the hourly low")
      BandIndicatorLogic(firstBar,0,adUpperBand,adLowerBand,Component[2],Component[3],BandIndLogic_The_bar_closes_below_the_Lower_Band);
   else if(ListParam[0].Text=="The bar closes above the hourly low")
      BandIndicatorLogic(firstBar,0,adUpperBand,adLowerBand,Component[2],Component[3],BandIndLogic_The_bar_closes_above_the_Lower_Band);
   else if(ListParam[0].Text=="The position opens above the hourly high")
     {
      Component[0].DataType = IndComponentType_Other;
      Component[1].DataType = IndComponentType_Other;
      Component[2].CompName = "Shifted hourly high";
      Component[2].DataType = IndComponentType_Other;
      Component[2].PosPriceDependence=PositionPriceDependence_PriceBuyHigher;
      Component[3].CompName = "Shifted hourly low";
      Component[3].DataType = IndComponentType_Other;
      Component[3].PosPriceDependence=PositionPriceDependence_PriceSellLower;
      ArrayCopy(Component[2].Value, adUpperBand);
      ArrayCopy(Component[3].Value, adLowerBand);
     }
   else if(ListParam[0].Text=="The position opens below the hourly high")
     {
      Component[0].DataType = IndComponentType_Other;
      Component[1].DataType = IndComponentType_Other;
      Component[2].CompName = "Shifted hourly high";
      Component[2].DataType = IndComponentType_Other;
      Component[2].PosPriceDependence=PositionPriceDependence_PriceBuyLower;
      Component[3].CompName = "Shifted hourly low";
      Component[3].DataType = IndComponentType_Other;
      Component[3].PosPriceDependence=PositionPriceDependence_PriceSellHigher;
      ArrayCopy(Component[2].Value, adUpperBand);
      ArrayCopy(Component[3].Value, adLowerBand);
     }
   else if(ListParam[0].Text=="The position opens above the hourly low")
     {
      Component[0].DataType = IndComponentType_Other;
      Component[1].DataType = IndComponentType_Other;
      Component[2].CompName = "Shifted hourly low";
      Component[2].DataType = IndComponentType_Other;
      Component[2].PosPriceDependence=PositionPriceDependence_PriceBuyHigher;
      Component[3].CompName = "Shifted hourly high";
      Component[3].DataType = IndComponentType_Other;
      Component[3].PosPriceDependence=PositionPriceDependence_PriceSellLower;
      ArrayCopy(Component[2].Value, adLowerBand);
      ArrayCopy(Component[3].Value, adUpperBand);
     }
   else if(ListParam[0].Text=="The position opens below the hourly low")
     {
      Component[0].DataType = IndComponentType_Other;
      Component[1].DataType = IndComponentType_Other;
      Component[2].CompName = "Shifted hourly low";
      Component[2].DataType = IndComponentType_Other;
      Component[2].PosPriceDependence=PositionPriceDependence_PriceBuyLower;
      Component[3].CompName = "Shifted hourly high";
      Component[3].DataType = IndComponentType_Other;
      Component[3].PosPriceDependence=PositionPriceDependence_PriceSellHigher;
      ArrayCopy(Component[2].Value, adLowerBand);
      ArrayCopy(Component[3].Value, adUpperBand);
     }
  }
//+------------------------------------------------------------------+
