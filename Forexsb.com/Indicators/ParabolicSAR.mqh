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
class ParabolicSAR : public Indicator
  {
public:
   ParabolicSAR(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="Parabolic SAR";

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
void ParabolicSAR::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

   double dAfMin = NumParam[0].Value;
   double dAfInc = NumParam[1].Value;
   double dAfMax = NumParam[2].Value;

// Reading the parameters
   double dPExtr;
   double dPsarNew=0;
   int aiDir[];      ArrayResize(aiDir,Data.Bars);  ArrayInitialize(aiDir,0);
   double adPsar[];  ArrayResize(adPsar,Data.Bars); ArrayInitialize(adPsar,0);

//----	Calculating the initial values
   adPsar[0]=0;
   double dAf=dAfMin;
   int intDirNew=0;
   if(Data.Close[1]>Data.Open[0])
     {
      aiDir[0] = 1;
      aiDir[1] = 1;
      dPExtr=MathMax(Data.High[0],Data.High[1]);
      adPsar[1]=MathMin(Data.Low[0],Data.Low[1]);
     }
   else
     {
      aiDir[0] = -1;
      aiDir[1] = -1;
      dPExtr=MathMin(Data.Low[0],Data.Low[1]);
      adPsar[1]=MathMax(Data.High[0],Data.High[1]);
     }

   for(int bar=2; bar<Data.Bars; bar++)
     {
      //----	PSAR for the current period
      if(intDirNew!=0)
        {
         // The direction was changed during the last period
         aiDir[bar]=intDirNew;
         intDirNew=0;
         adPsar[bar]=dPsarNew+dAf*(dPExtr-dPsarNew);
        }
      else
        {
         aiDir[bar]=aiDir[bar-1];
         adPsar[bar]=adPsar[bar-1]+dAf*(dPExtr-adPsar[bar-1]);
        }

      // PSAR has to be out of the previous two bars limits
      if(aiDir[bar]>0 && adPsar[bar]>MathMin(Data.Low[bar-1],Data.Low[bar-2]))
         adPsar[bar]=MathMin(Data.Low[bar-1],Data.Low[bar-2]);
      else if(aiDir[bar]<0 && adPsar[bar]<MathMax(Data.High[bar-1],Data.High[bar-2]))
         adPsar[bar]=MathMax(Data.High[bar-1],Data.High[bar-2]);

      //----	PSAR for the next period

      // Calculation of the new values of flPExtr and flAF
      // if there is a new extreme price in the PSAR direction
      if(aiDir[bar]>0 && Data.High[bar]>dPExtr)
        {
         dPExtr=Data.High[bar];
         dAf=MathMin(dAf+dAfInc,dAfMax);
        }

      if(aiDir[bar]<0 && Data.Low[bar]<dPExtr)
        {
         dPExtr=Data.Low[bar];
         dAf=MathMin(dAf+dAfInc,dAfMax);
        }

      // Whether the price reaches PSAR
      if(Data.Low[bar]<=adPsar[bar] && adPsar[bar]<=Data.High[bar])
        {
         intDirNew= -aiDir[bar];
         dPsarNew = dPExtr;
         dAf=dAfMin;
         dPExtr=intDirNew>0 ? Data.High[bar]: Data.Low[bar];
        }
     }
   const int firstBar=8;

// Saving the components
   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "PSAR value";
   Component[0].DataType = SlotType == SlotTypes_Close ? IndComponentType_ClosePrice : IndComponentType_IndicatorValue;
   Component[0].FirstBar = firstBar;
   Component[0].PosPriceDependence=PositionPriceDependence_BuyHigherSellLower;
   ArrayCopy(Component[0].Value,adPsar);
  }
//+------------------------------------------------------------------+
