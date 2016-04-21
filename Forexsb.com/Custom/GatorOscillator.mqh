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
class GatorOscillator : public Indicator
  {
public:
    GatorOscillator(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="Gator Oscillator";

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
void GatorOscillator::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

   MAMethod  maMethod  = (MAMethod )ListParam[1].Index;
   BasePrice basePrice = (BasePrice)ListParam[2].Index;
   int iNJaws  = (int)NumParam[0].Value;
   int iSJaws  = (int)NumParam[1].Value;
   int iNTeeth = (int)NumParam[2].Value;
   int iSTeeth = (int)NumParam[3].Value;
   int iNLips  = (int)NumParam[4].Value;
   int iSLips  = (int)NumParam[5].Value;
   int iPrvs   = CheckParam[0].Checked ? 1 : 0;

   int iFirstBar=MathMax(iNJaws+iSJaws+2,iNTeeth+iSTeeth+2);
   iFirstBar=MathMax(iFirstBar,iNLips+iSLips+2);

// Calculation
   double basePrc[];  Price(basePrice,basePrc);
   double adJaws[];   MovingAverage(iNJaws,iSJaws,maMethod,basePrc,adJaws);
   double adTeeth[];  MovingAverage(iNTeeth,iSTeeth,maMethod,basePrc,adTeeth);
   double adLips[];   MovingAverage(iNLips,iSLips,maMethod,basePrc,adLips);

   double adUpperGator[]; ArrayResize(adUpperGator,Data.Bars);
   double adLowerGator[]; ArrayResize(adLowerGator,Data.Bars);

   for(int iBar=0; iBar<Data.Bars; iBar++)
     {
      adUpperGator[iBar] =  MathAbs(adJaws[iBar]  - adTeeth[iBar]);
      adLowerGator[iBar] = -MathAbs(adTeeth[iBar] - adLips[iBar]);
     }

// Saving the components

   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName  = "Upper Gator";
   Component[0].DataType  = IndComponentType_IndicatorValue;
   Component[0].FirstBar  = iFirstBar;
   ArrayCopy(Component[0].Value,adUpperGator);

   ArrayResize(Component[1].Value,Data.Bars);
   Component[1].CompName  = "Lower Gator";
   Component[1].DataType  = IndComponentType_IndicatorValue;
   Component[1].FirstBar  = iFirstBar;
   ArrayCopy(Component[1].Value,adLowerGator);

   ArrayResize(Component[2].Value,Data.Bars);
   Component[2].FirstBar=iFirstBar;

   ArrayResize(Component[3].Value,Data.Bars);
   Component[3].FirstBar=iFirstBar;

// Sets the Component's type.
   if(SlotType==SlotTypes_OpenFilter)
     {
      Component[2].DataType = IndComponentType_AllowOpenLong;
      Component[2].CompName = "Is long entry allowed";
      Component[3].DataType = IndComponentType_AllowOpenShort;
      Component[3].CompName = "Is short entry allowed";
     }
   else if(SlotType==SlotTypes_CloseFilter)
     {
      Component[2].DataType = IndComponentType_ForceCloseLong;
      Component[2].CompName = "Close out long position";
      Component[3].DataType = IndComponentType_ForceCloseShort;
      Component[3].CompName = "Close out short position";
     }

   if(ListParam[0].Text=="The Gator Oscillator expands")
     {
      for(int iBar=iFirstBar; iBar<Data.Bars; iBar++)
        {
         Component[2].Value[iBar]=(adUpperGator[iBar-iPrvs]-adLowerGator[iBar-iPrvs])>
                                  (adUpperGator[iBar-iPrvs-1]-adLowerGator[iBar-iPrvs-1])+
                                  Sigma()? 1: 0;
         Component[3].Value[iBar]=(adUpperGator[iBar-iPrvs]-adLowerGator[iBar-iPrvs])>
                                  (adUpperGator[iBar-iPrvs-1]-adLowerGator[iBar-iPrvs-1])+
                                  Sigma()? 1: 0;
        }
     }
   else if(ListParam[0].Text=="The Gator Oscillator contracts")
     {
      for(int iBar=iFirstBar; iBar<Data.Bars; iBar++)
        {
         Component[2].Value[iBar]=(adUpperGator[iBar-iPrvs]-adLowerGator[iBar-iPrvs])<
                                  (adUpperGator[iBar-iPrvs-1]-adLowerGator[iBar-iPrvs-1]) -
                                  Sigma() ? 1 : 0;
         Component[3].Value[iBar]=(adUpperGator[iBar-iPrvs]-adLowerGator[iBar-iPrvs])<
                                  (adUpperGator[iBar-iPrvs-1]-adLowerGator[iBar-iPrvs-1]) -
                                  Sigma() ? 1 : 0;
        }
     }
  }
//+------------------------------------------------------------------+
