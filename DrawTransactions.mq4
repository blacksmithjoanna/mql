//+------------------------------------------------------------------+
//|                                             DrawTransactions.mq4 |
//|                               Copyright 2021, PZF Software Corp. |
//|                          https://github.com/blacksmithjoanna/mql |
//+------------------------------------------------------------------+
#property copyright   "2021, PZF Software Corp."
#property description "Draw transactions from ForexFactory"
#property link        "https://github.com/blacksmithjoanna/mql"
#property strict
#property show_inputs

input int InpGMTOffset = 0; // Hour Offset
input bool InpDrawVerticalLines = true; // Draw Vertical Red Lines
input color InpWinColor = clrLightCyan; // Loss Color
input color InpLossColor = clrLightSalmon; // Win Color
input string InpFileName = "ForexFactoryTransactions.txt"; // File Name

const string prefix = "FFD - ";

string symbol;
string type;
double open_price;
double close_price;
datetime open_time;
datetime close_time;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ParseSymbolTypeOpenPrice(string line, int& line_number) {
    string result[];
    int count = StringSplit(line, ' ', result);
    if (count < 3) {
        Print("Error at line number: ", line_number);
        Print("Was expecting to find symbol name and transaction open price eg. 'Dax30 Sell 13,619.5'");
        Print("Instead, this has been found: ", line);
        return true;
    }
    symbol = result[0];
    StringToUpper(symbol);
    StringReplace(symbol, "/", "");

    type = result[count - 2];

    string open_price_string = result[count - 1];
    StringReplace(open_price_string, ",", "");
    open_price = StringToDouble(open_price_string);

    return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ParseClosePrice(int file_handle, int& line_number) {
    line_number++;
    string line = FileReadString(file_handle);
    StringReplace(line, "\t", " ");
    line = StringTrimLeft(line);

    string result[];
    int count = StringSplit(line, ' ', result);
    if (count < 2) {
        Print("Error at line number: ", line_number);
        Print("Was expecting to find close price eg. 'Buy 13,469.5'");
        Print("Instead, this has been found: ", line);
        return true;
    }

    string close_price_string = result[count - 1];
    StringReplace(close_price_string, ",", "");
    close_price = StringToDouble(close_price_string);

    return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string MonthToNumber(string month) {
    if (StringCompare(month, "jan", false) == 0) return "01";
    if (StringCompare(month, "feb", false) == 0) return "02";
    if (StringCompare(month, "mar", false) == 0) return "03";
    if (StringCompare(month, "apr", false) == 0) return "04";
    if (StringCompare(month, "may", false) == 0) return "05";
    if (StringCompare(month, "jun", false) == 0) return "06";
    if (StringCompare(month, "jul", false) == 0) return "07";
    if (StringCompare(month, "aug", false) == 0) return "08";
    if (StringCompare(month, "sep", false) == 0) return "09";
    if (StringCompare(month, "oct", false) == 0) return "10";
    if (StringCompare(month, "nov", false) == 0) return "11";
    if (StringCompare(month, "dec", false) == 0) return "12";

    return "";
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ParseOpenTime(int file_handle, int& line_number) {
    line_number++;
    string line = FileReadString(file_handle);
    StringReplace(line, "\t", " ");
    line = StringTrimLeft(line);

    string result[];
    int count = StringSplit(line, ' ', result);
    if (count < 4) {
        Print("Error at line number: ", line_number);
        Print("Was expecting to find open time eg. 'Jan 27, 2021 10:12am'");
        Print("Instead, this has been found: ", line);
        return true;
    }

    string month = MonthToNumber(result[0]);
    if (StringLen(month) == 0) {
        Print("Error, unknown month: ", result[0]);
        return true;
    }

    string day = result[1];
    StringReplace(day, ",", "");

    string year = result[2];

    count = StringSplit(result[3], ':', result);
    if (count < 2) {
        Print("Error at line number: ", line_number);
        Print("Was expecting to find open time eg. 'Jan 27, 2021 10:12am'");
        Print("Instead, this has been found: ", line);
        return true;
    }
    long hour = StringToInteger(result[0]);
    if (StringFind(result[1], "pm") == -1) {
        hour %= 12;
    } else {
        hour = (hour + 12) % 24;
    }

    open_time = StrToTime(year + "." + month + "." + day + " " +
                          IntegerToString(hour) + ":" + result[1]);
    open_time += InpGMTOffset * 60 * 60;

    return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ParseCloseTime(int file_handle, int& line_number) {
    line_number++;
    string line = FileReadString(file_handle);
    StringReplace(line, "\t", " ");
    line = StringTrimLeft(line);

    string result[];
    int count = StringSplit(line, ' ', result);
    if (count < 4) {
        Print("Error at line number: ", line_number);
        Print("Was expecting to find close time eg. 'Jan 27, 2021 3:48pm'");
        Print("Instead, this has been found: ", line);
        return true;
    }

    string month = MonthToNumber(result[0]);
    if (StringLen(month) == 0) {
        Print("Error, unknown month: ", result[0]);
        return true;
    }

    string day = result[1];
    StringReplace(day, ",", "");

    string year = result[2];

    count = StringSplit(result[3], ':', result);
    if (count < 2) {
        Print("Error at line number: ", line_number);
        Print("Was expecting to find close time eg. 'Jan 27, 2021 3:48pm'");
        Print("Instead, this has been found: ", line);
        return true;
    }
    long hour = StringToInteger(result[0]);
    if (StringFind(result[1], "pm") == -1) {
        hour %= 12;
    } else if (hour < 12) {
        hour += 12;
    }

    close_time = StrToTime(year + "." + month + "." + day + " " +
                           IntegerToString(hour) + ":" + result[1]);
    close_time += InpGMTOffset * 60 * 60;

    return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawTransaction() {
    string object_name = "FFD - " + type +
                         " Open:" + DoubleToString(open_price, 2) +
                         " Close:" + DoubleToString(close_price, 2);
    string vline_name = object_name + " vline";

    long chart_id = ChartFirst();
    while (chart_id != -1) {
        if (StringCompare(symbol, ChartSymbol(chart_id)) == 0) {
            break;
        }
        chart_id = ChartNext(chart_id);
    }

    if (chart_id == -1) {
        chart_id = ChartOpen(symbol, PERIOD_M15);
        if (chart_id > 0) {
            ObjectsDeleteAll(chart_id, prefix);
            ChartRedraw(chart_id);
        } else {
            Print("Error, symbol not found: ", symbol);
            return;
        }
    }

    ChartSetInteger(chart_id, CHART_AUTOSCROLL, false);
    ChartSetInteger(chart_id, CHART_SHOW_GRID, false);
    ChartNavigate(chart_id, CHART_END, 0);

    if (InpDrawVerticalLines) {
        ObjectCreate(chart_id, vline_name, OBJ_VLINE, 0, open_time, open_price);
    }
    ObjectCreate(chart_id, object_name, OBJ_TREND, 0, open_time, open_price, close_time, close_price);
    ObjectSetInteger(chart_id, object_name, OBJPROP_RAY_RIGHT, false);
    ObjectSetInteger(chart_id, object_name, OBJPROP_WIDTH, 3);
    if (StringCompare(type, "sell") == 0) {
        if (open_price >= close_price) {
            ObjectSetInteger(chart_id, object_name, OBJPROP_COLOR, InpWinColor);
        } else {
            ObjectSetInteger(chart_id, object_name, OBJPROP_COLOR, InpLossColor);
        }
    } else {
        if (open_price <= close_price) {
            ObjectSetInteger(chart_id, object_name, OBJPROP_COLOR, InpWinColor);
        } else {
            ObjectSetInteger(chart_id, object_name, OBJPROP_COLOR, InpLossColor);
        }
    }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart() {
    long chart_id = ChartFirst();
    while (chart_id != -1) {
        ObjectsDeleteAll(chart_id, prefix);
        ChartRedraw(chart_id);
        chart_id = ChartNext(chart_id);
    }

    if (chart_id == -1) {
        chart_id = ChartOpen(symbol, PERIOD_M15);
        ObjectsDeleteAll(chart_id, prefix);
        ChartRedraw(chart_id);
    }
    ResetLastError();
    int file_handle = FileOpen(InpFileName, FILE_READ | FILE_TXT);
    if (file_handle == INVALID_HANDLE) {
        PrintFormat("Failed to open the file with transactions data: %s\\Files\\%s",
                    TerminalInfoString(TERMINAL_DATA_PATH), InpFileName);
        Print("Error is: ", GetLastError());
    }

    int line_number = 0;
    while (!FileIsEnding(file_handle)) {
        line_number++;
        string line = FileReadString(file_handle);
        StringToLower(line);
        StringReplace(line, "\t", " ");
        line = StringTrimLeft(line);
        if ((StringFind(line, "sell") == -1) && (StringFind(line, "buy") == -1)) {
            continue;
        }

        if (ParseSymbolTypeOpenPrice(line, line_number)) {
            break;
        }

        if (ParseClosePrice(file_handle, line_number)) {
            break;
        }

        if (ParseOpenTime(file_handle, line_number)) {
            break;
        }

        if (ParseCloseTime(file_handle, line_number)) {
            break;
        }

        DrawTransaction();

        // Skip one line
        line_number++;
        FileReadString(file_handle);
    }
    FileClose(file_handle);
}
//+------------------------------------------------------------------+
