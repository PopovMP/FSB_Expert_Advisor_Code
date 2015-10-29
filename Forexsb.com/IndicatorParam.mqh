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
#property version   "3.00"
#property strict

//## Import Start

class ListParameter
{
public:
    // Constructors
    ListParameter()
    {
        Caption = "";
        Text    = "";
        Index   = -1;
        Enabled = false;
    }

    // Properties
    string Caption;
    string Text;
    int    Index;
    bool   Enabled;
};

class NumericParameter
{
public:
    // Constructor
    NumericParameter()
    {
        Caption = "";
        Value   = 0;
        Enabled = false;
    }

    // Properties
    string Caption;
    double Value;
    bool   Enabled;
};

class CheckParameter
{
public:
    // Constructor
    CheckParameter()
    {
        Caption = "";
        Checked = false;
        Enabled = false;
    }

    // Properties
    string Caption;
    bool   Checked;
    bool   Enabled;
};
