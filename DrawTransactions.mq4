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
#property indicator_chart_window

input bool InpDrawVerticalLines = true; // Draw Vertical Red Lines
input color InpWinColor = clrLightCyan; // Loss Color
input color InpLossColor = clrLightSalmon; // Win Color
input string InpFileName = "ForexFactoryTransactions.txt"; // File Name
input int InpGMTOffset = 0; // Hour Offset

const string prefix = "FFD - ";


string symbol;
string type;
double open_price;
double close_price;
datetime open_time;
datetime close_time;

string symbol_map[][3] = {
    {"XTIUSD", "CRUDEOIL", "CrudeOIL"},
    {"DAX30", "DE30", ""},
    {"XAUUSD", "GOLD", ""},
    {"XAGUSD", "SILVER", ""},
};

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

long AmPmTo24(string& result[])
{
    long hour = StringToInteger(result[0]);
    if (StringFind(result[1], "pm") == -1) {
        hour %= 12;
    } else {
        hour = (hour + 12) % 24;
    }
    return hour;
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

    long hour = AmPmTo24(result);
    open_time = StrToTime(year + "." + month + "." + day + " " +
                          IntegerToString(hour) + ":" + result[1]);
    open_time += -InpGMTOffset * 60 * 60;
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

    long hour = AmPmTo24(result);
    close_time = StrToTime(year + "." + month + "." + day + " " +
                           IntegerToString(hour) + ":" + result[1]);
    close_time += -InpGMTOffset * 60 * 60;
    return false;
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateUI(long chart_id) {
    string name = "ShiftLeft";
    bool res = ObjectCreate(chart_id, name, OBJ_BUTTON, 0, 0, 0);
    if (res) {
        ObjectSetInteger(chart_id, name, OBJPROP_XDISTANCE, 42);
        ObjectSetInteger(chart_id, name, OBJPROP_YDISTANCE, 42);
        ObjectSetInteger(chart_id, name, OBJPROP_XSIZE, 42);
        ObjectSetInteger(chart_id, name, OBJPROP_YSIZE, 42);
        ObjectSetString(chart_id, name, OBJPROP_TEXT, "<");
    }

    name = "ShiftRight";
    res = ObjectCreate(chart_id, name, OBJ_BUTTON, 0, 0, 0);
    if (res) {
        ObjectSetInteger(chart_id, name, OBJPROP_XDISTANCE, 84);
        ObjectSetInteger(chart_id, name, OBJPROP_YDISTANCE, 42);
        ObjectSetInteger(chart_id, name, OBJPROP_XSIZE, 42);
        ObjectSetInteger(chart_id, name, OBJPROP_YSIZE, 42);
        ObjectSetString(chart_id, name, OBJPROP_TEXT, ">");
    }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long FindOrOpenChart(string sym) {
    long chart_id = ChartFirst();
    while (chart_id != -1) {
        if (StringCompare(sym, ChartSymbol(chart_id)) == 0) {
            break;
        }
        chart_id = ChartNext(chart_id);
    }

    if (chart_id == -1) {
        chart_id = ChartOpen(sym, PERIOD_M15);
        if (chart_id == 0) {
            chart_id = -1;
        } else {
            ObjectsDeleteAll(chart_id, prefix);
            ChartRedraw(chart_id);
        }
    }

    CreateUI(chart_id);

    return chart_id;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawTransaction() {
    static long cnt = 0;
    cnt++;

    string object_name = prefix + type +
                         " Open:" + DoubleToString(open_price, 2) +
                         " Close:" + DoubleToString(close_price, 2) +
                         " id:" + IntegerToString(cnt);
    string vline_name = object_name + " vline";

    long chart_id = FindOrOpenChart(symbol);
    if (chart_id == -1) {
        int row_idx = 0;
        bool found = false;
        for (; row_idx < ArrayRange(symbol_map, 0) && !found; ++row_idx) {
            for (int idx = 0; idx < ArrayRange(symbol_map, 1); ++idx) {
                if (StringCompare(symbol, symbol_map[row_idx][idx]) == 0) {
                    found = true;
                    break;
                }
            }
        }
        if (found) {
            row_idx--;
            for (int idx = 0; idx < ArrayRange(symbol_map, 1); ++idx) {
                chart_id = FindOrOpenChart(symbol_map[row_idx][idx]);
                if (chart_id != -1) {
                    break;
                }
            }
        }
        if (chart_id == -1) {
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
void OnInit() {
    long chart_id = ChartFirst();
    while (chart_id != -1) {
        ObjectsDeleteAll(chart_id, prefix);
        ChartRedraw(chart_id);
        chart_id = ChartNext(chart_id);
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
    EventSetMillisecondTimer(100);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    EventKillTimer();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer() {
    bool shift_left = false;
    bool shift_right = false;
    long chart_id = ChartFirst();
    while (chart_id != -1 && !shift_left && !shift_right) {
        shift_left = ObjectGetInteger(chart_id, "ShiftLeft", OBJPROP_STATE);
        if (shift_left) {
            ObjectSetInteger(chart_id, "ShiftLeft", OBJPROP_STATE, false);
        }
        shift_right = ObjectGetInteger(chart_id, "ShiftRight", OBJPROP_STATE);
        if (shift_right) {
            ObjectSetInteger(chart_id, "ShiftRight", OBJPROP_STATE, false);
        }
        chart_id = ChartNext(chart_id);
    }

    int offset;
    if (shift_left) {
        offset = -1;
    } else if (shift_right) {
        offset = 1;
    } else {
        return;
    }

    chart_id = ChartFirst();
    while (chart_id != -1) {
        for(int i = 0; i < ObjectsTotal(chart_id); i++) {
            string name = ObjectName(chart_id, i);
            if (StringFind(name, prefix) == 0) {
                double price = ObjectGetDouble(chart_id, name, OBJPROP_PRICE, 0);
                datetime open = (datetime)ObjectGetInteger(chart_id, name, OBJPROP_TIME, 0);
                open += offset * 60 * 60;
                ObjectMove(chart_id, name, 0, open, price);

                price = ObjectGetDouble(chart_id, name, OBJPROP_PRICE, 1);
                datetime close = (datetime)ObjectGetInteger(chart_id, name, OBJPROP_TIME, 1);
                if (close > open) {
                    close += offset * 60 * 60;
                    ObjectMove(chart_id, name, 1, close, price);
                }

            }
        }
        ChartRedraw(chart_id);
        chart_id = ChartNext(chart_id);
    }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {
    return rates_total;
}
//+------------------------------------------------------------------+
