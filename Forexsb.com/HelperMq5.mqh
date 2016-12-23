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

#include <Forexsb.com\Helpers.mqh>

//## Import Start

#define OP_BUY   ORDER_TYPE_BUY
#define OP_SELL  ORDER_TYPE_SELL
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int AccountNumber()
  {
   return ((int) AccountInfoInteger(ACCOUNT_LOGIN));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES DataPeriodToTimeFrame(DataPeriod period)
  {
   ENUM_TIMEFRAMES timeFrame;
   switch(period)
     {
      case DataPeriod_M1:  timeFrame = PERIOD_M1;  break;
      case DataPeriod_M5:  timeFrame = PERIOD_M5;  break;
      case DataPeriod_M15: timeFrame = PERIOD_M15; break;
      case DataPeriod_M30: timeFrame = PERIOD_M30; break;
      case DataPeriod_H1:  timeFrame = PERIOD_H1;  break;
      case DataPeriod_H4:  timeFrame = PERIOD_H4;  break;
      case DataPeriod_D1:  timeFrame = PERIOD_D1;  break;
      case DataPeriod_W1:  timeFrame = PERIOD_W1;  break;
      case DataPeriod_MN1: timeFrame = PERIOD_MN1; break;
      default:             timeFrame = PERIOD_D1; break;
     }
   return (timeFrame);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime Time(string symbol,ENUM_TIMEFRAMES period,int bar)
  {
   datetime datetime_array[];
   ArrayResize(datetime_array,1);
   int result=CopyTime(symbol,period,bar,1,datetime_array);
   datetime time=(result==1) ? datetime_array[0]: 0;
   return (time);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Open(string symbol,ENUM_TIMEFRAMES period,int bar)
  {
   double double_array[];
   ArrayResize(double_array,1);
   int result=CopyOpen(symbol,period,bar,1,double_array);
   double open=(result==1) ? double_array[0]: 0;
   return (open);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double High(string symbol,ENUM_TIMEFRAMES period,int bar)
  {
   double double_array[];
   ArrayResize(double_array,1);
   int result=CopyHigh(symbol,period,bar,1,double_array);
   double high=(result==1) ? double_array[0]: 0;
   return (high);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Low(string symbol,ENUM_TIMEFRAMES period,int bar)
  {
   double double_array[];
   ArrayResize(double_array,1);
   int result=CopyLow(symbol,period,bar,1,double_array);
   double low=(result==1) ? double_array[0]: 0;
   return (low);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Close(string symbol,ENUM_TIMEFRAMES period,int bar)
  {
   double double_array[];
   ArrayResize(double_array,1);
   int result=CopyClose(symbol,period,bar,1,double_array);
   double close=(result==1) ? double_array[0]: 0;
   return (close);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long Volume(string symbol,ENUM_TIMEFRAMES period,int bar)
  {
   long long_array[];
   ArrayResize(long_array,1);
   int result=CopyTickVolume(symbol,period,bar,1,long_array);
   long volume=(result==1) ? long_array[0]: 0;
   return (volume);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeDay(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return (tm.day);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeDayOfWeek(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return (tm.day_of_week);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeDayOfYear(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return (tm.day_of_year);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeHour(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return (tm.hour);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeMinute(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return (tm.min);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeMonth(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return (tm.mon);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeSeconds(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return (tm.sec);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeYear(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return (tm.year);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ResultRetcodeDescription(int code)
  {
   string message;
   switch(code)
     {
      case TRADE_RETCODE_REQUOTE:            message = "Requote"; break;
      case TRADE_RETCODE_REJECT:             message = "Request rejected"; break;
      case TRADE_RETCODE_CANCEL:             message = "Request canceled by trader"; break;
      case TRADE_RETCODE_PLACED:             message = "Order placed"; break;
      case TRADE_RETCODE_DONE:               message = "Request completed"; break;
      case TRADE_RETCODE_DONE_PARTIAL:       message = "Only part of the request was completed"; break;
      case TRADE_RETCODE_ERROR:              message = "Request processing error"; break;
      case TRADE_RETCODE_TIMEOUT:            message = "Request canceled by timeout"; break;
      case TRADE_RETCODE_INVALID:            message = "Invalid request"; break;
      case TRADE_RETCODE_INVALID_VOLUME:     message = "Invalid volume in the request"; break;
      case TRADE_RETCODE_INVALID_PRICE:      message = "Invalid price in the request"; break;
      case TRADE_RETCODE_INVALID_STOPS:      message = "Invalid stops in the request"; break;
      case TRADE_RETCODE_TRADE_DISABLED:     message = "Trade is disabled"; break;
      case TRADE_RETCODE_MARKET_CLOSED:      message = "Market is closed"; break;
      case TRADE_RETCODE_NO_MONEY:           message = "There is not enough money to complete the request"; break;
      case TRADE_RETCODE_PRICE_CHANGED:      message = "Prices changed"; break;
      case TRADE_RETCODE_PRICE_OFF:          message = "There are no quotes to process the request"; break;
      case TRADE_RETCODE_INVALID_EXPIRATION: message = "Invalid order expiration date in the request"; break;
      case TRADE_RETCODE_ORDER_CHANGED:      message = "Order state changed"; break;
      case TRADE_RETCODE_TOO_MANY_REQUESTS:  message = "Too frequent requests"; break;
      case TRADE_RETCODE_NO_CHANGES:         message = "No changes in request"; break;
      case TRADE_RETCODE_SERVER_DISABLES_AT: message = "Autotrading disabled by server"; break;
      case TRADE_RETCODE_CLIENT_DISABLES_AT: message = "Autotrading disabled by client terminal"; break;
      case TRADE_RETCODE_LOCKED:             message = "Request locked for processing"; break;
      case TRADE_RETCODE_FROZEN:             message = "Order or position frozen"; break;
      case TRADE_RETCODE_INVALID_FILL:       message = "Invalid order filling type"; break;
      case TRADE_RETCODE_CONNECTION:         message = "No connection with the trade server"; break;
      case TRADE_RETCODE_ONLY_REAL:          message = "Operation is allowed only for live accounts"; break;
      case TRADE_RETCODE_LIMIT_ORDERS:       message = "The number of pending orders has reached the limit"; break;
      case TRADE_RETCODE_LIMIT_VOLUME:       message = "The volume of orders and positions has reached the limit"; break;
      case TRADE_RETCODE_INVALID_ORDER:      message = "Incorrect or prohibited order type"; break;
      case TRADE_RETCODE_POSITION_CLOSED:    message = "Position specified has already been closed"; break;
      default:                               message = "Unknown result"; break;
     }
   return (message);
  }
//+------------------------------------------------------------------+
