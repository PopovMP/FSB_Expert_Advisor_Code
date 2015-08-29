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
class MoneyFlowIndex : public Indicator
  {
public:
    MoneyFlowIndex(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="Money Flow Index";

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
void MoneyFlowIndex::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

// Reading the parameters
   int iPeriod=(int) NumParam[0].Value;
   double dLevel=NumParam[1].Value;
   int iPrvs=CheckParam[0].Checked ? 1 : 0;

   int iFirstBar=iPeriod+iPrvs;

// Calculating Money Flow
   double adMf[]; ArrayResize(adMf,Data.Bars);ArrayInitialize(adMf,0);
   for(int iBar=1; iBar<Data.Bars; iBar++)
     {
      double dAvg=(Data.High[iBar]+Data.Low[iBar]+Data.Close[iBar])/3;
      double dAvg1=(Data.High[iBar-1]+Data.Low[iBar-1]+Data.Close[iBar-1])/3;
      if(dAvg>dAvg1)
         adMf[iBar]=adMf[iBar-1]+dAvg*Data.Volume[iBar];
      else if(dAvg<dAvg1)
         adMf[iBar]=adMf[iBar-1]-dAvg*Data.Volume[iBar];
      else
         adMf[iBar]=adMf[iBar-1];
     }

// Calculating Money Flow Index
   double adMfi[]; ArrayResize(adMfi,Data.Bars);ArrayInitialize(adMfi,0);
   for(int iBar=iPeriod+1; iBar<Data.Bars; iBar++)
     {
      double dPmf = 0;
      double dNmf = 0;
      for(int index=0; index<iPeriod; index++)
        {
         if(adMf[iBar-index]>adMf[iBar-index-1])
            dPmf+=adMf[iBar-index]-adMf[iBar-index-1];
         if(adMf[iBar-index]<adMf[iBar-index-1])
            dNmf+=adMf[iBar-index-1]-adMf[iBar-index];
        }
      if(MathAbs(dNmf)<Epsilon())
         adMfi[iBar]=100.0;
      else
         adMfi[iBar]=100.0 -(100.0/(1.0+(dPmf/dNmf)));
     }

// Saving the components

   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "Money Flow Index";
   Component[0].DataType = IndComponentType_IndicatorValue;
   Component[0].FirstBar = iFirstBar;
   ArrayCopy(Component[0].Value,adMfi);

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

   if(ListParam[0].Text=="MFI rises") 
      indLogic=IndicatorLogic_The_indicator_rises;
   else if(ListParam[0].Text=="MFI falls") 
      indLogic=IndicatorLogic_The_indicator_falls;
   else if(ListParam[0].Text=="MFI is higher than the Level line") 
      indLogic=IndicatorLogic_The_indicator_is_higher_than_the_level_line;
   else if(ListParam[0].Text=="MFI is lower than the Level line") 
      indLogic=IndicatorLogic_The_indicator_is_lower_than_the_level_line;
   else if(ListParam[0].Text=="MFI crosses the Level line upward") 
      indLogic=IndicatorLogic_The_indicator_crosses_the_level_line_upward;
   else if(ListParam[0].Text=="MFI crosses the Level line downward") 
      indLogic=IndicatorLogic_The_indicator_crosses_the_level_line_downward;
   else if(ListParam[0].Text=="MFI changes its direction upward") 
      indLogic=IndicatorLogic_The_indicator_changes_its_direction_upward;
   else if(ListParam[0].Text=="MFI changes its direction downward") 
      indLogic=IndicatorLogic_The_indicator_changes_its_direction_downward;

   OscillatorLogic(iFirstBar,iPrvs,adMfi,dLevel,100-dLevel,Component[1],Component[2],indLogic);
  }
//+------------------------------------------------------------------+
