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
#property version   "3.00"
#property strict

#include <Forexsb.com\Enumerations.mqh>

//## Import Start

bool LabelCreate(const long chart_ID = 0,              // chart's ID
                 const string name = "Label",          // label name
                 const int sub_window = 0,             // subwindow index
                 const int x = 0,                      // X coordinate
                 const int y = 0,                      // Y coordinate
                 const ENUM_BASE_CORNER corner = CORNER_LEFT_UPPER, // chart corner for anchoring
                 const string text = "Label",          // text
                 const string font = "Arial",          // font
                 const int font_size = 8,              // font size
                 const color clr = clrWhite,           // color
                 const double angle = 0.0,             // text slope
                 const ENUM_ANCHOR_POINT anchor = ANCHOR_LEFT_UPPER, // anchor type
                 const bool back = false,               // in the background
                 const bool selection = false,          // highlight to move
                 const bool hidden = true,              // hidden in the object list
                 const string tooltip = "\n",           // sets the tooltip
                 const long z_order = 0)                // priority for mouse click
{
    ResetLastError();

    if (!ObjectCreate(chart_ID, name, OBJ_LABEL, sub_window, 0, 0))
    {
        Print(__FUNCTION__, ": failed to create text label! Error code = ", GetLastError());
        return (false);
    }

    ObjectSetInteger(chart_ID, name, OBJPROP_XDISTANCE,  x);
    ObjectSetInteger(chart_ID, name, OBJPROP_YDISTANCE,  y);
    ObjectSetInteger(chart_ID, name, OBJPROP_CORNER,     corner);
    ObjectSetString(chart_ID,  name, OBJPROP_TEXT,       text);
    ObjectSetString(chart_ID,  name, OBJPROP_FONT,       font);
    ObjectSetInteger(chart_ID, name, OBJPROP_FONTSIZE,   font_size);
    ObjectSetInteger(chart_ID, name, OBJPROP_COLOR,      clr);
    ObjectSetDouble(chart_ID,  name, OBJPROP_ANGLE,      angle);
    ObjectSetInteger(chart_ID, name, OBJPROP_ANCHOR,     anchor);
    ObjectSetInteger(chart_ID, name, OBJPROP_BACK,       back);
    ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
    ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED,   selection);
    ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN,     hidden);
    ObjectSetString(chart_ID,  name, OBJPROP_TOOLTIP,    tooltip);
    ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER,     z_order);

    return (true);
}

bool LabelTextChange(const long chart_ID, const string name, const string text)
{
    ResetLastError();
    if (!ObjectSetString(chart_ID, name, OBJPROP_TEXT, text))
    {
        Print(__FUNCTION__, ": failed to change the text! Error code = ", GetLastError());
        return (false);
    }
    return (true);
}

bool LabelDelete(const long chart_ID = 0, const string name = "Label")
{
    if (!ObjectDelete(chart_ID, name))
    {
        Print(__FUNCTION__, ": failed to delete a text label! Error code = ", GetLastError());
        return (false);
    }
    return (true);
}

color GetChartForeColor(const long chartId = 0)
{
    long foreColor = clrWhite;
    ChartGetInteger(chartId, CHART_COLOR_FOREGROUND, 0, foreColor);
    return ((color) foreColor);
}

color GetChartBackColor(const long chartId = 0)
{
    long backColor = clrBlack;
    ChartGetInteger(chartId, CHART_COLOR_BACKGROUND, 0, backColor);
    return ((color) backColor);
}

string LoadStringFromFile(string filename)
{
    string text;
    int intSize;

    int handle = FileOpen(filename, FILE_TXT | FILE_READ | FILE_ANSI);
    if (handle == INVALID_HANDLE)
        return "";

    while (!FileIsEnding(handle))
    {
        intSize = FileReadInteger(handle, INT_VALUE);
        text += FileReadString(handle, intSize);
    }

    FileClose(handle);
    return text;
}

void SaveStringToFile(string filename, string text)
{
    int handle = FileOpen(filename, FILE_TXT | FILE_WRITE | FILE_ANSI);
    if (handle == INVALID_HANDLE)
        return;

    FileWriteString(handle, text);
    FileClose(handle);
}

bool ArrayContainsString(const string &array[], string text)
{
    for (int i = 0; i < ArraySize(array); i++)
        if (array[i] == text)
            return true;
    return false;
}

void ArrayAppendString(string &array[], string text)
{
    int size = ArraySize(array);
    ArrayResize(array, size + 1);
    array[size] = text;
}

string DataPeriodToString(DataPeriod period)
{
    switch (period)
    {
        case DataPeriod_M1:  return ("M1");
        case DataPeriod_M5:  return ("M5");
        case DataPeriod_M15: return ("M15");
        case DataPeriod_M30: return ("M30");
        case DataPeriod_H1:  return ("H1");
        case DataPeriod_H4:  return ("H4");
        case DataPeriod_D1:  return ("D1");
        case DataPeriod_W1:  return ("W1");
        case DataPeriod_MN1: return ("MN1");
    }

    return ("D1");
}

DataPeriod StringToDataPeriod(string period)
{
    if (period == "M1")  return (DataPeriod_M1);
    if (period == "M5")  return (DataPeriod_M5);
    if (period == "M15") return (DataPeriod_M15);
    if (period == "M30") return (DataPeriod_M30);
    if (period == "H1")  return (DataPeriod_H1);
    if (period == "H4")  return (DataPeriod_H4);
    if (period == "D1")  return (DataPeriod_D1);
    if (period == "W1")  return (DataPeriod_W1);
    if (period == "MN1") return (DataPeriod_MN1);
    return (DataPeriod_D1);
}

