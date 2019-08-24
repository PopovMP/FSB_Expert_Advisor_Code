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
#property version   "49.0"
#property strict

#include <Forexsb.com\ActionTrade4.mqh>

// -----------------------    External variables   ----------------------- //

static input string StrategyProperties__ = "------------"; // ------ Strategy Properties ------

static input double Entry_Amount    = 77701; // Amount for a new position #TRADEUNIT#
static input double Maximum_Amount  = 77702; // Maximum position amount [lot]
static input double Adding_Amount   = 77703; // Amount to add on addition #TRADEUNIT#
static input double Reducing_Amount = 77704; // Amount to close on reduction #TRADEUNIT#
input int Stop_Loss   = 77705; // Stop Loss [point]
input int Take_Profit = 77706; // Take Profit [point]
input int Break_Even  = 77707; // Break Even [point]
static input double Martingale_Multiplier = 77708; // Martingale Multiplier

//##INDICATORS_INPUT_PARAMS

static input string ExpertSettings__ = "------------"; // ------ Expert Settings ------

// A unique number of the expert's orders.
static input int Expert_Magic = 20011023; // Expert Magic Number

// If account equity drops below this value, the expert will close out all positions and stop automatic trade.
// The value must be set in account currency. Example:
// Protection_Min_Account = 700 will close positions if the equity drops below 700 USD (EUR if you account is in EUR).
static input int Protection_Min_Account = 0; // Stop trading at min account

// The expert checks the open positions at every tick and if found no SL or SL lower (higher for short) than selected,
// It sets SL to the defined value. The value is in points. Example:
// Protection_Max_StopLoss = 200 means 200 pips for 4 digit broker and 20 pips for 5 digit broker.
static input int Protection_Max_StopLoss = 0; // Ensure maximum Stop Loss [point]

// How many seconds before the expected bar closing to rise a Bar Closing event.
static input int Bar_Close_Advance = 15; // Bar closing advance [sec]

// Expert writes a log file when Write_Log_File = true.
static input bool Write_Log_File = false; // Write a log file

// Custom comment. It can be used for setting a binnary option epxiration perod
static input string Order_Comment = ""; // Custom order comment

// ----------------------------    Options   ---------------------------- //

// Data bars for calculating the indicator values with the necessary precission.
// If set to 0, the expert calculates them automatically.
int Min_Data_Bars=0;

// Separate SL and TP orders
// It has to be set to true for STP brokers that cannot set SL and TP together with the position (with OrderSend()).
// When Separate_SL_TP = true, the expert first opens the position and after that sets StopLoss and TakeProfit.
bool Separate_SL_TP = false; // Separate SL and TP orders 

// TrailingStop_Moving_Step determines the step of changing the Trailing Stop.
// 0 <= TrailingStop_Moving_Step <= 2000
// If TrailingStop_Moving_Step = 0, the Trailing Stop trails at every new extreme price in the position's direction.
// If TrailingStop_Moving_Step > 0, the Trailing Stop moves at steps equal to the number of pips chosen.
// This prevents sending multiple order modifications.
int TrailingStop_Moving_Step = 10;

// FIFO (First In First Out) forces the expert to close positions starting from
// the oldest one. This rule complies with the new NFA regulations.
// If you want to close the positions from the newest one (FILO), change the variable to "false".
// This doesn't change the normal work of Forex Strategy Builder.
bool FIFO_order = true;

// When the log file reaches the preset number of lines,
// the expert starts a new log file.
int Max_Log_Lines_in_File = 2000;

// Used to detect a chart change
string __symbol = "";
int    __period = -1;

//##IMPORT Enumerations.mqh
//##IMPORT Helpers.mqh
//##IMPORT HelperMq4.mqh
//##IMPORT DataSet.mqh
//##IMPORT DataMarket.mqh
//##IMPORT IndicatorComp.mqh
//##IMPORT IndicatorParam.mqh
//##IMPORT Indicator.mqh
//##IMPORT IndicatorManager.mqh
//##IMPORT IndicatorSlot.mqh
//##IMPORT Strategy.mqh
//##IMPORT StrategyManager.mqh
//##IMPORT Position.mqh
//##IMPORT Logger.mqh
//##IMPORT StrategyTrader.mqh
//##IMPORT ActionTrade4.mqh

ActionTrade *actionTrade;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   actionTrade=new ActionTrade();

   actionTrade.EntryAmount            = Entry_Amount    > 77700 ? 0.1 : Entry_Amount;
   actionTrade.MaximumAmount          = Maximum_Amount  > 77700 ? 0.1 : Maximum_Amount;
   actionTrade.AddingAmount           = Adding_Amount   > 77700 ? 0.1 : Adding_Amount;
   actionTrade.ReducingAmount         = Reducing_Amount > 77700 ? 0.1 : Reducing_Amount;
   actionTrade.OrderComment           = Order_Comment;
   actionTrade.MinDataBars            = Min_Data_Bars;
   actionTrade.ProtectionMinAccount   = Protection_Min_Account;
   actionTrade.ProtectionMaxStopLoss  = Protection_Max_StopLoss;
   actionTrade.ExpertMagic            = Expert_Magic;
   actionTrade.SeparateSLTP           = Separate_SL_TP;
   actionTrade.WriteLogFile           = Write_Log_File;
   actionTrade.TrailingStopMovingStep = TrailingStop_Moving_Step;
   actionTrade.FIFOorder              = FIFO_order;
   actionTrade.MaxLogLinesInFile      = Max_Log_Lines_in_File;
   actionTrade.BarCloseAdvance        = Bar_Close_Advance;

   int result=actionTrade.OnInit();

   if(result==INIT_SUCCEEDED)
      actionTrade.OnTick();

   return (result);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(__symbol!=_Symbol || __period!=_Period)
     {
      if(__period>0)
        {
         actionTrade.OnDeinit(-1);
         actionTrade.OnInit();
        }
      __symbol = _Symbol;
      __period = _Period;
     }

   actionTrade.OnTick();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   actionTrade.OnDeinit(reason);

   if(CheckPointer(actionTrade)==POINTER_DYNAMIC)
      delete actionTrade;
  }

/*STRATEGY CODE*/
//+------------------------------------------------------------------+
