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
class Fractal : public Indicator
  {
public:
                     Fractal(SlotTypes slotType);
   virtual void      Calculate(DataSet &dataSet);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Fractal::Fractal(SlotTypes slotType)
  {
   SlotType          = slotType;
   IndicatorName     = "Fractal";
   WarningMessage    = "";
   IsAllowLTF        = true;
   ExecTime          = ExecutionTime_DuringTheBar;
   IsSeparateChart   = false;
   IsDiscreteValues  = false;
   IsDefaultGroupAll = false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Fractal::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);
   double epsiolon=Epsilon();

   bool isVisible=ListParam[1].Text=="Visible";
   double shift=NumParam[0].Value*Data.Point;
   const int firstBar=8;

   double upFractals[];    ArrayResize(upFractals,Data.Bars);   ArrayInitialize(upFractals,0);
   double downFractals[];  ArrayResize(downFractals,Data.Bars); ArrayInitialize(downFractals,0);

   for(int bar=8; bar<Data.Bars-1; bar++)
     {
      if(Data.High[bar-1]<Data.High[bar-2] && Data.High[bar]<Data.High[bar-2])
        {
         // Fractal type 1
         if(Data.High[bar-4]<Data.High[bar-2] &&
            Data.High[bar-3]<Data.High[bar-2])
            upFractals[bar+1]=Data.High[bar-2];

         // Fractal type 2
         if(Data.High[bar-5]<Data.High[bar-2] &&
            Data.High[bar-4]<Data.High[bar-2] &&
            MathAbs(Data.High[bar-3]-Data.High[bar-2])<epsiolon)
            upFractals[bar+1]=Data.High[bar-2];

         // Fractal type 3, 4
         if(Data.High[bar-6]<Data.High[bar-2] &&
            Data.High[bar-5]<Data.High[bar-2] &&
            MathAbs(Data.High[bar-4]-Data.High[bar-2])<epsiolon && 
            Data.High[bar-3]<= Data.High[bar-2])
            upFractals[bar+1]= Data.High[bar-2];

         // Fractal type 5
         if(Data.High[bar-7]<Data.High[bar-2] &&
            Data.High[bar-6]<Data.High[bar-2] &&
            MathAbs(Data.High[bar-5]-Data.High[bar-2])<epsiolon && 
            Data.High[bar-4]<Data.High[bar-2] && 
            MathAbs(Data.High[bar-3]-Data.High[bar-2])<epsiolon)
            upFractals[bar+1]=Data.High[bar-2];

         // Fractal type 6
         if(Data.High[bar-7]<Data.High[bar-2] &&
            Data.High[bar-6]<Data.High[bar-2] &&
            MathAbs(Data.High[bar-5]-Data.High[bar-2])<epsiolon &&
            MathAbs(Data.High[bar-4]-Data.High[bar-2])<epsiolon &&
            Data.High[bar-3]<Data.High[bar-2])
            upFractals[bar+1]=Data.High[bar-2];

         // Fractal type 7
         if(Data.High[bar-8]<Data.High[bar-2] &&
            Data.High[bar-7]<Data.High[bar-2] &&
            MathAbs(Data.High[bar-6]-Data.High[bar-2])<epsiolon && 
            Data.High[bar-5]<Data.High[bar-2] && 
            MathAbs(Data.High[bar-6]-Data.High[bar-2])<epsiolon && 
            Data.High[bar-3]<Data.High[bar-2])
            upFractals[bar+1]=Data.High[bar-2];
        }

      if(Data.Low[bar-1]>Data.Low[bar-2] && Data.Low[bar]>Data.Low[bar-2])
        {
         // Fractal type 1
         if(Data.Low[bar-4]>Data.Low[bar-2] &&
            Data.Low[bar-3]>Data.Low[bar-2])
            downFractals[bar+1]=Data.Low[bar-2];

         // Fractal type 2
         if(Data.Low[bar-5]>Data.Low[bar-2] &&
            Data.Low[bar-4]>Data.Low[bar-2] &&
            MathAbs(Data.Low[bar-3]-Data.Low[bar-2])<epsiolon)
            downFractals[bar+1]=Data.Low[bar-2];

         // Fractal type 3, 4
         if(Data.Low[bar-6]>Data.Low[bar-2] &&
            Data.Low[bar-5] > Data.Low[bar-2] &&
            MathAbs(Data.Low[bar-4]-Data.Low[bar-2])<epsiolon && 
            Data.Low[bar-3]>=Data.Low[bar-2])
            downFractals[bar+1]=Data.Low[bar-2];

         // Fractal type 5
         if(Data.Low[bar-7]>Data.Low[bar-2] &&
            Data.Low[bar-6]>Data.Low[bar-2] &&
            MathAbs(Data.Low[bar-5]-Data.Low[bar-2])<epsiolon && 
            Data.Low[bar-4]>Data.Low[bar-2] && 
            MathAbs(Data.Low[bar-3]-Data.Low[bar-2])<epsiolon)
            downFractals[bar+1]=Data.Low[bar-2];

         // Fractal type 6
         if(Data.Low[bar-7]>Data.Low[bar-2] &&
            Data.Low[bar-6]>Data.Low[bar-2] &&
            MathAbs(Data.Low[bar-5]-Data.Low[bar-2])<epsiolon &&
            MathAbs(Data.Low[bar-4]-Data.Low[bar-2])<epsiolon &&
            Data.Low[bar-3]>Data.Low[bar-2])
            downFractals[bar+1]=Data.Low[bar-2];

         // Fractal type 7
         if(Data.Low[bar-8]>Data.Low[bar-2] &&
            Data.Low[bar-7]>Data.Low[bar-2] &&
            MathAbs(Data.Low[bar-6]-Data.Low[bar-2])<epsiolon && 
            Data.Low[bar-5]>Data.Low[bar-2] && 
            MathAbs(Data.Low[bar-4]-Data.Low[bar-2])<epsiolon && 
            Data.Low[bar-3]>Data.Low[bar-2])
            downFractals[bar+1]=Data.Low[bar-2];
        }
     }

   if(isVisible)
     {
      for(int bar=firstBar; bar<Data.Bars; bar++)
        {
         if(upFractals[bar]<epsiolon && upFractals[bar-1]>Data.High[bar-1])
            upFractals[bar]=upFractals[bar-1];
         if(downFractals[bar]<epsiolon && downFractals[bar-1]<Data.Low[bar-1])
            downFractals[bar]=downFractals[bar-1];
        }
     }
   else
     {
      for(int bar=firstBar; bar<Data.Bars; bar++)
        {
         if(upFractals[bar]<epsiolon)
            upFractals[bar]=upFractals[bar-1];
         if(downFractals[bar]<epsiolon)
            downFractals[bar]=downFractals[bar-1];
        }
     }

   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "Up Fractal";
   Component[0].DataType = IndComponentType_IndicatorValue;
   Component[0].FirstBar = firstBar;
   ArrayCopy(Component[0].Value,upFractals);

   ArrayResize(Component[1].Value,Data.Bars);
   Component[1].CompName = "Down Fractal";
   Component[1].DataType = IndComponentType_IndicatorValue;
   Component[1].FirstBar = firstBar;
   ArrayCopy(Component[1].Value,downFractals);

   ArrayResize(Component[2].Value,Data.Bars);
   ArrayInitialize(Component[2].Value,0);
   Component[2].FirstBar=firstBar;

   ArrayResize(Component[3].Value,Data.Bars);
   ArrayInitialize(Component[3].Value,0);
   Component[3].FirstBar=firstBar;

   if(SlotType==SlotTypes_Open)
     {
      Component[2].CompName = "Long position entry price";
      Component[2].DataType = IndComponentType_OpenLongPrice;
      Component[3].CompName = "Short position entry price";
      Component[3].DataType = IndComponentType_OpenShortPrice;
     }
   else if(SlotType==SlotTypes_Close)
     {
      Component[2].CompName = "Long position closing price";
      Component[2].DataType = IndComponentType_CloseLongPrice;
      Component[3].CompName = "Short position closing price";
      Component[3].DataType = IndComponentType_CloseShortPrice;
     }

   if(ListParam[0].Text=="Enter long at Up Fractal" ||
      ListParam[0].Text=="Exit long at Up Fractal")
      for(int bar=firstBar; bar<Data.Bars; bar++)
        {
         if(upFractals[bar]>epsiolon)
            Component[2].Value[bar]=upFractals[bar]+shift;
         if(downFractals[bar]>epsiolon)
            Component[3].Value[bar]=downFractals[bar]-shift;
        }
   if(ListParam[0].Text=="Enter long at Down Fractal" ||
      ListParam[0].Text=="Exit long at Down Fractal")
      for(int bar=firstBar; bar<Data.Bars; bar++)
        {
         if(downFractals[bar]>epsiolon)
            Component[2].Value[bar]=downFractals[bar]-shift;
         if(upFractals[bar]>epsiolon)
            Component[3].Value[bar]=upFractals[bar]+shift;
        }
  }
//+------------------------------------------------------------------+
