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
class PivotPoints : public Indicator
  {
public:
   PivotPoints(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="Pivot Points";

      WarningMessage    = "";
      IsAllowLTF        = true;
      ExecTime          = ExecutionTime_DuringTheBar;
      IsSeparateChart   = false;
      IsDiscreteValues  = false;
      IsDefaultGroupAll = false;
     }

   virtual void      Calculate(DataSet &dataSet);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PivotPoints::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

// Reading the parameters
   double dShift=NumParam[0].Value*Data.Point;
   int prvs=CheckParam[0].Checked ? 1 : 0;

// Calculation
   int firstBar=1;
   double adPp[];  ArrayResize(adPp,Data.Bars); ArrayInitialize(adPp,0);
   double adR1[];  ArrayResize(adR1,Data.Bars); ArrayInitialize(adR1,0);
   double adR2[];  ArrayResize(adR2,Data.Bars); ArrayInitialize(adR2,0);
   double adR3[];  ArrayResize(adR3,Data.Bars); ArrayInitialize(adR3,0);
   double adS1[];  ArrayResize(adS1,Data.Bars); ArrayInitialize(adS1,0);
   double adS2[];  ArrayResize(adS2,Data.Bars); ArrayInitialize(adS2,0);
   double adS3[];  ArrayResize(adS3,Data.Bars); ArrayInitialize(adS3,0);
   double adH[];   ArrayResize(adH,Data.Bars);  ArrayInitialize(adH,0);
   double adL[];   ArrayResize(adL,Data.Bars);  ArrayInitialize(adL,0);
   double adC[];   ArrayResize(adC,Data.Bars);  ArrayInitialize(adC,0);

   if(ListParam[1].Text=="One bar" || 
      Data.Period==DataPeriod_D1 || Data.Period==DataPeriod_W1)
     {
      ArrayCopy(adH, Data.High);
      ArrayCopy(adL, Data.Low);
      ArrayCopy(adC, Data.Close);
     }
   else
     {
      prvs=0;
      adH[0] = 0;
      adL[0] = 0;
      adC[0] = 0;

      double dTop=DBL_MIN;
      double dBottom=DBL_MAX;

      for(int bar=1; bar<Data.Bars; bar++)
        {
         if(Data.High[bar-1]>dTop)
            dTop=Data.High[bar-1];
         if(Data.Low[bar-1]<dBottom)
            dBottom=Data.Low[bar-1];
            
         MqlDateTime time0; TimeToStruct(Data.Time[bar+0], time0);
         MqlDateTime time1; TimeToStruct(Data.Time[bar-1], time1);

         if(time0.day!=time1.day)
           {
            adH[bar] = dTop;
            adL[bar] = dBottom;
            adC[bar] = Data.Close[bar - 1];
            dTop=DBL_MIN;
            dBottom=DBL_MAX;
           }
         else
           {
            adH[bar] = adH[bar - 1];
            adL[bar] = adL[bar - 1];
            adC[bar] = adC[bar - 1];
           }
        }

      // first Bar
      for(int bar=1; bar<Data.Bars; bar++)
      {
         MqlDateTime time0; TimeToStruct(Data.Time[bar+0], time0);
         MqlDateTime time1; TimeToStruct(Data.Time[bar-1], time1);
         if(time0.day!=time1.day)
            firstBar=bar;
      }
     }

   for(int bar=firstBar; bar<Data.Bars; bar++)
     {
      adPp[bar] = (adH[bar] + adL[bar] + adC[bar])/3;
      adR1[bar] = 2*adPp[bar] - adL[bar];
      adS1[bar] = 2*adPp[bar] - adH[bar];
      adR2[bar] = adPp[bar] + adH[bar] - adL[bar];
      adS2[bar] = adPp[bar] - adH[bar] + adL[bar];
      adR3[bar] = adH[bar] + 2*(adPp[bar] - adL[bar]);
      adS3[bar] = adL[bar] - 2*(adH[bar] - adPp[bar]);
     }

   for(int iComp=0; iComp<7; iComp++)
     {
      ArrayResize(Component[iComp].Value,Data.Bars);
      Component[iComp].DataType = IndComponentType_IndicatorValue;
      Component[iComp].FirstBar = firstBar;
     }

   ArrayCopy(Component[0].Value, adR3);
   ArrayCopy(Component[1].Value, adR2);
   ArrayCopy(Component[2].Value, adR1);
   ArrayCopy(Component[3].Value, adPp);
   ArrayCopy(Component[4].Value, adS1);
   ArrayCopy(Component[5].Value, adS2);
   ArrayCopy(Component[6].Value, adS3);

   Component[0].CompName = "Resistance 3";
   Component[1].CompName = "Resistance 2";
   Component[2].CompName = "Resistance 1";
   Component[3].CompName = "Pivot Point";
   Component[4].CompName = "Support 1";
   Component[5].CompName = "Support 2";
   Component[6].CompName = "Support 3";

   ArrayResize(Component[7].Value,Data.Bars);
   Component[7].FirstBar=firstBar;

   ArrayResize(Component[8].Value,Data.Bars);
   Component[8].FirstBar=firstBar;

   if(SlotType==SlotTypes_Open)
     {
      Component[7].CompName = "Long position entry price";
      Component[7].DataType = IndComponentType_OpenLongPrice;
      Component[8].CompName = "Short position entry price";
      Component[8].DataType = IndComponentType_OpenShortPrice;
     }
   else if(SlotType==SlotTypes_Close)
     {
      Component[7].CompName = "Long position closing price";
      Component[7].DataType = IndComponentType_CloseLongPrice;
      Component[8].CompName = "Short position closing price";
      Component[8].DataType = IndComponentType_CloseShortPrice;
     }

   if(ListParam[0].Text=="Enter long at R3 (short at S3)" || ListParam[0].Text=="Exit long at R3 (short at S3)")
      for(int bar=firstBar; bar<Data.Bars; bar++)
        {
         Component[7].Value[bar] = adR3[bar - prvs] + dShift;
         Component[8].Value[bar] = adS3[bar - prvs] - dShift;
        }
   if(ListParam[0].Text=="Enter long at R2 (short at S2)" || ListParam[0].Text=="Exit long at R2 (short at S2)")
      for(int bar=firstBar; bar<Data.Bars; bar++)
        {
         Component[7].Value[bar] = adR2[bar - prvs] + dShift;
         Component[8].Value[bar] = adS2[bar - prvs] - dShift;
        }
   if(ListParam[0].Text=="Enter long at R1 (short at S1)" || ListParam[0].Text=="Exit long at R1 (short at S1)")
      for(int bar=firstBar; bar<Data.Bars; bar++)
        {
         Component[7].Value[bar] = adR1[bar - prvs] + dShift;
         Component[8].Value[bar] = adS1[bar - prvs] - dShift;
        }
//---------------------------------------------------------------------
   if(ListParam[0].Text=="Enter the market at the Pivot Point" || ListParam[0].Text=="Exit the market at the Pivot Point")
      for(int bar=firstBar; bar<Data.Bars; bar++)
        {
         Component[7].Value[bar] = adPp[bar - prvs] + dShift;
         Component[8].Value[bar] = adPp[bar - prvs] - dShift;
        }
//---------------------------------------------------------------------
   if(ListParam[0].Text=="Enter long at S1 (short at R1)" || ListParam[0].Text=="Exit long at S1 (short at R1)")
      for(int bar=firstBar; bar<Data.Bars; bar++)
        {
         Component[7].Value[bar] = adS1[bar - prvs] - dShift;
         Component[8].Value[bar] = adR1[bar - prvs] + dShift;
        }
   if(ListParam[0].Text=="Enter long at S2 (short at R2)" || ListParam[0].Text=="Exit long at S2 (short at R2)")
      for(int bar=firstBar; bar<Data.Bars; bar++)
        {
         Component[7].Value[bar] = adS2[bar - prvs] - dShift;
         Component[8].Value[bar] = adR2[bar - prvs] + dShift;
        }
   if(ListParam[0].Text=="Enter long at S3 (short at R3)" || ListParam[0].Text=="Exit long at S3 (short at R3)")
      for(int bar=firstBar; bar<Data.Bars; bar++)
        {
         Component[7].Value[bar] = adS3[bar - prvs] - dShift;
         Component[8].Value[bar] = adR3[bar - prvs] + dShift;
        }
  }
//+------------------------------------------------------------------+
