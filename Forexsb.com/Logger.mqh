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


//## Import Start

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Logger
  {
   int               m_LogLines;
   int               m_FileHandle;

public:
   string            GetLogFileName(string symbol,int dataPeriod,int expertMagic);
   int               CreateLogFile(string fileName);
   void              WriteLogLine(string text);
   void              WriteNewLogLine(string text);
   void              WriteLogRequest(string text,string request);
   bool              IsLogLinesLimitReached(int maxLines);
   void              FlushLogFile(void);
   void              CloseLogFile(void);
   int               CloseExpert(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Logger::GetLogFileName(string symbol,int dataPeriod,int expertMagic)
  {
   string time=TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS);
   StringReplace(time,":","");
   StringReplace(time," ","_");
   string rnd=IntegerToString(MathRand());
   string fileName=symbol+"_"+IntegerToString(dataPeriod)+"_"+IntegerToString(expertMagic)+"_"+time+"_"+rnd+".log";
   return (fileName);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Logger::CreateLogFile(string fileName)
  {
   m_LogLines = 0;
   int handle = FileOpen(fileName, FILE_CSV|FILE_WRITE, ",");
   if(handle>0)
      m_FileHandle=handle;
   else
      Print("CreateFile: Error while creating log file!");
   return (handle);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Logger::WriteLogLine(string text)
  {
   if(m_FileHandle <= 0) return;
   FileWrite(m_FileHandle,TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),text);
   m_LogLines++;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Logger::WriteNewLogLine(string text)
  {
   if(m_FileHandle <= 0) return;
   FileWrite(m_FileHandle,"");
   FileWrite(m_FileHandle,TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),text);
   m_LogLines+=2;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Logger::WriteLogRequest(string text,string request)
  {
   if(m_FileHandle <= 0) return;
   FileWrite(m_FileHandle,"\n"+text);
   FileWrite(m_FileHandle,TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),request);
   m_LogLines+=3;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Logger::FlushLogFile()
  {
   if(m_FileHandle <= 0) return;
   FileFlush(m_FileHandle);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Logger::CloseLogFile()
  {
   if(m_FileHandle <= 0) return;
   WriteNewLogLine(StringFormat("%s Closed.",MQLInfoString(MQL_PROGRAM_NAME)));
   FileClose(m_FileHandle);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Logger::IsLogLinesLimitReached(int maxLines)
  {
   return (m_LogLines>maxLines);
  }
//+------------------------------------------------------------------+
