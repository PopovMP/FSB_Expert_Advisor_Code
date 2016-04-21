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
class AroonHistogram : public Indicator
  {
public:
    AroonHistogram(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="Aroon Histogram";

      WarningMessage    = "";
      IsAllowLTF        = true;
      ExecTime          = ExecutionTime_DuringTheBar;
      IsSeparateChart   = true;
      IsDiscreteValues  = true;
      IsDefaultGroupAll = false;
     }

   virtual void Calculate(DataSet &dataSet);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AroonHistogram::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

// Reading the parameters
   BasePrice basePrice=(BasePrice) ListParam[1].Index;
   int iPeriod=(int) NumParam[0].Value;
   double dLevel=NumParam[1].Value;
   int prev=CheckParam[0].Checked ? 1 : 0;

// Calculation
   int iFirstBar=iPeriod+2;
   double adBasePrice[];
   Price(basePrice,adBasePrice);
   double adUp[];    ArrayResize(adUp,Data.Bars);    ArrayInitialize(adUp,0);
   double adDown[];  ArrayResize(adDown,Data.Bars);  ArrayInitialize(adDown,0);
   double adAroon[]; ArrayResize(adAroon,Data.Bars); ArrayInitialize(adAroon,0);

   for(int bar=iPeriod; bar<Data.Bars; bar++)
     {
      double dHighestHigh=DBL_MIN;
      double dLowestLow  =DBL_MAX;
      for(int i=0; i<iPeriod; i++)
        {
         int iBaseBar=bar-iPeriod+1+i;
         if(adBasePrice[iBaseBar]>dHighestHigh)
           {
            dHighestHigh=adBasePrice[iBaseBar];
            adUp[bar]=100.0*i/(iPeriod-1);
           }
         if(adBasePrice[iBaseBar]<dLowestLow)
           {
            dLowestLow=adBasePrice[iBaseBar];
            adDown[bar]=100.0*i/(iPeriod-1);
           }
        }
     }

   for(int bar=iFirstBar; bar<Data.Bars; bar++)
      adAroon[bar]=adUp[bar]-adDown[bar];

// Saving the components
   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "Aroon Histogram";
   Component[0].DataType = IndComponentType_IndicatorValue;
   Component[0].FirstBar = iFirstBar;
   ArrayCopy(Component[0].Value,adAroon);

   ArrayResize(Component[1].Value,Data.Bars);
   Component[1].CompName = "Aroon Up";
   Component[1].DataType = IndComponentType_IndicatorValue;
   Component[1].FirstBar = iFirstBar;
   ArrayCopy(Component[1].Value,adUp);

   ArrayResize(Component[2].Value,Data.Bars);
   Component[2].CompName = "Aroon Down";
   Component[2].DataType = IndComponentType_IndicatorValue;
   Component[2].FirstBar = iFirstBar;
   ArrayCopy(Component[2].Value,adDown);

   ArrayResize(Component[3].Value,Data.Bars);
   Component[3].FirstBar=iFirstBar;

   ArrayResize(Component[4].Value,Data.Bars);
   Component[4].FirstBar=iFirstBar;

// Sets the Component's type
   if(SlotType==SlotTypes_OpenFilter)
     {
      Component[3].DataType = IndComponentType_AllowOpenLong;
      Component[3].CompName = "Is long entry allowed";
      Component[4].DataType = IndComponentType_AllowOpenShort;
      Component[4].CompName = "Is short entry allowed";
     }
   else if(SlotType==SlotTypes_CloseFilter)
     {
      Component[3].DataType = IndComponentType_ForceCloseLong;
      Component[3].CompName = "Close out long position";
      Component[4].DataType = IndComponentType_ForceCloseShort;
      Component[4].CompName = "Close out short position";
     }

// Calculation of the logic
   IndicatorLogic indLogic=IndicatorLogic_It_does_not_act_as_a_filter;

   if(ListParam[0].Text=="Aroon Histogram rises")
      indLogic=IndicatorLogic_The_indicator_rises;
   else if(ListParam[0].Text=="Aroon Histogram falls")
      indLogic=IndicatorLogic_The_indicator_falls;
   else if(ListParam[0].Text=="Aroon Histogram is higher than the Level line")
      indLogic=IndicatorLogic_The_indicator_is_higher_than_the_level_line;
   else if(ListParam[0].Text=="Aroon Histogram is lower than the Level line")
      indLogic=IndicatorLogic_The_indicator_is_lower_than_the_level_line;
   else if(ListParam[0].Text=="Aroon Histogram crosses the Level line upward")
      indLogic=IndicatorLogic_The_indicator_crosses_the_level_line_upward;
   else if(ListParam[0].Text=="Aroon Histogram crosses the Level line downward")
      indLogic=IndicatorLogic_The_indicator_crosses_the_level_line_downward;
   else if(ListParam[0].Text=="Aroon Histogram changes its direction upward")
      indLogic=IndicatorLogic_The_indicator_changes_its_direction_upward;
   else if(ListParam[0].Text=="Aroon Histogram changes its direction downward")
      indLogic=IndicatorLogic_The_indicator_changes_its_direction_downward;

   OscillatorLogic(iFirstBar,prev,adAroon,dLevel,-dLevel,Component[3],Component[4],indLogic);
  }
//+------------------------------------------------------------------+
