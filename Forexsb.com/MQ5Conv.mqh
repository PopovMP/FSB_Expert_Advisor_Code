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

#include <Forexsb.com\Helpers.mqh>

//## Import Start

#define OP_BUY   ORDER_TYPE_BUY
#define OP_SELL  ORDER_TYPE_SELL

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int AccountNumber()
  {
   return ((int)AccountInfoInteger(ACCOUNT_LOGIN));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES DataPeriodToTimeFrame(DataPeriod period)
  {
   switch(period)
     {
      case DataPeriod_M1:  return PERIOD_M1;
      case DataPeriod_M5:  return PERIOD_M5;
      case DataPeriod_M15: return PERIOD_M15;
      case DataPeriod_M30: return PERIOD_M30;
      case DataPeriod_H1:  return PERIOD_H1;
      case DataPeriod_H4:  return PERIOD_H4;
      case DataPeriod_D1:  return PERIOD_D1;
      case DataPeriod_W1:  return PERIOD_W1;
      case DataPeriod_MN1: return PERIOD_MN1;
     }
   return (PERIOD_D1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime Time(string symbol,ENUM_TIMEFRAMES period,int bar)
  {
   datetime datetime_array[];
   ArrayResize(datetime_array,1);
   int result=CopyTime(symbol,period,bar,1,datetime_array);
   return (result==1)?datetime_array[0]:0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Open(string symbol,ENUM_TIMEFRAMES period,int bar)
  {
   double double_array[];
   ArrayResize(double_array,1);
   int result=CopyOpen(symbol,period,bar,1,double_array);
   return (result==1)?double_array[0]:0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double High(string symbol,ENUM_TIMEFRAMES period,int bar)
  {
   double double_array[];
   ArrayResize(double_array,1);
   int result=CopyHigh(symbol,period,bar,1,double_array);
   return (result==1)?double_array[0]:0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Low(string symbol,ENUM_TIMEFRAMES period,int bar)
  {
   double double_array[];
   ArrayResize(double_array,1);
   int result=CopyLow(symbol,period,bar,1,double_array);
   return (result==1)?double_array[0]:0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Close(string symbol,ENUM_TIMEFRAMES period,int bar)
  {
   double double_array[];
   ArrayResize(double_array,1);
   int result=CopyClose(symbol,period,bar,1,double_array);
   return (result==1)?double_array[0]:0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long Volume(string symbol,ENUM_TIMEFRAMES period,int bar)
  {
   long long_array[];
   ArrayResize(long_array,1);
   int result=CopyTickVolume(symbol,period,bar,1,long_array);
   return (result==1)?long_array[0]:0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeDay(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.day);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeDayOfWeek(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.day_of_week);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeDayOfYear(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.day_of_year);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeHour(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.hour);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeMinute(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.min);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeMonth(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.mon);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeSeconds(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.sec);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeYear(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.year);
  }
//+------------------------------------------------------------------+
//| возврат стрингового результата торговой операции по его коду     |
//+------------------------------------------------------------------+
string ResultRetcodeDescription(int retcode)
  {
   string str;
   switch(retcode)
     {
      case TRADE_RETCODE_REQUOTE:            str="Requote"; break;
      case TRADE_RETCODE_REJECT:             str="Request rejected"; break;
      case TRADE_RETCODE_CANCEL:             str="Request canceled by trader"; break;
      case TRADE_RETCODE_PLACED:             str="Order placed"; break;
      case TRADE_RETCODE_DONE:               str="Request completed"; break;
      case TRADE_RETCODE_DONE_PARTIAL:       str="Only part of the request was completed"; break;
      case TRADE_RETCODE_ERROR:              str="Request processing error"; break;
      case TRADE_RETCODE_TIMEOUT:            str="Request canceled by timeout";break;
      case TRADE_RETCODE_INVALID:            str="Invalid request"; break;
      case TRADE_RETCODE_INVALID_VOLUME:     str="Invalid volume in the request"; break;
      case TRADE_RETCODE_INVALID_PRICE:      str="Invalid price in the request"; break;
      case TRADE_RETCODE_INVALID_STOPS:      str="Invalid stops in the request"; break;
      case TRADE_RETCODE_TRADE_DISABLED:     str="Trade is disabled"; break;
      case TRADE_RETCODE_MARKET_CLOSED:      str="Market is closed"; break;
      case TRADE_RETCODE_NO_MONEY:           str="There is not enough money to complete the request"; break;
      case TRADE_RETCODE_PRICE_CHANGED:      str="Prices changed"; break;
      case TRADE_RETCODE_PRICE_OFF:          str="There are no quotes to process the request"; break;
      case TRADE_RETCODE_INVALID_EXPIRATION: str="Invalid order expiration date in the request"; break;
      case TRADE_RETCODE_ORDER_CHANGED:      str="Order state changed"; break;
      case TRADE_RETCODE_TOO_MANY_REQUESTS:  str="Too frequent requests"; break;
      case TRADE_RETCODE_NO_CHANGES:         str="No changes in request"; break;
      case TRADE_RETCODE_SERVER_DISABLES_AT: str="Autotrading disabled by server"; break;
      case TRADE_RETCODE_CLIENT_DISABLES_AT: str="Autotrading disabled by client terminal"; break;
      case TRADE_RETCODE_LOCKED:             str="Request locked for processing"; break;
      case TRADE_RETCODE_FROZEN:             str="Order or position frozen"; break;
      case TRADE_RETCODE_INVALID_FILL:       str="Invalid order filling type"; break;
      case TRADE_RETCODE_CONNECTION:         str="No connection with the trade server"; break;
      case TRADE_RETCODE_ONLY_REAL:          str="Operation is allowed only for live accounts"; break;
      case TRADE_RETCODE_LIMIT_ORDERS:       str="The number of pending orders has reached the limit"; break;
      case TRADE_RETCODE_LIMIT_VOLUME:       str="The volume of orders and positions for the symbol has reached the limit"; break;
      case TRADE_RETCODE_INVALID_ORDER:      str="Incorrect or prohibited order type"; break;
      case TRADE_RETCODE_POSITION_CLOSED:    str="Position specified has already been closed"; break;
      default:                               str="Unknown result";
     }
   return(str);
  }
//+------------------------------------------------------------------+
