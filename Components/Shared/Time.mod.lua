local SECOND = 1;
local MINUTE = 60*SECOND;
local HOUR = 60*MINUTE;
local DAY = 24*HOUR;
local WEEK = 7*DAY;
local YEAR = 365*DAY;
local LYEAR = 366*DAY;
local AYEAR = 365.25*DAY;
local TYEAR = 365.24*DAY;
local MONTH = TYEAR/12;
local iMONTH = DAY/0.0328549;

local fl, t, format, select, extract = math.floor, os.time, string.format, select

local Days = {
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday"
}
local iMonths = {
    "January", 
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
}

local function TimeFromSeconds(...)
    local sec = extract(...) or t();
    return format("%.2d:%.2d:%.2d", sec/HOUR%24, sec/MINUTE%MINUTE, sec%MINUTE)
end

local function DateFromSeconds(...)
    -- http://howardhinnant.github.io/date_algorithms.html#civil_from_days
    --[[
    z += 719468;
    const Int era = (z >= 0 ? z : z - 146096) / 146097;
    const unsigned doe = static_cast<unsigned>(z - era * 146097);          // [0, 146096]
    const unsigned yoe = (doe - doe/1460 + doe/36524 - doe/146096) / 365;  // [0, 399]
    const Int y = static_cast<Int>(yoe) + era * 400;
    const unsigned doy = doe - (365*yoe + yoe/4 - yoe/100);                // [0, 365]
    const unsigned mp = (5*doy + 2)/153;                                   // [0, 11]
    const unsigned d = doy - (153*mp+2)/5 + 1;                             // [1, 31]
    const unsigned m = mp + (mp < 10 ? 3 : -9);                            // [1, 12]
    return std::tuple<Int, unsigned, unsigned>(y + (m <= 2), m, d);
    ]]

    local sec = extract(...) or t()
    local days = fl(sec / DAY) + 719468
    local era = fl((days >= 0 and days or days - 146096) / 146097)
    local dayOfEra = (days - era * 146097)
    local yearOfEra = fl((days - fl(days/1460) + fl(days/36524) - fl(days/146096))/365)
    local dayOfYear = dayOfEra - (365*yearOfEra + fl(yearOfEra/4) - fl(yearOfEra/100))
    local monthOfEra = fl((5*dayOfYear + 2)/153)
    local days = dayOfYear - fl((153*monthOfEra + 2)/5) + 1
    local month = monthOfEra + (monthOfEra < 10 and 3 or -9)
    local year = yearOfEra + era*400 + (month < 3 and 1 or 0)

    return year, iMonths[month], days
end

local function DayFromSeconds(...) -- Epoch was on a Thursday
    local sec = extract(...) or t()
    return Days[(fl(sec/DAY) + 4)%7 + 1]
end

local function GetMonth(...)
    return select(2,DateFromSeconds(...))
end;

local function FullDate(...) -- Remember...
    local sec = extract(...) or t();
    
    local ret = {}
    ret.Time = TimeFromSeconds(sec)
    ret.Year, ret.Month, ret.Date = DateFromSeconds(sec)
    ret.Day = DayFromSeconds(sec)
    ret.Second = fl(sec%MINUTE)
    ret.Minute = fl(sec/MINUTE%MINUTE)
    ret.Hour = fl(sec/HOUR%24)
    return ret;
end

local Controller = {
    Time = FullDate;
    FullDate = FullDate;
    GetMonth = GetMonth;
    TimeFromSeconds = TimeFromSeconds;
    FormatTime = TimeFromSeconds;
    SECOND = SECOND;
    MINUTE = MINUTE;
    HOUR = HOUR;
    DAY = DAY;
    WEEK = WEEK;
    YEAR = YEAR;
    LYEAR = LYEAR;
    AYEAR = AYEAR;
    TYEAR = TYEAR;
    MONTH = MONTH;
    iMONTH = iMONTH
}

local _Controller = newproxy(true);
local mt = getmetatable(_Controller);
mt.__metatable = "Locked metatable: Valkyrie";
mt.__index = Controller;
mt.__tostring = function() return "Time Component" end;

extract = function(...)
  if ... == _Controller then
    return select(2, ...);
  else
    return ...
  end
end;

return _Controller
