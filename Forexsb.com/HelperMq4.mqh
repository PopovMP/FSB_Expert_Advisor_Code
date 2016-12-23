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
#property version   "1.00"
#property strict
//## Import Start

string GetErrorDescription(int errorCode)
  {
   string message;

   switch(errorCode)
     {
      //--- codes returned from trade server
      case 0:    message = "No error"; break;
      case 1:    message = "No error, trade conditions not changed"; break;
      case 2:    message = "Common error"; break;
      case 3:    message = "Invalid trade parameters"; break;
      case 4:    message = "Trade server is busy"; break;
      case 5:    message = "Old version of the client terminal"; break;
      case 6:    message = "No connection with trade server"; break;
      case 7:    message = "Not enough rights"; break;
      case 8:    message = "Too frequent requests"; break;
      case 9:    message = "Malfunctional trade operation (never returned error)"; break;
      case 64:   message = "Account disabled"; break;
      case 65:   message = "Invalid account"; break;
      case 128:  message = "Trade timeout"; break;
      case 129:  message = "Invalid price"; break;
      case 130:  message = "Invalid stops"; break;
      case 131:  message = "Invalid trade volume"; break;
      case 132:  message = "Market is closed"; break;
      case 133:  message = "Trade is disabled"; break;
      case 134:  message = "Not enough money"; break;
      case 135:  message = "Price changed"; break;
      case 136:  message = "Off quotes"; break;
      case 137:  message = "Broker is busy (never returned error)"; break;
      case 138:  message = "Requote"; break;
      case 139:  message = "Order is locked"; break;
      case 140:  message = "Long positions only allowed"; break;
      case 141:  message = "Too many requests"; break;
      case 145:  message = "Modification denied because order is too close to market"; break;
      case 146:  message = "Trade context is busy"; break;
      case 147:  message = "Expirations are denied by broker"; break;
      case 148:  message = "Amount of open and pending orders has reached the limit"; break;
      case 149:  message = "Hedging is prohibited"; break;
      case 150:  message = "Prohibited by FIFO rules"; break;
      //--- mql4 errors case 4000: message = "No error (never generated code)";
      case 4001: message = "Wrong function pointer"; break;
      case 4002: message = "Array index is out of range"; break;
      case 4003: message = "No memory for function call stack"; break;
      case 4004: message = "Recursive stack overflow"; break;
      case 4005: message = "Not enough stack for parameter"; break;
      case 4006: message = "No memory for parameter string"; break;
      case 4007: message = "No memory for temp string"; break;
      case 4008: message = "Non-initialized string"; break;
      case 4009: message = "Non-initialized string in array"; break;
      case 4010: message = "No memory for array string"; break;
      case 4011: message = "Too long string"; break;
      case 4012: message = "Remainder from zero divide"; break;
      case 4013: message = "Zero divide"; break;
      case 4014: message = "Unknown command"; break;
      case 4015: message = "Wrong jump (never generated error)"; break;
      case 4016: message = "Non-initialized array"; break;
      case 4017: message = "Dll calls are not allowed"; break;
      case 4018: message = "Cannot load library"; break;
      case 4019: message = "Cannot call function"; break;
      case 4020: message = "Expert function calls are not allowed"; break;
      case 4021: message = "Not enough memory for temp string returned from function"; break;
      case 4022: message = "System is busy (never generated error)"; break;
      case 4023: message = "Dll-function call critical error"; break;
      case 4024: message = "Internal error"; break;
      case 4025: message = "Out of memory"; break;
      case 4026: message = "Invalid pointer"; break;
      case 4027: message = "Too many formatters in the format function"; break;
      case 4028: message = "Parameters count is more than formatters count"; break;
      case 4029: message = "Invalid array"; break;
      case 4030: message = "No reply from chart"; break;
      case 4050: message = "Invalid function parameters count"; break;
      case 4051: message = "Invalid function parameter value"; break;
      case 4052: message = "String function internal error"; break;
      case 4053: message = "Some array error"; break;
      case 4054: message = "Incorrect series array usage"; break;
      case 4055: message = "Custom indicator error"; break;
      case 4056: message = "Arrays are incompatible"; break;
      case 4057: message = "Global variables processing error"; break;
      case 4058: message = "Global variable not found"; break;
      case 4059: message = "Function is not allowed in testing mode"; break;
      case 4060: message = "Function is not confirmed"; break;
      case 4061: message = "Send mail error"; break;
      case 4062: message = "String parameter expected"; break;
      case 4063: message = "Integer parameter expected"; break;
      case 4064: message = "Double parameter expected"; break;
      case 4065: message = "Array as parameter expected"; break;
      case 4066: message = "Requested history data is in update state"; break;
      case 4067: message = "Internal trade error"; break;
      case 4068: message = "Resource not found"; break;
      case 4069: message = "Resource not supported"; break;
      case 4070: message = "Duplicate resource"; break;
      case 4071: message = "Cannot initialize custom indicator"; break;
      case 4072: message = "Cannot load custom indicator"; break;
      case 4073: message = "No history data"; break;
      case 4074: message = "No memory for history data"; break;
      case 4099: message = "End of file"; break;
      case 4100: message = "Some file error"; break;
      case 4101: message = "Wrong file name"; break;
      case 4102: message = "Too many opened files"; break;
      case 4103: message = "Cannot open file"; break;
      case 4104: message = "Incompatible access to a file"; break;
      case 4105: message = "No order selected"; break;
      case 4106: message = "Unknown symbol"; break;
      case 4107: message = "Invalid price parameter for trade function"; break;
      case 4108: message = "Invalid ticket"; break;
      case 4109: message = "Trade is not allowed in the expert properties"; break;
      case 4110: message = "Longs are not allowed in the expert properties"; break;
      case 4111: message = "Shorts are not allowed in the expert properties"; break;
      case 4200: message = "Object already exists"; break;
      case 4201: message = "Unknown object property"; break;
      case 4202: message = "Object does not exist"; break;
      case 4203: message = "Unknown object type"; break;
      case 4204: message = "No object name"; break;
      case 4205: message = "Object coordinates error"; break;
      case 4206: message = "No specified subwindow"; break;
      case 4207: message = "Graphical object error"; break;
      case 4210: message = "Unknown chart property"; break;
      case 4211: message = "Chart not found"; break;
      case 4212: message = "Chart subwindow not found"; break;
      case 4213: message = "Chart indicator not found"; break;
      case 4220: message = "Symbol select error"; break;
      case 4250: message = "Notification error"; break;
      case 4251: message = "Notification parameter error"; break;
      case 4252: message = "Notifications disabled"; break;
      case 4253: message = "Notification send too frequent"; break;
      case 5001: message = "Too many opened files"; break;
      case 5002: message = "Wrong file name"; break;
      case 5003: message = "Too long file name"; break;
      case 5004: message = "Cannot open file"; break;
      case 5005: message = "Text file buffer allocation error"; break;
      case 5006: message = "Cannot delete file"; break;
      case 5007: message = "Invalid file handle (file closed or was not opened)"; break;
      case 5008: message = "Wrong file handle (handle index is out of handle table)"; break;
      case 5009: message = "File must be opened with FILE_WRITE flag"; break;
      case 5010: message = "File must be opened with FILE_READ flag"; break;
      case 5011: message = "File must be opened with FILE_BIN flag"; break;
      case 5012: message = "File must be opened with FILE_TXT flag"; break;
      case 5013: message = "File must be opened with FILE_TXT or FILE_CSV flag"; break;
      case 5014: message = "File must be opened with FILE_CSV flag"; break;
      case 5015: message = "File read error"; break;
      case 5016: message = "File write error"; break;
      case 5017: message = "String size must be specified for binary file"; break;
      case 5018: message = "Incompatible file (for string arrays-TXT, for others-BIN)"; break;
      case 5019: message = "File is directory, not file"; break;
      case 5020: message = "File does not exist"; break;
      case 5021: message = "File cannot be rewritten"; break;
      case 5022: message = "Wrong directory name"; break;
      case 5023: message = "Directory does not exist"; break;
      case 5024: message = "Specified file is not directory"; break;
      case 5025: message = "Cannot delete directory"; break;
      case 5026: message = "Cannot clean directory"; break;
      case 5027: message = "Array resize error"; break;
      case 5028: message = "String resize error"; break;
      case 5029: message = "Structure contains strings or dynamic arrays"; break;
      default:   message = "Unknown error"; break;
     }

   return (message);
  }
//+------------------------------------------------------------------+
