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
class BullsPower : public Indicator
  {
public:
   BullsPower(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="Bulls Power";

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
void BullsPower::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

// Reading the parameters
   MAMethod maMethod=(MAMethod) ListParam[1].Index;
   int iPeriod=(int) NumParam[0].Value;
   double dLevel=NumParam[1].Value;
   int prev=CheckParam[0].Checked ? 1 : 0;

// Calculation
   int firstBar=iPeriod+2;
   double adMA[]; MovingAverage(iPeriod,0,maMethod,Data.Close,adMA);
   double adBulls[]; ArrayResize(adBulls,Data.Bars); ArrayInitialize(adBulls,0);

   for(int bar=iPeriod; bar<Data.Bars; bar++)
      adBulls[bar]=Data.High[bar]-adMA[bar];

// Saving the components

   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "Bulls Power";
   Component[0].DataType = IndComponentType_IndicatorValue;
   Component[0].FirstBar = firstBar;
   ArrayCopy(Component[0].Value,adBulls);

   ArrayResize(Component[1].Value,Data.Bars);
   Component[1].FirstBar=firstBar;

   ArrayResize(Component[2].Value,Data.Bars);
   Component[2].FirstBar=firstBar;

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

   if(ListParam[0].Text=="Bulls Power rises") 
      indLogic=IndicatorLogic_The_indicator_rises;
   else if(ListParam[0].Text=="Bulls Power falls") 
      indLogic=IndicatorLogic_The_indicator_falls;
   else if(ListParam[0].Text=="Bulls Power is higher than the Level line") 
      indLogic=IndicatorLogic_The_indicator_is_higher_than_the_level_line;
   else if(ListParam[0].Text=="Bulls Power is lower than the Level line") 
      indLogic=IndicatorLogic_The_indicator_is_lower_than_the_level_line;
   else if(ListParam[0].Text=="Bulls Power crosses the Level line upward") 
      indLogic=IndicatorLogic_The_indicator_crosses_the_level_line_upward;
   else if(ListParam[0].Text=="Bulls Power crosses the Level line downward") 
      indLogic=IndicatorLogic_The_indicator_crosses_the_level_line_downward;
   else if(ListParam[0].Text=="Bulls Power changes its direction upward") 
      indLogic=IndicatorLogic_The_indicator_changes_its_direction_upward;
   else if(ListParam[0].Text=="Bulls Power changes its direction downward") 
      indLogic=IndicatorLogic_The_indicator_changes_its_direction_downward;

   OscillatorLogic(firstBar,prev,adBulls,dLevel,-dLevel,Component[1],Component[2],indLogic);
  }
//+------------------------------------------------------------------+
