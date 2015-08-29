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
class ChandeMomentumOscillator : public Indicator
  {
public:
   ChandeMomentumOscillator(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="Chande Momentum Oscillator";

      WarningMessage    = "";
      IsAllowLTF        = true;
      ExecTime          = ExecutionTime_DuringTheBar;
      IsSeparateChart   = true;
      IsDiscreteValues  = false;
      IsDeafultGroupAll = false;
     }

   virtual void Calculate(DataSet &dataSet);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChandeMomentumOscillator::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

// Reading parameters
   BasePrice basePrice = (BasePrice)ListParam[2].Index;
   int       iPeriod   = (int)NumParam[0].Value;
   double    dLevel    = NumParam[1].Value;
   int       iPrvs     = CheckParam[0].Checked ? 1 : 0;

// Calculation
   int      iFirstBar=iPeriod+2;
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

// Saving components
   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "CMO";
   Component[0].DataType = IndComponentType_IndicatorValue;
   Component[0].FirstBar = iFirstBar;
   ArrayCopy(Component[0].Value,adCMO);

   ArrayResize(Component[1].Value,Data.Bars);
   Component[1].FirstBar=iFirstBar;

   ArrayResize(Component[2].Value,Data.Bars);
   Component[2].FirstBar=iFirstBar;

// Sets Component's type
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

// Calculation of logic
   IndicatorLogic indLogic=IndicatorLogic_It_does_not_act_as_a_filter;

   if(ListParam[0].Text=="CMO rises")
      indLogic=IndicatorLogic_The_indicator_rises;
   else if(ListParam[0].Text=="CMO falls")
      indLogic=IndicatorLogic_The_indicator_falls;
   else if(ListParam[0].Text=="CMO is higher than Level line")
      indLogic=IndicatorLogic_The_indicator_is_higher_than_the_level_line;
   else if(ListParam[0].Text=="CMO is lower than Level line")
      indLogic=IndicatorLogic_The_indicator_is_lower_than_the_level_line;
   else if(ListParam[0].Text=="CMO crosses Level line upward")
      indLogic=IndicatorLogic_The_indicator_crosses_the_level_line_upward;
   else if(ListParam[0].Text=="CMO crosses Level line downward")
      indLogic=IndicatorLogic_The_indicator_crosses_the_level_line_downward;
   else if(ListParam[0].Text=="CMO changes its direction upward")
      indLogic=IndicatorLogic_The_indicator_changes_its_direction_upward;
   else if(ListParam[0].Text=="CMO changes its direction downward")
      indLogic=IndicatorLogic_The_indicator_changes_its_direction_downward;

   OscillatorLogic(iFirstBar,iPrvs,adCMO,dLevel,-dLevel,Component[1],Component[2],indLogic);
  }
//+------------------------------------------------------------------+
