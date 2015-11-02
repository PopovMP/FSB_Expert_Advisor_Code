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
class Volumes : public Indicator
  {
public:
   Volumes(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="Volumes";

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
void Volumes::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

// Reading the parameters
   double dLevel = NumParam[0].Value;
   int    iPrvs  = CheckParam[0].Checked ? 1 : 0;

// Calculation
   double adVolumes[];
   ArrayResize(adVolumes,Data.Bars);
   ArrayInitialize(adVolumes,0);

   int iFirstBar=iPrvs+1;

   for(int iBar=0; iBar<Data.Bars; iBar++)
      adVolumes[iBar]=(int)Data.Volume[iBar];

// Saving the components
   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName  = "Volumes";
   Component[0].DataType  = IndComponentType_IndicatorValue;
   Component[0].FirstBar  = iFirstBar;
   ArrayCopy(Component[0].Value,adVolumes);

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
   if(ListParam[0].Text=="Volume rises")
     {
      for(int iBar=iPrvs+1; iBar<Data.Bars; iBar++)
        {
         Component[1].Value[iBar] = adVolumes[iBar - iPrvs] > adVolumes[iBar - iPrvs - 1] + Sigma() ? 1 : 0;
         Component[2].Value[iBar] = adVolumes[iBar - iPrvs] > adVolumes[iBar - iPrvs - 1] + Sigma() ? 1 : 0;
        }
     }
   else if(ListParam[0].Text=="Volume falls")
     {
      for(int iBar=iPrvs+1; iBar<Data.Bars; iBar++)
        {
         Component[1].Value[iBar] = adVolumes[iBar - iPrvs] < adVolumes[iBar - iPrvs - 1] - Sigma() ? 1 : 0;
         Component[2].Value[iBar] = adVolumes[iBar - iPrvs] < adVolumes[iBar - iPrvs - 1] - Sigma() ? 1 : 0;
        }
     }
   else if(ListParam[0].Text=="Volume is higher than the Level line")
     {
      for(int iBar=iPrvs; iBar<Data.Bars; iBar++)
        {
         Component[1].Value[iBar] = adVolumes[iBar - iPrvs] > dLevel + Sigma() ? 1 : 0;
         Component[2].Value[iBar] = adVolumes[iBar - iPrvs] > dLevel + Sigma() ? 1 : 0;
        }
     }
   else if(ListParam[0].Text=="Volume is lower than the Level line")
     {
      for(int iBar=iPrvs; iBar<Data.Bars; iBar++)
        {
         Component[1].Value[iBar] = adVolumes[iBar - iPrvs] < dLevel - Sigma() ? 1 : 0;
         Component[2].Value[iBar] = adVolumes[iBar - iPrvs] < dLevel - Sigma() ? 1 : 0;
        }
     }
  }
//+------------------------------------------------------------------+
