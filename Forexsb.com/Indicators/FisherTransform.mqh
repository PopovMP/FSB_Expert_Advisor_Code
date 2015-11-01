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
class FisherTransform : public Indicator
  {
public:
    FisherTransform(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="Fisher Transform";

      WarningMessage    = "";
      IsAllowLTF        = true;
      ExecTime          = ExecutionTime_DuringTheBar;
      IsSeparateChart   = true;
      IsDiscreteValues  = false;
      IsDefaultGroupAll = false;
     }

   virtual void Calculate(DataSet &dataSet);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FisherTransform::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

// Reading the parameters
   BasePrice basePrice=(BasePrice) ListParam[1].Index;
   int iPeriod=(int) NumParam[0].Value;
   int iPrvs=CheckParam[0].Checked ? 1 : 0;

// Calculation
   int iFirstBar=iPeriod+2;

   double adPrice[]; Price(basePrice,adPrice);
   double adValue[]; ArrayResize(adValue,Data.Bars); ArrayInitialize(adValue,0);

   for(int iBar=0; iBar<iPeriod; iBar++)
      adValue[iBar]=0;

   for(int iBar=iPeriod; iBar<Data.Bars; iBar++)
     {
      double dHighestHigh=DBL_MIN;
      double dLowestLow=DBL_MAX;
      for(int i=0; i<iPeriod; i++)
        {
         if(adPrice[iBar-i]>dHighestHigh)
            dHighestHigh=adPrice[iBar-i];
         if(adPrice[iBar-i]<dLowestLow)
            dLowestLow=adPrice[iBar-i];
        }

      if(MathAbs(dHighestHigh-dLowestLow)<Epsilon())
         dHighestHigh=dLowestLow+Data.Point;
      if(MathAbs(dHighestHigh-dLowestLow-0.5)<Epsilon())
         dHighestHigh+=Data.Point;

      adValue[iBar]=0.33*2*((adPrice[iBar]-dLowestLow)/(dHighestHigh-dLowestLow)-0.5)+0.67*adValue[iBar - 1];
     }

   double adFt[];
   ArrayResize(adFt,Data.Bars);
   adFt[0]=0;
   for(int iBar=1; iBar<Data.Bars; iBar++)
      adFt[iBar]=0.5*MathLog10((1+adValue[iBar])/(1-adValue[iBar]))+0.5*adFt[iBar-1];

// Saving the components
   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "Fisher Transform";
   Component[0].DataType = IndComponentType_IndicatorValue;
   Component[0].FirstBar = iFirstBar;
   ArrayCopy(Component[0].Value,adFt);

   ArrayResize(Component[1].Value,Data.Bars);
   Component[1].FirstBar=iFirstBar;

   ArrayResize(Component[2].Value,Data.Bars);
   Component[2].FirstBar=iFirstBar;

// Sets the Component's type
   if(SlotType==SlotTypes_OpenFilter)
     {
      Component[1].DataType = IndComponentType_AllowOpenLong;
      Component[1].CompName = "Is long entry allowed";
      Component[2].DataType = IndComponentType_AllowOpenShort;
      Component[2].CompName = "Is short entry allowed";
     }
   else if(SlotType==SlotTypes_CloseFilter)
     {
      Component[1].DataType = IndComponentType_ForceCloseLong;
      Component[1].CompName = "Close out long position";
      Component[2].DataType = IndComponentType_ForceCloseShort;
      Component[2].CompName = "Close out short position";
     }

// Calculation of the logic
   IndicatorLogic indLogic=IndicatorLogic_It_does_not_act_as_a_filter;

   if(ListParam[0].Text=="Fisher Transform rises")
      indLogic=IndicatorLogic_The_indicator_rises;
   else if(ListParam[0].Text=="Fisher Transform falls")
      indLogic=IndicatorLogic_The_indicator_falls;
   else if(ListParam[0].Text=="Fisher Transform is higher than the zero line")
      indLogic=IndicatorLogic_The_indicator_is_higher_than_the_level_line;
   else if(ListParam[0].Text=="Fisher Transform is lower than the zero line")
      indLogic=IndicatorLogic_The_indicator_is_lower_than_the_level_line;
   else if(ListParam[0].Text=="Fisher Transform crosses the zero line upward")
      indLogic=IndicatorLogic_The_indicator_crosses_the_level_line_upward;
   else if(ListParam[0].Text=="Fisher Transform crosses the zero line downward")
      indLogic=IndicatorLogic_The_indicator_crosses_the_level_line_downward;
   else if(ListParam[0].Text=="Fisher Transform changes its direction upward")
      indLogic=IndicatorLogic_The_indicator_changes_its_direction_upward;
   else if(ListParam[0].Text=="Fisher Transform changes its direction downward")
      indLogic=IndicatorLogic_The_indicator_changes_its_direction_downward;

   OscillatorLogic(iFirstBar,iPrvs,adFt,0,0,Component[1],Component[2],indLogic);
  }
//+------------------------------------------------------------------+
