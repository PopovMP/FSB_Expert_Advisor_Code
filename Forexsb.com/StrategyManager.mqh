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

#include <Forexsb.com/Enumerations.mqh>
#include <Forexsb.com/IndicatorSlot.mqh>
#include <Forexsb.com/Strategy.mqh>
#include <Forexsb.com/IndicatorManager.mqh>
#include <Forexsb.com/EasyXml.mqh>
#include <Forexsb.com/Helpers.mqh>

//## Import Start

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class StrategyManager
  {
   SameDirSignalAction ParseSameDirSignalAction(string value);
   OppositeDirSignalAction ParseOppositeDirSignalAction(string value);
public:
   Strategy         *ParseXmlStrategy(string xml);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SameDirSignalAction StrategyManager::ParseSameDirSignalAction(string value)
  {
      if (value == "Add")    return SameDirSignalAction_Add;
      if (value == "Loser")  return SameDirSignalAction_Loser;
      if (value == "Winner") return SameDirSignalAction_Winner;
      return SameDirSignalAction_Nothing;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
OppositeDirSignalAction  StrategyManager::ParseOppositeDirSignalAction(string value)
  {
      if (value == "Close")   return OppositeDirSignalAction_Close;
      if (value == "Reduce")  return OppositeDirSignalAction_Reduce;
      if (value == "Reverse") return OppositeDirSignalAction_Reverse;
      return OppositeDirSignalAction_Nothing;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Strategy *StrategyManager::ParseXmlStrategy(string xml)
  {
   IndicatorManager indicatorManager;

   CEasyXml doc;
   doc.SetDebugging(false);
   bool isLoaded=doc.LoadXmlFromString(xml);

   if(!isLoaded)
     {
      string message="Cannot parse the strategy XML file";
      Comment(message);
      Print(message);
      return NULL;
     }

   CArrayObj *rootChildren=doc.GetDocumentRoot().Children();

   int openFilters  = 0;
   int closeFilters = 0;

   for(int i=0; i<rootChildren.Total(); i++)
     {
      CEasyXmlNode *node=rootChildren.At(i);
      string name  = node.GetName();
      string value = node.GetValue();

      if(name=="openFilters")
         openFilters=(int) StringToInteger(value);
      else if(name=="closeFilters")
         closeFilters=(int) StringToInteger(value);
     }

   Strategy *strategy=new Strategy(openFilters,closeFilters);

   for(int i=0; i<rootChildren.Total(); i++)
     {
      CEasyXmlNode *node=rootChildren.At(i);
      string name  = node.GetName();
      string value = node.GetValue();

      // Skip unused tags;
      string unusedTags[]=
        {
         "dataSourceName","profileName","AccountBalance","ProfitPerDay","WinLossRatio","AccountStatsParam",
         "instrumentSymbol","instrumentPeriod","AccountStatsValue","MarketStatsParam","MarketStatsValue","InputParametersParam",
         "InputParametersValue","BalanceLine","EquityLine","slot"
        };
      for(int j=0; j<ArraySize(unusedTags); j++)
         if(name==unusedTags[j])
            continue;

      if(name=="strategyName") strategy.StrategyName=value;
      else if(name == "sameDirSignalAction")    strategy.SameSignalAction       = ParseSameDirSignalAction(value);
      else if(name == "oppDirSignalAction")     strategy.OppSignalAction        = ParseOppositeDirSignalAction(value);
      else if(name == "maxOpenLots")            strategy.MaxOpenLots            = StringToDouble(value);
      else if(name == "useAccountPercentEntry") strategy.UseAccountPercentEntry = StringBoolToBool(value);
      else if(name == "entryLots")              strategy.EntryLots              = StringToDouble(value);
      else if(name == "addingLots")             strategy.AddingLots             = StringToDouble(value);
      else if(name == "reducingLots")           strategy.ReducingLots           = StringToDouble(value);
      else if(name == "useMartingale")          strategy.UseMartingale          = StringBoolToBool(value);
      else if(name == "martingaleMultiplier")   strategy.MartingaleMultiplier   = StringToDouble(value);
      else if(name == "description")            strategy.Description            = value;
      else if(name == "recommendedBars")        strategy.RecommendedBars        = (int) StringToInteger(value);
      else if(name == "firstBar")               strategy.FirstBar               = (int) StringToInteger(value);
      else if(name == "minBarsRequired")        strategy.MinBarsRequired        = (int) StringToInteger(value);
      else if(name == "permanentStopLoss")
        {
         strategy.PermanentSL=(int) StringToInteger(value);
         string usePermanentSL=node.GetAttribute("usePermanentSL");
         strategy.UsePermanentSL=StringBoolToBool(usePermanentSL);
         strategy.PermanentSLType=(PermanentProtectionType)StringToInteger(node.GetAttribute("permanentSLType"));
        }
      else if(name=="permanentTakeProfit")
        {
         strategy.PermanentTP=(int) StringToInteger(value);
         string usePermanentTP=node.GetAttribute("usePermanentTP");
         strategy.UsePermanentTP=StringBoolToBool(usePermanentTP);
         strategy.PermanentTPType=(PermanentProtectionType)StringToInteger(node.GetAttribute("permanentTPType"));
        }
      else if(name=="breakEven")
        {
         strategy.BreakEven=(int) StringToInteger(value);
         string useBreakEven=node.GetAttribute("useBreakEven");
         strategy.UseBreakEven=StringBoolToBool(useBreakEven);
        }
     }

   for(int i=0; i<rootChildren.Total(); i++)
     {
      CEasyXmlNode *node=rootChildren.At(i);

      if(node.GetName()!="slot")
         continue;

      string slotNumberText=node.GetAttribute("slotNumber");
      int slot=(int) StringToInteger(slotNumberText);

      string slotTypeText= node.GetAttribute("slotType");
      SlotTypes slotType = SlotTypeFromShortString(slotTypeText);
      
      string logicalGroup = node.GetAttribute("logicalGroup");

      string indicatorName;
      int signalShift  = 0;
      int signalRepeat = 0;
      DataPeriod indicatorPeriod=DataPeriod_M1;
      string indicatorSymbol="";

      for(int r=0; r<node.Children().Total(); r++)
        {
         CEasyXmlNode *child=node.Children().At(r);
         string name  = child.GetName();
         string value = child.GetValue();

         if(name=="indicatorName") indicatorName=value;
         else if(name == "signalShift")     signalShift     = (int) StringToInteger(value);
         else if(name == "signalRepeat")    signalRepeat    = (int) StringToInteger(value);
         else if(name == "indicatorPeriod") indicatorPeriod = StringToDataPeriod(value);
         else if(name == "indicatorSymbol") indicatorSymbol = StringRemoveWhite(value);
        }

      strategy.Slot[slot].IndicatorName    = indicatorName;
      strategy.Slot[slot].IndicatorPointer = indicatorManager.CreateIndicator(indicatorName, slotType);
      strategy.Slot[slot].SlotType         = slotType;
      strategy.Slot[slot].SignalShift      = signalShift;
      strategy.Slot[slot].SignalRepeat     = signalRepeat;
      strategy.Slot[slot].IndicatorPeriod  = indicatorPeriod;
      strategy.Slot[slot].IndicatorSymbol  = indicatorSymbol;
      strategy.Slot[slot].LogicalGroup     = logicalGroup;
      
      for(int j=1; j<node.Children().Total(); j++)
        {
         CEasyXmlNode* subNodes = node.Children().At(j);
         string paramNumberText = subNodes.GetAttribute("paramNumber");
         int paramNumber=(int) StringToInteger(paramNumberText);

         if(subNodes.GetName()=="listParam")
           {
            strategy.Slot[slot].IndicatorPointer.ListParam[paramNumber].Enabled=true;

            CEasyXmlNode *param0=subNodes.Children().At(0);
            string text0=param0.GetValue();
            strategy.Slot[slot].IndicatorPointer.ListParam[paramNumber].Caption=text0;

            CEasyXmlNode *param1=subNodes.Children().At(1);
            string text1=param1.GetValue();
            strategy.Slot[slot].IndicatorPointer.ListParam[paramNumber].Index=(int) StringToInteger(text1);

            CEasyXmlNode *param2=subNodes.Children().At(2);
            string text2=param2.GetValue();
            strategy.Slot[slot].IndicatorPointer.ListParam[paramNumber].Text=text2;
           }
         else if(subNodes.GetName()=="numParam")
           {
            strategy.Slot[slot].IndicatorPointer.NumParam[paramNumber].Enabled=true;

            CEasyXmlNode *param0=subNodes.Children().At(0);
            string text0=param0.GetValue();
            strategy.Slot[slot].IndicatorPointer.NumParam[paramNumber].Caption=text0;

            CEasyXmlNode *param1=subNodes.Children().At(1);
            string text1=param1.GetValue();
            strategy.Slot[slot].IndicatorPointer.NumParam[paramNumber].Value=StringToDouble(text1);
           }
         else if(subNodes.GetName()=="checkParam")
           {
            strategy.Slot[slot].IndicatorPointer.CheckParam[paramNumber].Enabled=true;

            CEasyXmlNode *param0=subNodes.Children().At(0);
            string text0=param0.GetValue();
            strategy.Slot[slot].IndicatorPointer.CheckParam[paramNumber].Caption=text0;

            CEasyXmlNode *param1=subNodes.Children().At(1);
            string text1=param1.GetValue();
            strategy.Slot[slot].IndicatorPointer.CheckParam[paramNumber].Checked=StringBoolToBool(text1);
           }
        }
     }

   return strategy;
  }
//+------------------------------------------------------------------+
