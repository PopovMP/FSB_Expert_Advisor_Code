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
#property version   "3.00"
#property strict

#include <Forexsb.com\Enumerations.mqh>
#include <Forexsb.com\IndicatorParam.mqh>
#include <Forexsb.com\IndicatorComp.mqh>
#include <Forexsb.com\DataSet.mqh>
#include <Forexsb.com\Helpers.mqh>
//## Import Start

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Indicator
  {
protected:
   double            Sigma(void);

   double            Epsilon(void);

   void              NormalizeComponentValue(const double &componentValue[],const datetime &strategyTime[],
                                             int ltfShift,bool isCloseFilterShift,double &output[]);

   int               NormalizeComponentFirstBar(int componentFirstBar,datetime &strategyTime[]);

   bool              IsSignalComponent(IndComponentType componentType);

   void              Price(BasePrice priceType,double &price[]);

   void              MovingAverage(int period,int shift,MAMethod maMethod,const double &source[],double &movingAverage[]);

   void              OscillatorLogic(int firstBar,int previous,const double &adIndValue[],double levelLong,double levelShort,
                                     IndicatorComp &indCompLong,IndicatorComp &indCompShort,IndicatorLogic indLogic);

   void              NoDirectionOscillatorLogic(int firstBar,int previous,const double &adIndValue[],double dLevel,
                                                IndicatorComp &indComp,IndicatorLogic indLogic);

   void              BandIndicatorLogic(int firstBar,int previous,const double &adUpperBand[],const double &adLowerBand[],
                                        IndicatorComp &indCompLong,IndicatorComp &indCompShort,BandIndLogic indLogic);

   void              IndicatorRisesLogic(int firstBar,int previous,const double &adIndValue[],IndicatorComp &indCompLong,
                                         IndicatorComp &indCompShort);

   void              IndicatorFallsLogic(int firstBar,int previous,const double &adIndValue[],IndicatorComp &indCompLong,
                                         IndicatorComp &indCompShort);

   void              IndicatorChangesItsDirectionUpward(int firstBar,int previous,double &adIndValue[],
                                                        IndicatorComp &indCompLong,IndicatorComp &indCompShort);

   void              IndicatorChangesItsDirectionDownward(int firstBar,int previous,double &adIndValue[],
                                                          IndicatorComp &indCompLong,IndicatorComp &indCompShort);

   void              IndicatorIsHigherThanAnotherIndicatorLogic(int firstBar,int previous,const double &adIndValue[],
                                                                double &adAnotherIndValue[],IndicatorComp &indCompLong,
                                                                IndicatorComp &indCompShort);

   void              IndicatorIsLowerThanAnotherIndicatorLogic(int firstBar,int previous,const double &adIndValue[],
                                                               double &adAnotherIndValue[],IndicatorComp &indCompLong,
                                                               IndicatorComp &indCompShort);

   void              IndicatorCrossesAnotherIndicatorUpwardLogic(int firstBar,int previous,const double &adIndValue[],
                                                                 double &adAnotherIndValue[],IndicatorComp &indCompLong,
                                                                 IndicatorComp &indCompShort);

   void              IndicatorCrossesAnotherIndicatorDownwardLogic(int firstBar,int previous,const double &adIndValue[],
                                                                   double &adAnotherIndValue[],IndicatorComp &indCompLong,
                                                                   IndicatorComp &indCompShort);

   void              BarOpensAboveIndicatorLogic(int firstBar,int previous,const double &adIndValue[],IndicatorComp &indCompLong,
                                                 IndicatorComp &indCompShort);

   void              BarOpensBelowIndicatorLogic(int firstBar,int previous,const double &adIndValue[],IndicatorComp &indCompLong,
                                                 IndicatorComp &indCompShort);

   void              BarOpensAboveIndicatorAfterOpeningBelowLogic(int firstBar,int previous,const double &adIndValue[],
                                                                  IndicatorComp &indCompLong,IndicatorComp &indCompShort);

   void              BarOpensBelowIndicatorAfterOpeningAboveLogic(int firstBar,int previous,const double &adIndValue[],
                                                                  IndicatorComp &indCompLong,IndicatorComp &indCompShort);

   void              BarClosesAboveIndicatorLogic(int firstBar,int previous,const double &adIndValue[],
                                                  IndicatorComp &indCompLong,IndicatorComp &indCompShort);

   void              BarClosesBelowIndicatorLogic(int firstBar,int previous,const double &adIndValue[],
                                                  IndicatorComp &indCompLong,IndicatorComp &indCompShort);

public:
   // Constructors
                     Indicator(void);

                    ~Indicator(void);

   // Properties
   string            IndicatorName;
   string            WarningMessage;
   bool              IsDiscreteValues;
   bool              UsePreviousBarValue; // Important! Otdated Do not use.
   bool              IsSeparateChart;
   bool              IsBacktester;
   bool              IsDeafultGroupAll; // Important! Outdated. Do not use.
   bool              IsDefaultGroupAll;
   bool              IsAllowLTF;

   SlotTypes         SlotType;
   ExecutionTime     ExecTime;

   ListParameter    *ListParam[5];
   NumericParameter *NumParam[6];
   CheckParameter   *CheckParam[2];

   IndicatorComp    *Component[10];
   DataSet          *Data;

   // Methods
   virtual void      Calculate(DataSet &dataSet);
   void              NormalizeComponents(DataSet &strategyDataSet,int ltfShift,bool isCloseFilterShift);
   void              ShiftSignal(int shift);
   void              RepeatSignal(int repeat);
   int               Components(void);
   string            IndicatorParamToString(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Indicator::Indicator(void)
  {
   IndicatorName="";

   IsBacktester      = false;
   IsDiscreteValues  = false;
   IsSeparateChart   = false;
   IsDeafultGroupAll = false;
   IsDefaultGroupAll = false;
   IsAllowLTF        = true;

   SlotType = SlotTypes_NotDefined;
   ExecTime = ExecutionTime_DuringTheBar;

   for(int i=0; i<5; i++)
      ListParam[i]=new ListParameter();

   for(int i=0; i<6; i++)
      NumParam[i]=new NumericParameter();

   for(int i=0; i<2; i++)
      CheckParam[i]=new CheckParameter();

   for(int i=0; i<10; i++)
      Component[i]=new IndicatorComp();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Indicator::~Indicator(void)
  {
   for(int i=0; i<5; i++)
      delete ListParam[i];

   for(int i=0; i<6; i++)
      delete NumParam[i];

   for(int i=0; i<2; i++)
      delete CheckParam[i];

   for(int i=0; i<10; i++)
      delete Component[i];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::Calculate(DataSet &dataSet)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::NormalizeComponents(DataSet &strategyDataSet,int ltfShift,bool isCloseFilterShift)
  {
   for(int i=0; i<Components(); i++)
     {
      if(Component[i].PosPriceDependence!=PositionPriceDependence_None)
         ltfShift=1;

      double value[];
      NormalizeComponentValue(Component[i].Value,strategyDataSet.Time,ltfShift,isCloseFilterShift,value);
      ArrayCopy(Component[i].Value,value);
      Component[i].FirstBar=NormalizeComponentFirstBar(Component[i].FirstBar,strategyDataSet.Time);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::ShiftSignal(int shift)
  {
   for(int i=0; i<Components(); i++)
     {
      if(!IsSignalComponent(Component[i].DataType))
         continue;
      int bars=ArraySize(Component[i].Value);
      double value[];
      ArrayResize(value,bars);
      ArrayInitialize(value,0);
      ArrayCopy(value,Component[i].Value,shift,0,WHOLE_ARRAY);
      for(int bar=0; bar<bars; bar++)
         Component[i].Value[bar]=value[bar];
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::RepeatSignal(int repeat)
  {
   for(int i=0; i<Components(); i++)
     {
      if(!IsSignalComponent(Component[i].DataType))
         continue;
      int bars=ArraySize(Component[i].Value);
      for(int bar=0; bar<bars; bar++)
        {
         if(Component[i].Value[bar]<0.5)
            continue;
         for(int r=1; r<=repeat; r++)
            if(++bar<bars)
               Component[i].Value[bar]=1;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Indicator::NormalizeComponentValue(const double &componentValue[],const datetime &strategyTime[],
                                   int ltfShift,bool isCloseFilterShift,double &output[])
  {
   int strategyBars=ArraySize(strategyTime);
   ArrayResize(output,strategyBars); ArrayInitialize(output,0);
   int reachedBar=0;
   datetime strategyPeriodMinutes=strategyTime[1]-strategyTime[0];

   for(int ltfBar=ltfShift; ltfBar<Data.Bars; ltfBar++)
     {
      datetime ltfOpenTime=Data.Time[ltfBar];
      datetime ltfCloseTime=ltfOpenTime+((int) Data.Period)*60;

      for(int bar=reachedBar; bar<strategyBars; bar++)
        {
         reachedBar=bar;
         datetime time=strategyTime[bar];
         datetime barCloseTime=time+strategyPeriodMinutes;

         if(isCloseFilterShift && barCloseTime==ltfCloseTime)
           {
            output[bar]=componentValue[ltfBar];
           }
         else
           {
            if(time>=ltfOpenTime && time<ltfCloseTime)
               output[bar]=componentValue[ltfBar-ltfShift];
            else if(time>=ltfCloseTime)
                          break;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Indicator::NormalizeComponentFirstBar(int componentFirstBar,datetime &strategyTime[])
  {
   datetime firstBarTime=Data.Time[componentFirstBar];
   for(int bar=0; bar<ArraySize(strategyTime); bar++)
      if(strategyTime[bar]>=firstBarTime)
         return bar;
   return componentFirstBar;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Indicator::IsSignalComponent(IndComponentType componentType)
  {
   return
   componentType == IndComponentType_AllowOpenLong   ||
   componentType == IndComponentType_AllowOpenShort  ||
   componentType == IndComponentType_CloseLongPrice  ||
   componentType == IndComponentType_ClosePrice      ||
   componentType == IndComponentType_CloseShortPrice ||
   componentType == IndComponentType_ForceClose      ||
   componentType == IndComponentType_ForceCloseLong  ||
   componentType == IndComponentType_ForceCloseShort ||
   componentType == IndComponentType_OpenClosePrice  ||
   componentType == IndComponentType_OpenLongPrice   ||
   componentType == IndComponentType_OpenPrice       ||
   componentType == IndComponentType_OpenShortPrice;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Indicator::Components(void)
  {
   for(int i=0; i<10; i++)
      if(Component[i].DataType==IndComponentType_NotDefined)
         return (i);
   return (10);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Indicator::IndicatorParamToString(void)
  {
   string text;

   for(int i=0; i<5; i++)
      if(ListParam[i].Enabled)
         text+=StringFormat("%s: %s\n",ListParam[i].Caption,ListParam[i].Text);

   for(int i=0; i<6; i++)
      if(NumParam[i].Enabled)
         text+=StringFormat("%s: %g\n",NumParam[i].Caption,NumParam[i].Value);

   for(int i=0; i<2; i++)
      if(CheckParam[i].Enabled)
         text+=StringFormat("%s: %s\n",CheckParam[i].Caption,(CheckParam[i].Checked ? "Yes" : "No"));

   return (text);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::Price(BasePrice priceType,double &price[])
  {
   ArrayResize(price,Data.Bars);
   ArrayInitialize(price,0);

   switch(priceType)
     {
      case BasePrice_Open:
         ArrayCopy(price,Data.Open);
         break;
      case BasePrice_High:
         ArrayCopy(price,Data.High);
         break;
      case BasePrice_Low:
         ArrayCopy(price,Data.Low);
         break;
      case BasePrice_Close:
         ArrayCopy(price,Data.Close);
         break;
      case BasePrice_Median:
         for(int bar=0; bar<Data.Bars; bar++)
         price[bar]=(Data.Low[bar]+Data.High[bar])/2;
         break;
      case BasePrice_Typical:
         for(int bar=0; bar<Data.Bars; bar++)
         price[bar]=(Data.Low[bar]+Data.High[bar]+Data.Close[bar])/3;
         break;
      case BasePrice_Weighted:
         for(int bar=0; bar<Data.Bars; bar++)
         price[bar]=(Data.Low[bar]+Data.High[bar]+2*Data.Close[bar])/4;
         break;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::MovingAverage(int period,int shift,MAMethod maMethod,const double &source[],double &movingAverage[])
  {
   int bars=ArraySize(source);
   ArrayResize(movingAverage,bars);
   ArrayInitialize(movingAverage,0);

   if(period<=1 && shift==0)
     {
      // There is no smoothing
      ArrayCopy(movingAverage,source);
      return;
     }

   if(period>bars || period+shift<=0 || period+shift>bars)
     {
      // Error in the parameters
      string message=IndicatorName+" "+Data.Symbol+" "+DataPeriodToString(Data.Period)+
                     "Wrong MovingAverage parameters(Period: "+IntegerToString(period)+
                     ", Shift: "+IntegerToString(shift)+
                     ", Source bars: "+IntegerToString(bars)+")";
      Print(message);
      ArrayCopy(movingAverage,source);
      return;
     }

   for(int bar=0; bar<period+shift-1; bar++)
      movingAverage[bar]=0;

   double sum=0;
   for(int bar=0; bar<period; bar++)
      sum+=source[bar];

   movingAverage[period+shift-1]=sum/period;
   int lastBar=MathMin(bars,bars-shift);

   switch(maMethod)
     {
      case MAMethod_Simple:
        {
         for(int bar=period; bar<lastBar; bar++)
            movingAverage[bar+shift]=movingAverage[bar+shift-1]+source[bar]/period -
                                     source[bar-period]/period;
        }
      break;
      case MAMethod_Exponential:
        {
         double pr=2.0/(period+1);
         for(int bar=period; bar<lastBar; bar++)
            movingAverage[bar+shift]=source[bar] *pr+movingAverage[bar+shift-1]*(1-pr);
        }
      break;
      case MAMethod_Weighted:
        {
         double weight=period *(period+1)/2.0;
         for(int bar=period; bar<lastBar; bar++)
           {
            sum=0;
            for(int i=0; i<period; i++)
               sum+=source[bar-i]*(period-i);
            movingAverage[bar+shift]=sum/weight;
           }
        }
      break;
      case MAMethod_Smoothed:
        {
         for(int bar=period; bar<lastBar; bar++)
            movingAverage[bar+shift]=(movingAverage[bar+shift-1]*(period-1)+
                                      source[bar])/period;
        }
      break;
      default:
         break;
     }

   for(int bar=bars+shift; bar<bars; bar++)
      movingAverage[bar]=0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Indicator::Sigma(void)
  {
   return (IsSeparateChart ? 0.000005 : Data.Point * 0.5);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Indicator::Epsilon(void)
  {
   return (0.0000001);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::OscillatorLogic(int firstBar,int previous,const double &adIndValue[],double levelLong,
                                double levelShort,IndicatorComp &indCompLong,IndicatorComp &indCompShort,
                                IndicatorLogic indLogic)
  {
   double sigma=Sigma();
   firstBar=MathMax(firstBar,2);

   for(int bar=0; bar<firstBar; bar++)
     {
      indCompLong.Value[bar]=0;
      indCompShort.Value[bar]=0;
     }

   switch(indLogic)
     {
      case IndicatorLogic_The_indicator_rises:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            int currentBar=bar-previous;
            int baseBar=currentBar-1;
            bool isHigher=adIndValue[currentBar]>adIndValue[baseBar];

            if(!IsDiscreteValues) // Aroon oscillator uses IsDiscreteValues = true
              {
               bool isNoChange=true;
               while(MathAbs(adIndValue[currentBar]-adIndValue[baseBar])<sigma && 
                     isNoChange && baseBar>firstBar)
                 {
                  isNoChange=(isHigher==(adIndValue[baseBar+1]>adIndValue[baseBar]));
                  baseBar--;
                 }
              }

            indCompLong.Value[bar]  = adIndValue[baseBar] < adIndValue[currentBar] - sigma ? 1 : 0;
            indCompShort.Value[bar] = adIndValue[baseBar] > adIndValue[currentBar] + sigma ? 1 : 0;
           }
         break;

      case IndicatorLogic_The_indicator_falls:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            int  currentBar = bar - previous;
            int  baseBar    = currentBar - 1;
            bool isHigher   = adIndValue[currentBar] > adIndValue[baseBar];

            if(!IsDiscreteValues) // Aroon oscillator uses IsDiscreteValues = true
              {
               bool isNoChange=true;
               while(MathAbs(adIndValue[currentBar]-adIndValue[baseBar])<sigma && isNoChange && 
                     baseBar>firstBar)
                 {
                  isNoChange=(isHigher==(adIndValue[baseBar+1]>adIndValue[baseBar]));
                  baseBar--;
                 }
              }

            indCompLong.Value[bar]  = adIndValue[baseBar] > adIndValue[currentBar] + sigma ? 1 : 0;
            indCompShort.Value[bar] = adIndValue[baseBar] < adIndValue[currentBar] - sigma ? 1 : 0;
           }
         break;

      case IndicatorLogic_The_indicator_is_higher_than_the_level_line:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            indCompLong.Value[bar]  = adIndValue[bar - previous] > levelLong + sigma  ? 1 : 0;
            indCompShort.Value[bar] = adIndValue[bar - previous] < levelShort - sigma ? 1 : 0;
           }
         break;

      case IndicatorLogic_The_indicator_is_lower_than_the_level_line:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            indCompLong.Value[bar]  = adIndValue[bar - previous] < levelLong - sigma  ? 1 : 0;
            indCompShort.Value[bar] = adIndValue[bar - previous] > levelShort + sigma ? 1 : 0;
           }
         break;

      case IndicatorLogic_The_indicator_crosses_the_level_line_upward:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            int baseBar=bar-previous-1;
            while(MathAbs(adIndValue[baseBar]-levelLong)<sigma && baseBar>firstBar)
               baseBar--;

            indCompLong.Value[bar]=(adIndValue[baseBar]<levelLong-sigma && 
                                    adIndValue[bar-previous]>levelLong+sigma) ? 1 : 0;
            indCompShort.Value[bar]=(adIndValue[baseBar]>levelShort+sigma && 
                                     adIndValue[bar-previous]<levelShort-sigma) ? 1 : 0;
           }
         break;

      case IndicatorLogic_The_indicator_crosses_the_level_line_downward:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            int baseBar=bar-previous-1;
            while(MathAbs(adIndValue[baseBar]-levelLong)<sigma && baseBar>firstBar)
               baseBar--;

            indCompLong.Value[bar]=(adIndValue[baseBar]>levelLong+sigma && 
                                    adIndValue[bar-previous]<levelLong-sigma) ? 1 : 0;
            indCompShort.Value[bar]=(adIndValue[baseBar]<levelShort-sigma && 
                                     adIndValue[bar-previous]>levelShort+sigma) ? 1 : 0;
           }
         break;

      case IndicatorLogic_The_indicator_changes_its_direction_upward:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            int bar0 = bar - previous;
            int bar1 = bar0 - 1;
            while(MathAbs(adIndValue[bar0]-adIndValue[bar1])<sigma && bar1>firstBar)
               bar1--;

            int iBar2=bar1-1>firstBar ? bar1-1 : firstBar;
            while(MathAbs(adIndValue[bar1]-adIndValue[iBar2])<sigma && iBar2>firstBar)
               iBar2--;

            indCompLong.Value[bar]=(adIndValue[iBar2]>adIndValue[bar1] && adIndValue[bar1]<adIndValue[bar0] && 
                                    bar1==bar0-1) ? 1 : 0;
            indCompShort.Value[bar]=(adIndValue[iBar2]<adIndValue[bar1] && 
                                     adIndValue[bar1]>adIndValue[bar0] && bar1==bar0-1) ? 1 : 0;
           }
         break;

      case IndicatorLogic_The_indicator_changes_its_direction_downward:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            int bar0 = bar - previous;
            int bar1 = bar0 - 1;
            while(MathAbs(adIndValue[bar0]-adIndValue[bar1])<sigma && bar1>firstBar)
               bar1--;

            int iBar2=bar1-1>firstBar ? bar1-1 : firstBar;
            while(MathAbs(adIndValue[bar1]-adIndValue[iBar2])<sigma && iBar2>firstBar)
               iBar2--;

            indCompLong.Value[bar]=(adIndValue[iBar2]<adIndValue[bar1] && adIndValue[bar1]>adIndValue[bar0] && 
                                    bar1==bar0-1) ? 1 : 0;
            indCompShort.Value[bar]=(adIndValue[iBar2]>adIndValue[bar1] && 
                                     adIndValue[bar1]<adIndValue[bar0] && bar1==bar0-1) ? 1 : 0;
           }
         break;

      default:
         return;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::NoDirectionOscillatorLogic(int firstBar,int previous,const double &adIndValue[],double dLevel,
                                           IndicatorComp &indComp,IndicatorLogic indLogic)
  {
   double sigma=Sigma();
   firstBar=MathMax(firstBar,2);

   for(int bar=0; bar<firstBar; bar++)
      indComp.Value[bar]=0;

   switch(indLogic)
     {
      case IndicatorLogic_The_indicator_rises:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            int  currentBar = bar - previous;
            int  baseBar    = currentBar - 1;
            bool isHigher   = adIndValue[currentBar] > adIndValue[baseBar];
            bool isNoChange = true;

            while(MathAbs(adIndValue[currentBar]-adIndValue[baseBar])<sigma && isNoChange && baseBar>firstBar)
              {
               isNoChange=(isHigher==(adIndValue[baseBar+1]>adIndValue[baseBar]));
               baseBar--;
              }

            indComp.Value[bar]=adIndValue[baseBar]<adIndValue[currentBar]-sigma ? 1 : 0;
           }
         break;

      case IndicatorLogic_The_indicator_falls:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            int  currentBar = bar - previous;
            int  baseBar    = currentBar - 1;
            bool isHigher   = adIndValue[currentBar] > adIndValue[baseBar];
            bool isNoChange = true;

            while(MathAbs(adIndValue[currentBar]-adIndValue[baseBar])<sigma && isNoChange && baseBar>firstBar)
              {
               isNoChange=(isHigher==(adIndValue[baseBar+1]>adIndValue[baseBar]));
               baseBar--;
              }

            indComp.Value[bar]=adIndValue[baseBar]>adIndValue[currentBar]+sigma ? 1 : 0;
           }
         break;

      case IndicatorLogic_The_indicator_is_higher_than_the_level_line:
         for(int bar=firstBar; bar<Data.Bars; bar++)
         indComp.Value[bar]=adIndValue[bar-previous]>dLevel+sigma ? 1 : 0;
         break;

      case IndicatorLogic_The_indicator_is_lower_than_the_level_line:
         for(int bar=firstBar; bar<Data.Bars; bar++)
         indComp.Value[bar]=adIndValue[bar-previous]<dLevel-sigma ? 1 : 0;
         break;

      case IndicatorLogic_The_indicator_crosses_the_level_line_upward:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            int baseBar=bar-previous-1;
            while(MathAbs(adIndValue[baseBar]-dLevel)<sigma && baseBar>firstBar)
               baseBar--;

            indComp.Value[bar]=(adIndValue[baseBar]<dLevel-sigma && 
                                adIndValue[bar-previous]>dLevel+sigma)
            ? 1 : 0;
           }
         break;

      case IndicatorLogic_The_indicator_crosses_the_level_line_downward:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            int baseBar=bar-previous-1;
            while(MathAbs(adIndValue[baseBar]-dLevel)<sigma && baseBar>firstBar)
               baseBar--;

            indComp.Value[bar]=(adIndValue[baseBar]>dLevel+sigma && 
                                adIndValue[bar-previous]<dLevel-sigma) ? 1 : 0;
           }
         break;

      case IndicatorLogic_The_indicator_changes_its_direction_upward:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            int bar0 = bar - previous;
            int bar1 = bar0 - 1;
            while(MathAbs(adIndValue[bar0]-adIndValue[bar1])<sigma && bar1>firstBar)
               bar1--;

            int bar2=bar1-1>firstBar ? bar1-1 : firstBar;
            while(MathAbs(adIndValue[bar1]-adIndValue[bar2])<sigma && bar2>firstBar)
               bar2--;

            indComp.Value[bar]=(adIndValue[bar2]>adIndValue[bar1] && adIndValue[bar1]<adIndValue[bar0] && 
                                bar1==bar0-1) ? 1 : 0;
           }
         break;

      case IndicatorLogic_The_indicator_changes_its_direction_downward:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            int bar0 = bar - previous;
            int bar1 = bar0 - 1;
            while(MathAbs(adIndValue[bar0]-adIndValue[bar1])<sigma && bar1>firstBar)
               bar1--;

            int bar2=bar1-1>firstBar ? bar1-1 : firstBar;
            while(MathAbs(adIndValue[bar1]-adIndValue[bar2])<sigma && bar2>firstBar)
               bar2--;

            indComp.Value[bar]=(adIndValue[bar2]<adIndValue[bar1] && adIndValue[bar1]>adIndValue[bar0] && 
                                bar1==bar0-1) ? 1 : 0;
           }
         break;

      default:
         return;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::BandIndicatorLogic(int firstBar,int previous,const double &adUpperBand[],const double &adLowerBand[],
                                   IndicatorComp &indCompLong,IndicatorComp &indCompShort,BandIndLogic indLogic)
  {
   double sigma=Sigma();
   firstBar=MathMax(firstBar,2);

   for(int bar=0; bar<firstBar; bar++)
     {
      indCompLong.Value[bar]  = 0;
      indCompShort.Value[bar] = 0;
     }

   switch(indLogic)
     {
      case BandIndLogic_The_bar_opens_below_the_Upper_Band:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            indCompLong.Value[bar]  = Data.Open[bar] < adUpperBand[bar - previous] - sigma ? 1 : 0;
            indCompShort.Value[bar] = Data.Open[bar] > adLowerBand[bar - previous] + sigma ? 1 : 0;
           }
         break;

      case BandIndLogic_The_bar_opens_above_the_Upper_Band:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            indCompLong.Value[bar]  = Data.Open[bar] > adUpperBand[bar - previous] + sigma ? 1 : 0;
            indCompShort.Value[bar] = Data.Open[bar] < adLowerBand[bar - previous] - sigma ? 1 : 0;
           }
         break;

      case BandIndLogic_The_bar_opens_below_the_Lower_Band:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            indCompLong.Value[bar]  = Data.Open[bar] < adLowerBand[bar - previous] - sigma ? 1 : 0;
            indCompShort.Value[bar] = Data.Open[bar] > adUpperBand[bar - previous] + sigma ? 1 : 0;
           }
         break;

      case BandIndLogic_The_bar_opens_above_the_Lower_Band:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            indCompLong.Value[bar]  = Data.Open[bar] > adLowerBand[bar - previous] + sigma ? 1 : 0;
            indCompShort.Value[bar] = Data.Open[bar] < adUpperBand[bar - previous] - sigma ? 1 : 0;
           }
         break;

      case BandIndLogic_The_bar_opens_below_Upper_Band_after_above:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            int baseBar=bar-1;
            while(MathAbs(Data.Open[baseBar]-adUpperBand[baseBar-previous])<sigma && baseBar>firstBar)
               baseBar--;

            indCompLong.Value[bar]=Data.Open[bar]<adUpperBand[bar-previous]-sigma && 
                                   Data.Open[baseBar]>adUpperBand[baseBar-previous]+sigma ? 1 : 0;

            baseBar=bar-1;
            while(MathAbs(Data.Open[baseBar]-adLowerBand[baseBar-previous])<sigma && baseBar>firstBar)
               baseBar--;

            indCompShort.Value[bar]=Data.Open[bar]>adLowerBand[bar-previous]+sigma && 
                                    Data.Open[baseBar]<adLowerBand[baseBar-previous]-sigma ? 1 : 0;
           }
         break;

      case BandIndLogic_The_bar_opens_above_Upper_Band_after_below:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            int baseBar=bar-1;
            while(MathAbs(Data.Open[baseBar]-adUpperBand[baseBar-previous])<sigma && baseBar>firstBar)
               baseBar--;

            indCompLong.Value[bar]=Data.Open[bar]>adUpperBand[bar-previous]+sigma && 
                                   Data.Open[baseBar]<adUpperBand[baseBar-previous]-sigma ? 1 : 0;

            baseBar=bar-1;
            while(MathAbs(Data.Open[baseBar]-adLowerBand[baseBar-previous])<sigma && baseBar>firstBar)
               baseBar--;

            indCompShort.Value[bar]=Data.Open[bar]<adLowerBand[bar-previous]-sigma && 
                                    Data.Open[baseBar]>adLowerBand[baseBar-previous]+sigma ? 1 : 0;
           }
         break;

      case BandIndLogic_The_bar_opens_below_Lower_Band_after_above:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            int baseBar=bar-1;
            while(MathAbs(Data.Open[baseBar]-adLowerBand[baseBar-previous])<sigma && baseBar>firstBar)
               baseBar--;

            indCompLong.Value[bar]=Data.Open[bar]<adLowerBand[bar-previous]-sigma && 
                                   Data.Open[baseBar]>adLowerBand[baseBar-previous]+sigma ? 1 : 0;

            baseBar=bar-1;
            while(MathAbs(Data.Open[baseBar]-adUpperBand[baseBar-previous])<sigma && baseBar>firstBar)
               baseBar--;

            indCompShort.Value[bar]=Data.Open[bar]>adUpperBand[bar-previous]+sigma && 
                                    Data.Open[baseBar]<adUpperBand[baseBar-previous]-sigma ? 1 : 0;
           }
         break;

      case BandIndLogic_The_bar_opens_above_Lower_Band_after_below:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            int baseBar=bar-1;
            while(MathAbs(Data.Open[baseBar]-adLowerBand[baseBar-previous])<sigma && baseBar>firstBar)
               baseBar--;

            indCompLong.Value[bar]=Data.Open[bar]>adLowerBand[bar-previous]+sigma && 
                                   Data.Open[baseBar]<adLowerBand[baseBar-previous]-sigma ? 1 : 0;

            baseBar=bar-1;
            while(MathAbs(Data.Open[baseBar]-adUpperBand[baseBar-previous])<sigma && baseBar>firstBar)
               baseBar--;

            indCompShort.Value[bar]=Data.Open[bar]<adUpperBand[bar-previous]-sigma && 
                                    Data.Open[baseBar]>adUpperBand[baseBar-previous]+sigma ? 1 : 0;
           }
         break;

      case BandIndLogic_The_bar_closes_below_the_Upper_Band:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            indCompLong.Value[bar]  = Data.Close[bar] < adUpperBand[bar - previous] - sigma ? 1 : 0;
            indCompShort.Value[bar] = Data.Close[bar] > adLowerBand[bar - previous] + sigma ? 1 : 0;
           }
         break;

      case BandIndLogic_The_bar_closes_above_the_Upper_Band:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            indCompLong.Value[bar]  = Data.Close[bar] > adUpperBand[bar - previous] + sigma ? 1 : 0;
            indCompShort.Value[bar] = Data.Close[bar] < adLowerBand[bar - previous] - sigma ? 1 : 0;
           }
         break;

      case BandIndLogic_The_bar_closes_below_the_Lower_Band:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            indCompLong.Value[bar]  = Data.Close[bar] < adLowerBand[bar - previous] - sigma ? 1 : 0;
            indCompShort.Value[bar] = Data.Close[bar] > adUpperBand[bar - previous] + sigma ? 1 : 0;
           }
         break;

      case BandIndLogic_The_bar_closes_above_the_Lower_Band:
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            indCompLong.Value[bar]  = Data.Close[bar] > adLowerBand[bar - previous] + sigma ? 1 : 0;
            indCompShort.Value[bar] = Data.Close[bar] < adUpperBand[bar - previous] - sigma ? 1 : 0;
           }
         break;

      default:
         return;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::IndicatorRisesLogic(int firstBar,int previous,const double &adIndValue[],IndicatorComp &indCompLong,
                                    IndicatorComp &indCompShort)
  {
   double sigma=Sigma();
   firstBar=MathMax(firstBar,2);

   for(int bar=0; bar<firstBar; bar++)
     {
      indCompLong.Value[bar]  = 0;
      indCompShort.Value[bar] = 0;
     }

   for(int bar=firstBar; bar<Data.Bars; bar++)
     {
      int  currentBar = bar - previous;
      int  baseBar    = currentBar - 1;
      bool isNoChange = true;
      bool isHigher   = adIndValue[currentBar] > adIndValue[baseBar];

      while(MathAbs(adIndValue[currentBar]-adIndValue[baseBar])<sigma && isNoChange && 
            baseBar>firstBar)
        {
         isNoChange=(isHigher==(adIndValue[baseBar+1]>adIndValue[baseBar]));
         baseBar--;
        }

      indCompLong.Value[bar]  = adIndValue[currentBar] > adIndValue[baseBar] + sigma ? 1 : 0;
      indCompShort.Value[bar] = adIndValue[currentBar] < adIndValue[baseBar] - sigma ? 1 : 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::IndicatorFallsLogic(int firstBar,int previous,const double &adIndValue[],IndicatorComp &indCompLong,
                                    IndicatorComp &indCompShort)
  {
   double sigma=Sigma();
   firstBar=MathMax(firstBar,2);

   for(int bar=0; bar<firstBar; bar++)
     {
      indCompLong.Value[bar]=0;
      indCompShort.Value[bar]=0;
     }

   for(int bar=firstBar; bar<Data.Bars; bar++)
     {
      int currentBar=bar-previous;
      int baseBar=currentBar-1;
      bool isNoChange=true;
      bool isLower=adIndValue[currentBar]<adIndValue[baseBar];

      while(MathAbs(adIndValue[currentBar]-adIndValue[baseBar])<sigma && isNoChange && 
            baseBar>firstBar)
        {
         isNoChange=(isLower==(adIndValue[baseBar+1]<adIndValue[baseBar]));
         baseBar--;
        }

      indCompLong.Value[bar]  = adIndValue[currentBar] < adIndValue[baseBar] - sigma ? 1 : 0;
      indCompShort.Value[bar] = adIndValue[currentBar] > adIndValue[baseBar] + sigma ? 1 : 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::IndicatorIsHigherThanAnotherIndicatorLogic(int firstBar,int previous,const double &adIndValue[],
                                                           double &adAnotherIndValue[],IndicatorComp &indCompLong,
                                                           IndicatorComp &indCompShort)
  {
   double sigma=Sigma();
   firstBar=MathMax(firstBar,2);

   for(int bar=0; bar<firstBar; bar++)
     {
      indCompLong.Value[bar]=0;
      indCompShort.Value[bar]=0;
     }

   for(int bar=firstBar; bar<Data.Bars; bar++)
     {
      int currentBar=bar-previous;
      indCompLong.Value[bar]  = adIndValue[currentBar] > adAnotherIndValue[currentBar] + sigma ? 1 : 0;
      indCompShort.Value[bar] = adIndValue[currentBar] < adAnotherIndValue[currentBar] - sigma ? 1 : 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::IndicatorIsLowerThanAnotherIndicatorLogic(int firstBar,int previous,const double &adIndValue[],
                                                          double &adAnotherIndValue[],IndicatorComp &indCompLong,
                                                          IndicatorComp &indCompShort)
  {
   double sigma=Sigma();
   firstBar=MathMax(firstBar,2);

   for(int bar=0; bar<firstBar; bar++)
     {
      indCompLong.Value[bar]  = 0;
      indCompShort.Value[bar] = 0;
     }

   for(int bar=firstBar; bar<Data.Bars; bar++)
     {
      int currentBar=bar-previous;
      indCompLong.Value[bar]  = adIndValue[currentBar] < adAnotherIndValue[currentBar] - sigma ? 1 : 0;
      indCompShort.Value[bar] = adIndValue[currentBar] > adAnotherIndValue[currentBar] + sigma ? 1 : 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::IndicatorChangesItsDirectionUpward(int firstBar,int previous,double &adIndValue[],
                                                   IndicatorComp &indCompLong,IndicatorComp &indCompShort)
  {
   double sigma= Sigma();
   for(int bar = firstBar; bar<Data.Bars; bar++)
     {
      int bar0 = bar - previous;
      int bar1 = bar0 - 1;
      while(MathAbs(adIndValue[bar0]-adIndValue[bar1])<sigma && bar1>firstBar)
         bar1--;

      int bar2=bar1-1>firstBar ? bar1-1 : firstBar;
      while(MathAbs(adIndValue[bar1]-adIndValue[bar2])<sigma && bar2>firstBar)
         bar2--;

      indCompLong.Value[bar]=(adIndValue[bar2]>adIndValue[bar1] && adIndValue[bar1]<adIndValue[bar0] && 
                              bar1==bar0-1) ? 1 : 0;
      indCompShort.Value[bar]=(adIndValue[bar2]<adIndValue[bar1] && adIndValue[bar1]>adIndValue[bar0] && 
                               bar1==bar0-1) ? 1 : 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::IndicatorChangesItsDirectionDownward(int firstBar,int previous,double &adIndValue[],
                                                     IndicatorComp &indCompLong,IndicatorComp &indCompShort)
  {
   double sigma= Sigma();
   for(int bar = firstBar; bar<Data.Bars; bar++)
     {
      int bar0 = bar - previous;
      int bar1 = bar0 - 1;
      while(MathAbs(adIndValue[bar0]-adIndValue[bar1])<sigma && bar1>firstBar)
         bar1--;

      int bar2=bar1-1>firstBar ? bar1-1 : firstBar;
      while(MathAbs(adIndValue[bar1]-adIndValue[bar2])<sigma && bar2>firstBar)
         bar2--;

      indCompLong.Value[bar]=(adIndValue[bar2]<adIndValue[bar1] && adIndValue[bar1]>adIndValue[bar0] && 
                              bar1==bar0-1) ? 1 : 0;
      indCompShort.Value[bar]=(adIndValue[bar2]>adIndValue[bar1] && adIndValue[bar1]<adIndValue[bar0] && 
                               bar1==bar0-1) ? 1 : 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::IndicatorCrossesAnotherIndicatorUpwardLogic(int firstBar,int previous,const double &adIndValue[],
                                                            double &adAnotherIndValue[],IndicatorComp &indCompLong,
                                                            IndicatorComp &indCompShort)
  {
   double sigma=Sigma();
   firstBar=MathMax(firstBar,2);

   for(int bar=0; bar<firstBar; bar++)
     {
      indCompLong.Value[bar]=0;
      indCompShort.Value[bar]=0;
     }

   for(int bar=firstBar; bar<Data.Bars; bar++)
     {
      int currentBar=bar-previous;
      int baseBar=currentBar-1;
      while(MathAbs(adIndValue[baseBar]-adAnotherIndValue[baseBar])<sigma && baseBar>firstBar)
         baseBar--;

      indCompLong.Value[bar]=adIndValue[currentBar]>adAnotherIndValue[currentBar]+sigma && 
                             adIndValue[baseBar]<adAnotherIndValue[baseBar]-sigma ? 1 : 0;
      indCompShort.Value[bar]=adIndValue[currentBar]<adAnotherIndValue[currentBar]-sigma && 
                              adIndValue[baseBar]>adAnotherIndValue[baseBar]+sigma ? 1 : 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::IndicatorCrossesAnotherIndicatorDownwardLogic(int firstBar,int previous,const double &adIndValue[],
                                                              double &adAnotherIndValue[],IndicatorComp &indCompLong,
                                                              IndicatorComp &indCompShort)
  {
   double sigma=Sigma();
   firstBar=MathMax(firstBar,2);

   for(int bar=0; bar<firstBar; bar++)
     {
      indCompLong.Value[bar]=0;
      indCompShort.Value[bar]=0;
     }

   for(int bar=firstBar; bar<Data.Bars; bar++)
     {
      int currentBar=bar-previous;
      int baseBar=currentBar-1;
      while(MathAbs(adIndValue[baseBar]-adAnotherIndValue[baseBar])<sigma && baseBar>firstBar)
        {
         baseBar--;
        }

      indCompLong.Value[bar]=adIndValue[currentBar]<adAnotherIndValue[currentBar]-sigma && 
                             adIndValue[baseBar]>adAnotherIndValue[baseBar]+sigma ? 1 : 0;
      indCompShort.Value[bar]=adIndValue[currentBar]>adAnotherIndValue[currentBar]+sigma && 
                              adIndValue[baseBar]<adAnotherIndValue[baseBar]-sigma ? 1 : 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::BarOpensAboveIndicatorLogic(int firstBar,int previous,const double &adIndValue[],
                                            IndicatorComp &indCompLong,IndicatorComp &indCompShort)
  {
   double sigma=Sigma();
   firstBar=MathMax(firstBar,2);

   for(int bar=0; bar<firstBar; bar++)
     {
      indCompLong.Value[bar]  = 0;
      indCompShort.Value[bar] = 0;
     }

   for(int bar=firstBar; bar<Data.Bars; bar++)
     {
      indCompLong.Value[bar]  = Data.Open[bar] > adIndValue[bar - previous] + sigma ? 1 : 0;
      indCompShort.Value[bar] = Data.Open[bar] < adIndValue[bar - previous] - sigma ? 1 : 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::BarOpensBelowIndicatorLogic(int firstBar,int previous,const double &adIndValue[],
                                            IndicatorComp &indCompLong,IndicatorComp &indCompShort)
  {
   double sigma=Sigma();
   firstBar=MathMax(firstBar,2);

   for(int bar=0; bar<firstBar; bar++)
     {
      indCompLong.Value[bar]=0;
      indCompShort.Value[bar]=0;
     }

   for(int bar=firstBar; bar<Data.Bars; bar++)
     {
      indCompLong.Value[bar]  = Data.Open[bar] < adIndValue[bar - previous] - sigma ? 1 : 0;
      indCompShort.Value[bar] = Data.Open[bar] > adIndValue[bar - previous] + sigma ? 1 : 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::BarOpensAboveIndicatorAfterOpeningBelowLogic(int firstBar,int previous,const double &adIndValue[],
                                                             IndicatorComp &indCompLong,IndicatorComp &indCompShort)
  {
   double sigma=Sigma();
   firstBar=MathMax(firstBar,2);

   for(int bar=0; bar<firstBar; bar++)
     {
      indCompLong.Value[bar]=0;
      indCompShort.Value[bar]=0;
     }

   for(int bar=firstBar; bar<Data.Bars; bar++)
     {
      int baseBar=bar-1;
      while(MathAbs(Data.Open[baseBar]-adIndValue[baseBar-previous])<sigma && baseBar>firstBar)
         baseBar--;

      indCompLong.Value[bar]=Data.Open[bar]>adIndValue[bar-previous]+sigma && 
                             Data.Open[baseBar]<adIndValue[baseBar-previous]-sigma ? 1 : 0;
      indCompShort.Value[bar]=Data.Open[bar]<adIndValue[bar-previous]-sigma && 
                              Data.Open[baseBar]>adIndValue[baseBar-previous]+sigma ? 1 : 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::BarOpensBelowIndicatorAfterOpeningAboveLogic(int firstBar,int previous,const double &adIndValue[],
                                                             IndicatorComp &indCompLong,IndicatorComp &indCompShort)
  {
   double sigma=Sigma();
   firstBar=MathMax(firstBar,2);

   for(int bar=0; bar<firstBar; bar++)
     {
      indCompLong.Value[bar]=0;
      indCompShort.Value[bar]=0;
     }

   for(int bar=firstBar; bar<Data.Bars; bar++)
     {
      int baseBar=bar-1;
      while(MathAbs(Data.Open[baseBar]-adIndValue[baseBar-previous])<sigma && baseBar>firstBar)
         baseBar--;

      indCompLong.Value[bar]=Data.Open[bar]<adIndValue[bar-previous]-sigma && 
                             Data.Open[baseBar]>adIndValue[baseBar-previous]+sigma ? 1 : 0;
      indCompShort.Value[bar]=Data.Open[bar]>adIndValue[bar-previous]+sigma && 
                              Data.Open[baseBar]<adIndValue[baseBar-previous]-sigma ? 1 : 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::BarClosesAboveIndicatorLogic(int firstBar,int previous,const double &adIndValue[],
                                             IndicatorComp &indCompLong,IndicatorComp &indCompShort)
  {
   double sigma=Sigma();
   firstBar=MathMax(firstBar,2);

   for(int bar=0; bar<firstBar; bar++)
     {
      indCompLong.Value[bar]  = 0;
      indCompShort.Value[bar] = 0;
     }

   for(int bar=firstBar; bar<Data.Bars; bar++)
     {
      indCompLong.Value[bar]  = Data.Close[bar] > adIndValue[bar - previous] + sigma ? 1 : 0;
      indCompShort.Value[bar] = Data.Close[bar] < adIndValue[bar - previous] - sigma ? 1 : 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Indicator::BarClosesBelowIndicatorLogic(int firstBar,int previous,const double &adIndValue[],
                                             IndicatorComp &indCompLong,IndicatorComp &indCompShort)
  {
   double sigma=Sigma();
   firstBar=MathMax(firstBar,2);

   for(int bar=0; bar<firstBar; bar++)
     {
      indCompLong.Value[bar]  = 0;
      indCompShort.Value[bar] = 0;
     }

   for(int bar=firstBar; bar<Data.Bars; bar++)
     {
      indCompLong.Value[bar]  = Data.Close[bar] < adIndValue[bar - previous] - sigma ? 1 : 0;
      indCompShort.Value[bar] = Data.Close[bar] > adIndValue[bar - previous] + sigma ? 1 : 0;
     }
  }
//+------------------------------------------------------------------+
