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
class IchimokuKinkoHyo : public Indicator
  {
public:
                     IchimokuKinkoHyo(SlotTypes slotType);
   virtual void      Calculate(DataSet &dataSet);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
IchimokuKinkoHyo::IchimokuKinkoHyo(SlotTypes slotType)
  {
   SlotType          = slotType;
   IndicatorName     = "Ichimoku Kinko Hyo";
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
void IchimokuKinkoHyo::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

   int tenkan   = (int) NumParam[0].Value;
   int kijun    = (int) NumParam[2].Value;
   int senkou   = (int) NumParam[4].Value;
   int previous = CheckParam[0].Checked ? 1 : 0;
   int firstBar = MathMax(MathMax(tenkan,kijun),senkou)+previous+2;

   double tenkanSen[];   ArrayResize(tenkanSen,Data.Bars);   ArrayInitialize(tenkanSen,0);
   double kijunSen[];    ArrayResize(kijunSen,Data.Bars);    ArrayInitialize(kijunSen,0);
   double chikouSpan[];  ArrayResize(chikouSpan,Data.Bars);  ArrayInitialize(chikouSpan,0);
   double senkouSpanA[]; ArrayResize(senkouSpanA,Data.Bars); ArrayInitialize(senkouSpanA,0);
   double senkouSpanB[]; ArrayResize(senkouSpanB,Data.Bars); ArrayInitialize(senkouSpanB,0);

   for(int bar=tenkan-1; bar<Data.Bars; bar++)
     {
      double highestHigh=DBL_MIN;
      double lowestLow=DBL_MAX;
      for(int i=0; i<tenkan; i++)
        {
         if(Data.High[bar-i]>highestHigh)
            highestHigh=Data.High[bar-i];
         if(Data.Low[bar-i]<lowestLow)
            lowestLow=Data.Low[bar-i];
        }
      tenkanSen[bar]=(highestHigh+lowestLow)/2;
     }

   for(int bar=kijun-1; bar<Data.Bars; bar++)
     {
      double highestHigh=DBL_MIN;
      double lowestLow=DBL_MAX;
      for(int i=0; i<kijun; i++)
        {
         if(Data.High[bar-i]>highestHigh)
            highestHigh=Data.High[bar-i];
         if(Data.Low[bar-i]<lowestLow)
            lowestLow=Data.Low[bar-i];
        }
      kijunSen[bar]=(highestHigh+lowestLow)/2;
     }

   for(int bar=0; bar<Data.Bars-kijun; bar++)
     {
      chikouSpan[bar]=Data.Close[bar+kijun];
     }

   for(int bar=firstBar; bar<Data.Bars-kijun; bar++)
     {
      senkouSpanA[bar+kijun]=(tenkanSen[bar]+kijunSen[bar])/2;
     }

   for(int bar=senkou-1; bar<Data.Bars-kijun; bar++)
     {
      double highestHigh=DBL_MIN;
      double lowestLow=DBL_MAX;
      for(int i=0; i<senkou; i++)
        {
         if(Data.High[bar-i]>highestHigh)
            highestHigh=Data.High[bar-i];
         if(Data.Low[bar-i]<lowestLow)
            lowestLow=Data.Low[bar-i];
        }
      senkouSpanB[bar+kijun]=(highestHigh+lowestLow)/2;
     }

   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "Tenkan Sen";
   Component[0].DataType = IndComponentType_IndicatorValue;
   Component[0].FirstBar = firstBar;
   ArrayCopy(Component[0].Value,tenkanSen);

   ArrayResize(Component[1].Value,Data.Bars);
   Component[1].CompName = "Kijun Sen";
   Component[1].DataType = IndComponentType_IndicatorValue;
   Component[1].FirstBar = firstBar;
   ArrayCopy(Component[1].Value,kijunSen);

   ArrayResize(Component[2].Value,Data.Bars);
   Component[2].CompName = "Chikou Span";
   Component[2].DataType = IndComponentType_IndicatorValue;
   Component[2].FirstBar = firstBar;
   ArrayCopy(Component[2].Value,chikouSpan);

   ArrayResize(Component[3].Value,Data.Bars);
   Component[3].CompName = "Senkou Span A";
   Component[3].DataType = IndComponentType_IndicatorValue;
   Component[3].FirstBar = firstBar;
   ArrayCopy(Component[3].Value,senkouSpanA);

   ArrayResize(Component[4].Value,Data.Bars);
   Component[4].CompName = "Senkou Span B";
   Component[4].DataType = IndComponentType_IndicatorValue;
   Component[4].FirstBar = firstBar;
   ArrayCopy(Component[4].Value,senkouSpanB);

   ArrayResize(Component[5].Value,Data.Bars);
   Component[5].FirstBar = firstBar;
   Component[5].DataType = IndComponentType_Other;

   if(SlotType==SlotTypes_OpenFilter)
     {
      Component[5].CompName = "Is long entry allowed";
      Component[5].DataType = IndComponentType_AllowOpenLong;

      ArrayResize(Component[6].Value,Data.Bars);
      Component[6].FirstBar = firstBar;
      Component[6].CompName = "Is short entry allowed";
      Component[6].DataType = IndComponentType_AllowOpenShort;
     }

   if(ListParam[0].Text=="Enter the market at Tenkan Sen")
     {
      Component[5].CompName = "Tenkan Sen entry price";
      Component[5].DataType = IndComponentType_OpenPrice;
      for(int bar=firstBar+previous; bar<Data.Bars; bar++)
        {
         Component[5].Value[bar]=tenkanSen[bar-previous];
        }
     }
   else if(ListParam[0].Text=="Enter the market at Kijun Sen")
     {
      Component[5].CompName = "Kijun Sen entry price";
      Component[5].DataType = IndComponentType_OpenPrice;
      for(int bar=firstBar+previous; bar<Data.Bars; bar++)
        {
         Component[5].Value[bar]=kijunSen[bar-previous];
        }
     }
   else if(ListParam[0].Text=="Exit the market at Tenkan Sen")
     {
      Component[5].CompName = "Tenkan Sen exit price";
      Component[5].DataType = IndComponentType_ClosePrice;
      for(int bar=firstBar+previous; bar<Data.Bars; bar++)
        {
         Component[5].Value[bar]=tenkanSen[bar-previous];
        }
     }
   else if(ListParam[0].Text=="Exit the market at Kijun Sen")
     {
      Component[5].CompName = "Kijun Sen exit price";
      Component[5].DataType = IndComponentType_ClosePrice;
      for(int bar=firstBar+previous; bar<Data.Bars; bar++)
        {
         Component[5].Value[bar]=kijunSen[bar-previous];
        }
     }
   else if(ListParam[0].Text=="Tenkan Sen rises")
     {
      for(int bar=firstBar+previous; bar<Data.Bars; bar++)
        {
         Component[5].Value[bar]=tenkanSen[bar-previous]>tenkanSen[bar-previous-1]+Sigma()? 1: 0;
         Component[6].Value[bar]=tenkanSen[bar-previous]<tenkanSen[bar-previous-1]-Sigma()? 1: 0;
        }
     }
   else if(ListParam[0].Text=="Kijun Sen rises")
     {
      for(int bar=firstBar+previous; bar<Data.Bars; bar++)
        {
         Component[5].Value[bar]=kijunSen[bar-previous]>kijunSen[bar-previous-1]+Sigma() ? 1 : 0;
         Component[6].Value[bar]=kijunSen[bar-previous]<kijunSen[bar-previous-1]-Sigma() ? 1 : 0;
        }
     }
   else if(ListParam[0].Text=="Tenkan Sen is higher than Kijun Sen")
     {
      IndicatorIsHigherThanAnotherIndicatorLogic(firstBar,previous,tenkanSen,kijunSen,Component[5],Component[6]);
     }
   else if(ListParam[0].Text=="Tenkan Sen crosses Kijun Sen upward")
     {
      IndicatorCrossesAnotherIndicatorUpwardLogic(firstBar,previous,tenkanSen,kijunSen,Component[5],Component[6]);
     }
   else if(ListParam[0].Text=="The bar opens above Tenkan Sen")
     {
      BarOpensAboveIndicatorLogic(firstBar,previous,tenkanSen,Component[5],Component[6]);
     }
   else if(ListParam[0].Text=="The bar opens above Kijun Sen")
     {
      BarOpensAboveIndicatorLogic(firstBar,previous,kijunSen,Component[5],Component[6]);
     }
   else if(ListParam[0].Text=="Chikou Span is above closing price")
     {
      for(int bar=firstBar+previous; bar<Data.Bars; bar++)
        {
         Component[5].Value[bar]=chikouSpan[bar-kijun-previous]>Data.Close[bar-kijun-previous]+Sigma()? 1: 0;
         Component[6].Value[bar]=chikouSpan[bar-kijun-previous]<Data.Close[bar-kijun-previous]-Sigma()? 1: 0;
        }
     }
   else if(ListParam[0].Text=="The position opens above Kumo")
     {
      for(int bar=firstBar; bar<Data.Bars; bar++)
        {
         Component[5].Value[bar] = MathMax(senkouSpanA[bar], senkouSpanB[bar]);
         Component[6].Value[bar] = MathMin(senkouSpanA[bar], senkouSpanB[bar]);
        }
      Component[5].PosPriceDependence=PositionPriceDependence_PriceBuyHigher;
      Component[5].DataType=IndComponentType_Other;
      Component[5].ShowInDynInfo=false;

      Component[6].PosPriceDependence=PositionPriceDependence_PriceSellLower;
      Component[6].DataType=IndComponentType_Other;
      Component[6].ShowInDynInfo=false;
     }
   else if(ListParam[0].Text=="The position opens inside or above Kumo")
     {
      for(int bar=firstBar; bar<Data.Bars; bar++)
        {
         Component[5].Value[bar] = MathMin(senkouSpanA[bar], senkouSpanB[bar]);
         Component[6].Value[bar] = MathMax(senkouSpanA[bar], senkouSpanB[bar]);
        }
      Component[5].PosPriceDependence=PositionPriceDependence_PriceBuyHigher;
      Component[5].DataType=IndComponentType_Other;
      Component[5].ShowInDynInfo=false;

      Component[6].PosPriceDependence=PositionPriceDependence_PriceSellLower;
      Component[6].DataType=IndComponentType_Other;
      Component[6].ShowInDynInfo=false;
     }
   else if(ListParam[0].Text=="Tenkan Sen is above Kumo")
     {
      for(int bar=firstBar+previous; bar<Data.Bars; bar++)
        {
         Component[5].Value[bar]=tenkanSen[bar-previous]>MathMax(senkouSpanA[bar-previous],senkouSpanB[bar-previous])+Sigma()? 1: 0;
         Component[6].Value[bar]=tenkanSen[bar-previous]<MathMin(senkouSpanA[bar-previous],senkouSpanB[bar-previous])-Sigma()? 1: 0;
        }
     }
   else if(ListParam[0].Text=="Tenkan Sen is inside or above Kumo")
     {
      for(int bar=firstBar+previous; bar<Data.Bars; bar++)
        {
         Component[5].Value[bar]=tenkanSen[bar-previous]>MathMin(senkouSpanA[bar-previous],senkouSpanB[bar-previous])+Sigma()? 1: 0;
         Component[6].Value[bar]=tenkanSen[bar-previous]<MathMax(senkouSpanA[bar-previous],senkouSpanB[bar-previous])-Sigma()? 1: 0;
        }
     }
   else if(ListParam[0].Text=="Kijun Sen is above Kumo")
     {
      for(int bar=firstBar+previous; bar<Data.Bars; bar++)
        {
         Component[5].Value[bar]=kijunSen[bar-previous]>MathMax(senkouSpanA[bar-previous],senkouSpanB[bar-previous])+Sigma()? 1: 0;
         Component[6].Value[bar]=kijunSen[bar-previous]<MathMin(senkouSpanA[bar-previous],senkouSpanB[bar-previous])-Sigma()? 1: 0;
        }
     }
   else if(ListParam[0].Text=="Kijun Sen is inside or above Kumo")
     {
      for(int bar=firstBar+previous; bar<Data.Bars; bar++)
        {
         Component[5].Value[bar]=kijunSen[bar-previous]>MathMin(senkouSpanA[bar-previous],senkouSpanB[bar-previous])+Sigma()? 1: 0;
         Component[6].Value[bar]=kijunSen[bar-previous]<MathMax(senkouSpanA[bar-previous],senkouSpanB[bar-previous])-Sigma()? 1: 0;
        }
     }
   else if(ListParam[0].Text=="Senkou Span A is higher than Senkou Span B")
     {
      IndicatorIsHigherThanAnotherIndicatorLogic(firstBar,previous,senkouSpanA,senkouSpanB,Component[5],Component[6]);
     }
   else if(ListParam[0].Text=="Senkou Span A crosses Senkou Span B upward")
     {
      IndicatorCrossesAnotherIndicatorUpwardLogic(firstBar,previous,senkouSpanA,senkouSpanB,Component[5],Component[6]);
     }
  }
//+------------------------------------------------------------------+
