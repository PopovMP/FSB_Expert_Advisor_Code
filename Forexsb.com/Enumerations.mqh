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

//## Import Start

enum DataPeriod
{
   DataPeriod_M1  = 1,
   DataPeriod_M5  = 5,
   DataPeriod_M15 = 15,
   DataPeriod_M30 = 30,
   DataPeriod_H1  = 60,
   DataPeriod_H4  = 240,
   DataPeriod_D1  = 1440,
   DataPeriod_W1  = 10080,
   DataPeriod_MN1 = 43200
};

enum PosDirection
{
   PosDirection_None,
   PosDirection_Long,
   PosDirection_Short,
   PosDirection_Closed
};

enum OrderDirection
{
   OrderDirection_None,
   OrderDirection_Buy,
   OrderDirection_Sell
};

enum StrategyPriceType
{
   StrategyPriceType_Open,
   StrategyPriceType_Close,
   StrategyPriceType_Indicator,
   StrategyPriceType_CloseAndReverse,
   StrategyPriceType_Unknown
};

enum ExecutionTime
{
   ExecutionTime_DuringTheBar,
   ExecutionTime_AtBarOpening,
   ExecutionTime_AtBarClosing,
   ExecutionTime_CloseAndReverse
};

enum TraderOrderType
{
   TraderOrderType_Buy       = 0,
   TraderOrderType_Sell      = 1,
   TraderOrderType_BuyLimit  = 2,
   TraderOrderType_SellLimit = 3,
   TraderOrderType_BuyStop   = 4,
   TraderOrderType_SellStop  = 5
};

enum TradeDirection
{
   TradeDirection_None,
   TradeDirection_Long,
   TradeDirection_Short,
   TradeDirection_Both
};

enum LongTradeEntryPrice
{
   LongTradeEntryPrice_Bid,
   LongTradeEntryPrice_Ask,
   LongTradeEntryPrice_Chart
};

enum OperationType
{
   OperationType_Buy,
   OperationType_Sell,
   OperationType_Close,
   OperationType_Modify
};

enum TickType
{
   TickType_Open       = 0,
   TickType_OpenClose  = 1,
   TickType_Regular    = 2,
   TickType_Close      = 3,
   TickType_AfterClose = 4
};

enum InstrumentType
{
   InstrumentType_Forex,
   InstrumentType_CFD,
   InstrumentType_Index
};

enum SlotTypes
{
   SlotTypes_NotDefined  = 0,
   SlotTypes_Open        = 1,
   SlotTypes_OpenFilter  = 2,
   SlotTypes_Close       = 4,
   SlotTypes_CloseFilter = 8
};

enum IndComponentType
{
   IndComponentType_NotDefined,
   IndComponentType_OpenLongPrice,
   IndComponentType_OpenShortPrice,
   IndComponentType_OpenPrice,
   IndComponentType_CloseLongPrice,
   IndComponentType_CloseShortPrice,
   IndComponentType_ClosePrice,
   IndComponentType_OpenClosePrice,
   IndComponentType_IndicatorValue,
   IndComponentType_AllowOpenLong,
   IndComponentType_AllowOpenShort,
   IndComponentType_ForceCloseLong,
   IndComponentType_ForceCloseShort,
   IndComponentType_ForceClose,
   IndComponentType_Other
};

enum PositionPriceDependence
{
   PositionPriceDependence_None,
   PositionPriceDependence_PriceBuyHigher,
   PositionPriceDependence_PriceBuyLower,
   PositionPriceDependence_PriceSellHigher,
   PositionPriceDependence_PriceSellLower,
   PositionPriceDependence_BuyHigherSellLower,
   PositionPriceDependence_BuyLowerSelHigher, // Deprecated
   PositionPriceDependence_BuyLowerSellHigher
};

enum BasePrice
{
   BasePrice_Open     = 0,
   BasePrice_High     = 1,
   BasePrice_Low      = 2,
   BasePrice_Close    = 3,
   BasePrice_Median   = 4, // Price[bar] = (Low[bar] + High[bar]) / 2;
   BasePrice_Typical  = 5, // Price[bar] = (Low[bar] + High[bar] + Close[bar]) / 3;
   BasePrice_Weighted = 6  // Price[bar] = (Low[bar] + High[bar] + 2 * Close[bar]) / 4;
};

enum MAMethod
{
   MAMethod_Simple      = 0,
   MAMethod_Weighted    = 1,
   MAMethod_Exponential = 2,
   MAMethod_Smoothed    = 3
};

enum SameDirSignalAction
{
   SameDirSignalAction_Nothing,
   SameDirSignalAction_Add,
   SameDirSignalAction_Winner,
   SameDirSignalAction_Loser,
};

enum OppositeDirSignalAction
{
   OppositeDirSignalAction_Nothing,
   OppositeDirSignalAction_Reduce,
   OppositeDirSignalAction_Close,
   OppositeDirSignalAction_Reverse
};

enum PermanentProtectionType
{
   PermanentProtectionType_Relative,
   PermanentProtectionType_Absolute
};

enum TrailingStopMode
{
   TrailingStopMode_Bar,
   TrailingStopMode_Tick
};

enum IndicatorLogic
{
   IndicatorLogic_The_indicator_rises,
   IndicatorLogic_The_indicator_falls,
   IndicatorLogic_The_indicator_is_higher_than_the_level_line,
   IndicatorLogic_The_indicator_is_lower_than_the_level_line,
   IndicatorLogic_The_indicator_crosses_the_level_line_upward,
   IndicatorLogic_The_indicator_crosses_the_level_line_downward,
   IndicatorLogic_The_indicator_changes_its_direction_upward,
   IndicatorLogic_The_indicator_changes_its_direction_downward,
   IndicatorLogic_The_price_buy_is_higher_than_the_ind_value,
   IndicatorLogic_The_price_buy_is_lower_than_the_ind_value,
   IndicatorLogic_The_price_open_is_higher_than_the_ind_value,
   IndicatorLogic_The_price_open_is_lower_than_the_ind_value,
   IndicatorLogic_It_does_not_act_as_a_filter,
};

enum BandIndLogic
{
   BandIndLogic_The_bar_opens_below_the_Upper_Band,
   BandIndLogic_The_bar_opens_above_the_Upper_Band,
   BandIndLogic_The_bar_opens_below_the_Lower_Band,
   BandIndLogic_The_bar_opens_above_the_Lower_Band,
   BandIndLogic_The_position_opens_below_the_Upper_Band,
   BandIndLogic_The_position_opens_above_the_Upper_Band,
   BandIndLogic_The_position_opens_below_the_Lower_Band,
   BandIndLogic_The_position_opens_above_the_Lower_Band,
   BandIndLogic_The_bar_opens_below_Upper_Band_after_above,
   BandIndLogic_The_bar_opens_above_Upper_Band_after_below,
   BandIndLogic_The_bar_opens_below_Lower_Band_after_above,
   BandIndLogic_The_bar_opens_above_Lower_Band_after_below,
   BandIndLogic_The_bar_closes_below_the_Upper_Band,
   BandIndLogic_The_bar_closes_above_the_Upper_Band,
   BandIndLogic_The_bar_closes_below_the_Lower_Band,
   BandIndLogic_The_bar_closes_above_the_Lower_Band,
   BandIndLogic_It_does_not_act_as_a_filter
};
