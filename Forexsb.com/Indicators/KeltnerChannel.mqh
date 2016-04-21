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
class KeltnerChannel : public Indicator
  {
public:
    KeltnerChannel(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="Keltner Channel";

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
void KeltnerChannel::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

// Reading the parameters
   MAMethod maMethod=(MAMethod) ListParam[1].Index;
   const BasePrice basePrice=BasePrice_Close;
   int nMA=(int) NumParam[0].Value;
   int atrPeriod=(int) NumParam[1].Value;
   int atrMultiplier=(int) NumParam[3].Value;
   int previous=CheckParam[0].Checked ? 1 : 0;

// Calculation
   double price[];    Price(basePrice,price);
   double adMA[];     MovingAverage(nMA,0,maMethod,price,adMA);
   double adAtr[];    ArrayResize(adAtr,Data.Bars);    ArrayInitialize(adAtr,0);
   double adUpBand[]; ArrayResize(adUpBand,Data.Bars); ArrayInitialize(adUpBand,0);
   double adDnBand[]; ArrayResize(adDnBand,Data.Bars); ArrayInitialize(adDnBand,0);

   int firstBar=MathMax(nMA,atrPeriod)+previous+2;

   for(int iBar=1; iBar<Data.Bars; iBar++)
     {
      adAtr[iBar] = MathMax(MathAbs(Data.High[iBar] - Data.Close[iBar - 1]), MathAbs(Data.Close[iBar - 1] - Data.Low[iBar]));
      adAtr[iBar] = MathMax(MathAbs(Data.High[iBar] - Data.Low[iBar]), adAtr[iBar]);
     }

   double maAtr[]; ArrayResize(maAtr,Data.Bars); ArrayInitialize(maAtr,0);
   MovingAverage(atrPeriod,0,maMethod,adAtr,maAtr);

   for(int iBar=nMA; iBar<Data.Bars; iBar++)
     {
      adUpBand[iBar] = adMA[iBar] + maAtr[iBar]*atrMultiplier;
      adDnBand[iBar] = adMA[iBar] - maAtr[iBar]*atrMultiplier;
     }

// Saving the components

   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "Upper Band";
   Component[0].DataType = IndComponentType_IndicatorValue;
   Component[0].FirstBar = firstBar;
   ArrayCopy(Component[0].Value,adUpBand);

   ArrayResize(Component[1].Value,Data.Bars);
   Component[1].CompName = "Moving Average";
   Component[1].DataType = IndComponentType_IndicatorValue;
   Component[1].FirstBar = firstBar;
   ArrayCopy(Component[1].Value,adMA);

   ArrayResize(Component[2].Value,Data.Bars);
   Component[2].CompName = "Lower Band";
   Component[2].DataType = IndComponentType_IndicatorValue;
   Component[2].FirstBar = firstBar;
   ArrayCopy(Component[2].Value,adDnBand);

   ArrayResize(Component[3].Value,Data.Bars);
   ArrayInitialize(Component[3].Value,0);
   Component[3].FirstBar=firstBar;

   ArrayResize(Component[4].Value,Data.Bars);
   ArrayInitialize(Component[4].Value,0);
   Component[4].FirstBar=firstBar;

// Sets the Component's type
   if(SlotType==SlotTypes_Open)
     {
      Component[3].DataType = IndComponentType_OpenLongPrice;
      Component[3].CompName = "Long position entry price";
      Component[4].DataType = IndComponentType_OpenShortPrice;
      Component[4].CompName = "Short position entry price";
     }
   else if(SlotType==SlotTypes_OpenFilter)
     {
      Component[3].DataType = IndComponentType_AllowOpenLong;
      Component[3].CompName = "Is long entry allowed";
      Component[4].DataType = IndComponentType_AllowOpenShort;
      Component[4].CompName = "Is short entry allowed";
     }
   else if(SlotType==SlotTypes_Close)
     {
      Component[3].DataType = IndComponentType_CloseLongPrice;
      Component[3].CompName = "Long position closing price";
      Component[4].DataType = IndComponentType_CloseShortPrice;
      Component[4].CompName = "Short position closing price";
     }
   else if(SlotType==SlotTypes_CloseFilter)
     {
      Component[3].DataType = IndComponentType_ForceCloseLong;
      Component[3].CompName = "Close out long position";
      Component[4].DataType = IndComponentType_ForceCloseShort;
      Component[4].CompName = "Close out short position";
     }

   if(SlotType==SlotTypes_Open || SlotType==SlotTypes_Close)
     {
      if(nMA>1)
        {
         for(int iBar=firstBar; iBar<Data.Bars; iBar++)
           {
            // Covers the cases when the price can pass through the band without a signal.
            double dOpen=Data.Open[iBar]; // Current open price

            // Upper band
            double dValueUp=adUpBand[iBar-previous]; // Current value
            double dValueUp1=adUpBand[iBar-previous-1]; // Previous value
            double dTempValUp=dValueUp;

            if((dValueUp1>Data.High[iBar-1] && dValueUp<dOpen) || // The Data.Open price jumps above the indicator
               (dValueUp1<Data.Low[iBar-1]  && dValueUp>dOpen) || // The Data.Open price jumps below the indicator
               (Data.Close[iBar-1]<dValueUp && dValueUp<dOpen) || // The Data.Open price is in a positive gap
               (Data.Close[iBar-1]>dValueUp &&  dValueUp>dOpen))  // The Data.Open price is in a negative gap
               dTempValUp=dOpen; // The entry/exit level is moved to Data.Open price

            // Lower band
            double dValueDown=adDnBand[iBar-previous];    // Current value
            double dValueDown1=adDnBand[iBar-previous-1]; // Previous value
            double dTempValDown=dValueDown;

            if((dValueDown1>Data.High[iBar-1] && dValueDown<dOpen) || // The Data.Open price jumps above the indicator
               (dValueDown1<Data.Low[iBar-1]  && dValueDown>dOpen) || // The Data.Open price jumps below the indicator
               (Data.Close[iBar-1]<dValueDown && dValueDown<dOpen) || // The Data.Open price is in a positive gap
               (Data.Close[iBar-1]>dValueDown && dValueDown>dOpen))   // The Data.Open price is in a negative gap
               dTempValDown=dOpen; // The entry/exit level is moved to Data.Open price

            if(ListParam[0].Text=="Enter long at Upper Band" || ListParam[0].Text=="Exit long at Upper Band")
              {
               Component[3].Value[iBar] = dTempValUp;
               Component[4].Value[iBar] = dTempValDown;
              }
            else
              {
               Component[3].Value[iBar] = dTempValDown;
               Component[4].Value[iBar] = dTempValUp;
              }
           }
        }
      else
        {
         for(int iBar=2; iBar<Data.Bars; iBar++)
           {
            if(ListParam[0].Text=="Enter long at Upper Band" || ListParam[0].Text=="Exit long at Upper Band")
              {
               Component[3].Value[iBar] = adUpBand[iBar - previous];
               Component[4].Value[iBar] = adDnBand[iBar - previous];
              }
            else
              {
               Component[3].Value[iBar] = adDnBand[iBar - previous];
               Component[4].Value[iBar] = adUpBand[iBar - previous];
              }
           }
        }
     }
   else
     {
      if(ListParam[0].Text=="The bar opens below Upper Band")
         BandIndicatorLogic(firstBar,previous,adUpBand,adDnBand,Component[3],Component[4],BandIndLogic_The_bar_opens_below_the_Upper_Band);
      else if(ListParam[0].Text=="The bar opens above Upper Band")
         BandIndicatorLogic(firstBar,previous,adUpBand,adDnBand,Component[3],Component[4],BandIndLogic_The_bar_opens_above_the_Upper_Band);
      else if(ListParam[0].Text=="The bar opens below Lower Band")
         BandIndicatorLogic(firstBar,previous,adUpBand,adDnBand,Component[3],Component[4],BandIndLogic_The_bar_opens_below_the_Lower_Band);
      else if(ListParam[0].Text=="The bar opens above Lower Band")
         BandIndicatorLogic(firstBar,previous,adUpBand,adDnBand,Component[3],Component[4],BandIndLogic_The_bar_opens_above_the_Lower_Band);
      else if(ListParam[0].Text=="The bar opens below Upper Band after opening above it")
         BandIndicatorLogic(firstBar,previous,adUpBand,adDnBand,Component[3],Component[4],BandIndLogic_The_bar_opens_below_Upper_Band_after_above);
      else if(ListParam[0].Text=="The bar opens above Upper Band after opening below it")
         BandIndicatorLogic(firstBar,previous,adUpBand,adDnBand,Component[3],Component[4],BandIndLogic_The_bar_opens_above_Upper_Band_after_below);
      else if(ListParam[0].Text=="The bar opens below Lower Band after opening above it")
         BandIndicatorLogic(firstBar,previous,adUpBand,adDnBand,Component[3],Component[4],BandIndLogic_The_bar_opens_below_Lower_Band_after_above);
      else if(ListParam[0].Text=="The bar opens above Lower Band after opening below it")
         BandIndicatorLogic(firstBar,previous,adUpBand,adDnBand,Component[3],Component[4],BandIndLogic_The_bar_opens_above_Lower_Band_after_below);
      else if(ListParam[0].Text=="The position opens above Upper Band")
        {
         Component[0].PosPriceDependence = PositionPriceDependence_PriceBuyHigher;
         Component[2].PosPriceDependence = PositionPriceDependence_PriceSellLower;
         Component[3].DataType = IndComponentType_Other;
         Component[4].DataType = IndComponentType_Other;
         Component[3].ShowInDynInfo = false;
         Component[4].ShowInDynInfo = false;
        }
      else if(ListParam[0].Text=="The position opens below Upper Band")
        {
         Component[0].PosPriceDependence = PositionPriceDependence_PriceBuyLower;
         Component[2].PosPriceDependence = PositionPriceDependence_PriceSellHigher;
         Component[3].DataType = IndComponentType_Other;
         Component[4].DataType = IndComponentType_Other;
         Component[3].ShowInDynInfo = false;
         Component[4].ShowInDynInfo = false;
        }
      else if(ListParam[0].Text=="The position opens above Lower Band")
        {
         Component[0].PosPriceDependence = PositionPriceDependence_PriceSellLower;
         Component[2].PosPriceDependence = PositionPriceDependence_PriceBuyHigher;
         Component[3].DataType = IndComponentType_Other;
         Component[4].DataType = IndComponentType_Other;
         Component[3].ShowInDynInfo = false;
         Component[4].ShowInDynInfo = false;
        }
      else if(ListParam[0].Text=="The position opens below Lower Band")
        {
         Component[0].PosPriceDependence = PositionPriceDependence_PriceSellHigher;
         Component[2].PosPriceDependence = PositionPriceDependence_PriceBuyLower;
         Component[3].DataType = IndComponentType_Other;
         Component[4].DataType = IndComponentType_Other;
         Component[3].ShowInDynInfo = false;
         Component[4].ShowInDynInfo = false;
        }
      else if(ListParam[0].Text=="The bar closes below Upper Band")
         BandIndicatorLogic(firstBar,previous,adUpBand,adDnBand,Component[3],Component[4],BandIndLogic_The_bar_closes_below_the_Upper_Band);
      else if(ListParam[0].Text=="The bar closes above Upper Band")
         BandIndicatorLogic(firstBar,previous,adUpBand,adDnBand,Component[3],Component[4],BandIndLogic_The_bar_closes_above_the_Upper_Band);
      else if(ListParam[0].Text=="The bar closes below Lower Band")
         BandIndicatorLogic(firstBar,previous,adUpBand,adDnBand,Component[3],Component[4],BandIndLogic_The_bar_closes_below_the_Lower_Band);
      else if(ListParam[0].Text=="The bar closes above Lower Band")
         BandIndicatorLogic(firstBar,previous,adUpBand,adDnBand,Component[3],Component[4],BandIndLogic_The_bar_closes_above_the_Lower_Band);
     }
  }
//+------------------------------------------------------------------+
