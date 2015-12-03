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
class PreviousBarOpening : public Indicator
  {
public:
    PreviousBarOpening(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="Previous Bar Opening";

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
void PreviousBarOpening::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

// Calculation
   double adPrevBarOpening[];
   ArrayResize(adPrevBarOpening,Data.Bars);
   ArrayInitialize(adPrevBarOpening,0);

   const int firstBar=1;

   for(int bar=firstBar; bar<Data.Bars; bar++)
      adPrevBarOpening[bar]=Data.Open[bar-1];

// Saving the components
   if(SlotType==SlotTypes_OpenFilter || SlotType==SlotTypes_CloseFilter)
     {
      ArrayResize(Component[1].Value,Data.Bars);
      Component[1].FirstBar=firstBar;

      ArrayResize(Component[2].Value,Data.Bars);
      Component[2].FirstBar=firstBar;
     }

   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].DataType = IndComponentType_IndicatorValue;
   Component[0].CompName = "Previous Bar Opening";
   Component[0].FirstBar = firstBar;
   ArrayCopy(Component[0].Value,adPrevBarOpening);

// Sets the Component's type
   if(SlotType==SlotTypes_Open)
      Component[0].DataType=IndComponentType_OpenPrice;
   else if(SlotType==SlotTypes_OpenFilter)
     {
      Component[1].DataType = IndComponentType_AllowOpenLong;
      Component[1].CompName = "Is long entry allowed";
      Component[2].DataType = IndComponentType_AllowOpenShort;
      Component[2].CompName = "Is short entry allowed";
     }
   else if(SlotType==SlotTypes_Close)
      Component[0].DataType=IndComponentType_ClosePrice;
   else if(SlotType==SlotTypes_CloseFilter)
     {
      Component[1].DataType = IndComponentType_ForceCloseLong;
      Component[1].CompName = "Close out long position";
      Component[2].DataType = IndComponentType_ForceCloseShort;
      Component[2].CompName = "Close out short position";
     }

   if(SlotType==SlotTypes_OpenFilter || SlotType==SlotTypes_CloseFilter)
     {
      if(ListParam[0].Text=="The bar opens below the previous Bar Opening")
         BarOpensBelowIndicatorLogic(firstBar,0,adPrevBarOpening,Component[1],Component[2]);
      else if(ListParam[0].Text=="The bar opens above the previous Bar Opening")
         BarOpensAboveIndicatorLogic(firstBar,0,adPrevBarOpening,Component[1],Component[2]);
      else if(ListParam[0].Text=="The position opens above the previous Bar Opening")
        {
         Component[0].PosPriceDependence=PositionPriceDependence_BuyHigherSellLower;
         Component[1].DataType = IndComponentType_Other;
         Component[2].DataType = IndComponentType_Other;
         Component[1].ShowInDynInfo = false;
         Component[2].ShowInDynInfo = false;
        }
      else if(ListParam[0].Text=="The position opens below the previous Bar Opening")
        {
         Component[0].PosPriceDependence=PositionPriceDependence_BuyLowerSellHigher;
         Component[1].DataType = IndComponentType_Other;
         Component[2].DataType = IndComponentType_Other;
         Component[1].ShowInDynInfo = false;
         Component[2].ShowInDynInfo = false;
        }
      else if(ListParam[0].Text=="The bar closes below the previous Bar Opening")
         BarClosesBelowIndicatorLogic(firstBar,0,adPrevBarOpening,Component[1],Component[2]);
      else if(ListParam[0].Text=="The bar closes above the previous Bar Opening")
         BarClosesAboveIndicatorLogic(firstBar,0,adPrevBarOpening,Component[1],Component[2]);
     }
  }
//+------------------------------------------------------------------+