DataPeriod EnumTimeFramesToPeriod(int period)
{
    switch (period)
    {
        case PERIOD_M1:  return (DataPeriod_M1);
        case PERIOD_M5:  return (DataPeriod_M5);
        case PERIOD_M15: return (DataPeriod_M15);
        case PERIOD_M30: return (DataPeriod_M30);
        case PERIOD_H1:  return (DataPeriod_H1);
        case PERIOD_H4:  return (DataPeriod_H4);
        case PERIOD_D1:  return (DataPeriod_D1);
        case PERIOD_W1:  return (DataPeriod_W1);
        case PERIOD_MN1: return (DataPeriod_MN1);
    }
    return (DataPeriod_D1);
}

void SetMAMethodsText(string &list[])
{
    ArrayResize(list, 4);
    list[0] = "Simple";
    list[1] = "Weighted";
    list[2] = "Exponential";
    list[3] = "Smoothed";
}

void SetBasePricesText(string &list[])
{
    ArrayResize(list, 8);
    list[0] = "Open";
    list[1] = "High";
    list[2] = "Low";
    list[3] = "Close";
    list[4] = "Median";
    list[5] = "Typical";
    list[6] = "Low";
    list[7] = "Weighted";
}

string SameDirSignalActionToString(SameDirSignalAction action)
{
    switch (action)
    {
        case SameDirSignalAction_Add:
            return ("Add");
        case SameDirSignalAction_Winner:
            return ("Winner");
        case SameDirSignalAction_Loser:
            return ("Loser");
        case SameDirSignalAction_Nothing:
            return ("Nothing");
    }
    return ("");
}

string OppositeDirSignalActionToString(OppositeDirSignalAction action)
{
    switch (action)
    {
        case OppositeDirSignalAction_Close:
            return ("Close");
        case OppositeDirSignalAction_Nothing:
            return ("Nothing");
        case OppositeDirSignalAction_Reduce:
            return ("Reduce");
        case OppositeDirSignalAction_Reverse:
            return ("Reverse");
    }
    return ("");
}

string SlotTypeToString(SlotTypes slotType)
{
    string stringCaptionText = "Not Defined";
    switch (slotType)
    {
        case SlotTypes_Open:
            stringCaptionText = "Opening Point of the Position";
            break;
        case SlotTypes_OpenFilter:
            stringCaptionText = "Opening Logic Condition";
            break;
        case SlotTypes_Close:
            stringCaptionText = "Closing Point of the Position";
            break;
        case SlotTypes_CloseFilter:
            stringCaptionText = "Closing Logic Condition";
            break;
    }

    return (stringCaptionText);
}

SlotTypes SlotTypeFromShortString(string shortString)
{
    if (shortString == "Open")
        return (SlotTypes_Open);
    if (shortString == "OpenFilter")
        return (SlotTypes_OpenFilter);
    if (shortString == "Close")
        return (SlotTypes_Close);
    if (shortString == "CloseFilter")
        return (SlotTypes_CloseFilter);

    return (SlotTypes_NotDefined);
}

bool StringBoolToBool(string flag)
{
    return (flag == "True" || flag == "true");
}

string StringRemoveWhite(string instring)
{
    if (instring == "" || instring == NULL)
        return ("");
    string out = instring;
    string white[4] = {" ", "\r", "\n", "\t"};
    for (int i = 0; i < ArraySize(white); i++)
        StringReplace(out, white[i], "");
    return (out);
}

class ListString
{
    int m_count;
    string m_data[];
public:
    int Count() { return (m_count); }
    bool Contains(string element);
    void Add(string element);
    string Get(int index) { return (m_data[index]); };
};

void ListString::Add(string element)
{
    ArrayResize(m_data, m_count + 1);
    m_data[m_count] = element;
    m_count++;
}

bool ListString::Contains(string element)
{
    for (int i = 0; i < m_count; i++)
        if (m_data[i] == element)
            return (true);
    return (false);
}

class DictStringBool
{
    int m_count;
    string m_key[];
    bool m_val[];
public:
    int Count() { return m_count; }
    bool ContainsKey(string key);
    void Add(string key, bool value);
    void Set(string key, bool value);
    string Key(int index) { return (m_key[index]); }
    bool Value(string key);
};

bool DictStringBool::ContainsKey(string key)
{
    if (m_count == 0)
        return (false);
    for (int i = 0; i < m_count; i++)
        if (m_key[i] == key)
            return (true);
    return (false);
}

void DictStringBool::Add(string key, bool value)
{
    ArrayResize(m_key, m_count + 1);
    ArrayResize(m_val, m_count + 1);
    m_key[m_count] = key;
    m_val[m_count] = value;
    m_count++;
}

void DictStringBool::Set(string key, bool value)
{
    for (int i = 0; i < m_count; i++)
        if (m_key[i] == key)
        {
            m_val[i] = value;
            break;
        }
}

bool DictStringBool::Value(string key)
{
    for (int i = 0; i < m_count; i++)
        if (m_key[i] == key)
            return (m_val[i]);

    Print("ERROR DictStringBool::Value: Geven key does not exist.");
    return (false);
}
