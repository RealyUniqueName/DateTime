package datetime;

import datetime.DateTime;
import datetime.DateTimeInterval;
import datetime.utils.DateTimeUtils;

using datetime.utils.DateTimeUtils;
using datetime.utils.DateTimeSnapUtils;
using datetime.utils.DateTimeMonthUtils;


/**
* Time periods for date math
*
*/
enum DTPeriod {

    Year (n:Int);
    Month (n:Int);
    Day (n:Int);
    Hour (n:Int);
    Minute (n:Int);
    Second (n:Int);
    Week (n:Int);

}//enum DTPeriod


/**
* Days of week
*
*/
@:enum abstract DTWeekDay (Int) to Int from Int {
    var Sunday    = 0;
    var Monday    = 1;
    var Tuesday   = 2;
    var Wednesday = 3;
    var Thursday  = 4;
    var Friday    = 5;
    var Saturday  = 6;
}//enum DTWeekDay


/**
* Months
*
*/
@:enum abstract DTMonth (Int) to Int from Int {
    var January   = 1;
    var February  = 2;
    var March     = 3;
    var April     = 4;
    var May       = 5;
    var June      = 6;
    var July      = 7;
    var August    = 8;
    var September = 9;
    var October   = 10;
    var November  = 11;
    var December  = 12;
}//enum DTMonth


/**
* Snap directions for date/time snapping. See DateTime.snap()
*
*/
@:enum abstract DTSnapDirection (Int) {
    var Up = 1;
    var Down = -1;
    var Nearest = 0;
}//enum DTSnapDirection


/**
* Time periods for date/time snapping. See DateTime.snap()
*
*/
enum DTSnap {

    Year (direction:DTSnapDirection);
    Month (direction:DTSnapDirection);
    Day (direction:DTSnapDirection);
    Hour (direction:DTSnapDirection);
    Minute (direction:DTSnapDirection);
    Second (direction:DTSnapDirection);

    Week (direction:DTSnapDirection, day:DTWeekDay);

}//enum DTSnap



/**
* DateTime implementation based on amount of seconds since unix epoch.
* By default all date/time data returned is in UTC.
*
*/
@:access(datetime)
@:allow(datetime)
abstract DateTime (Float) {
    /** Difference bitween unix epoch and internal number of seconds */
    static private inline var UNIX_EPOCH_DIFF = 62135596800.0;//62136892800.0;

    static public inline var SECONDS_IN_MINUTE    = 60;
    static public inline var SECONDS_IN_HOUR      = 3600;
    static public inline var SECONDS_IN_DAY       = 86400;
    static public inline var SECONDS_IN_WEEK      = 604800;
    static public inline var SECONDS_IN_YEAR      = 31536000;
    static public inline var SECONDS_IN_LEAP_YEAR = 31622400;
    /** 3 normal years */
    static private inline var SECONDS_IN_3_YEARS = 94608000;
    /** Amount of seconds in 4 years (3 normal years + 1 leap year) */
    static private inline var SECONDS_IN_QUAD = 126230400.0;
    /** normal year + normal year */
    static private inline var SECONDS_IN_HALF_QUAD = 63072000.0;
    /** normal year + leap year */
    static private inline var SECONDS_IN_HALF_QUAD_LEAP = 63158400.0;
    /** normal year + normal year + leap year */
    static private inline var SECONDS_IN_3_PART_QUAD = 94694400.0;
    /** 4 centuries, where the last century is leap (last year is leap), while others are not */
    static private inline var SECONDS_IN_CQUAD = 12622780800.0;
    /** seconds in century, where the last (xx00-year) is not leap */
    static private inline var SECONDS_IN_CENTURY = 3155673600.0;
    /** seconds in century, where the last (xx00-year) is leap */
    static private inline var SECONDS_IN_LEAP_CENTURY = 3155760000.0;


    /**
    * Get current UTC date&time
    *
    */
    static public inline function now () : DateTime {
        return new DateTime(
            #if cpp
                untyped __global__.__hxcpp_date_now()
            #elseif js
                untyped __js__("Math.floor(new Date().getTime() / 1000)")
            #elseif php
                untyped __php__("time()")
            #elseif neko
                untyped Date.date_now()
            #elseif java
                Math.ffloor(untyped __java__("System.currentTimeMillis()/1000"))
            #elseif cs
                Math.ffloor(cast (cs.system.DateTime.Now.ToUniversalTime().Ticks - 621355968000000000.0) / 10000000)
            #else
                Math.ffloor(Date.now().getTime() / 1000)
            #end
        );
    }//function now()


    /**
    * Get current local date&time.
    *
    * Returns user's local date/time.
    */
    static public function local () : DateTime {
        var utc = now();
        return utc.getTime() + getLocalOffset();
    }//function local()


    /**
    * Build DateTime using specified components
    *
    * Builds UTC time.
    *
    * @param year
    * @param month  - 1-12
    * @param day    - 1-31
    * @param hour   - 0-23
    * @param minute - 0-59
    * @param second - 0-59
    */
    static public inline function make (year:Int = 1970, month:Int = 1, day:Int = 1, hour:Int = 0, minute:Int = 0, second:Int = 0) : DateTime {
        return DateTimeUtils.yearToStamp(year)
                + month.toSeconds(isLeap(year))
                + (day - 1) * SECONDS_IN_DAY
                + hour * SECONDS_IN_HOUR
                + minute * SECONDS_IN_MINUTE
                + second
                - UNIX_EPOCH_DIFF;
    }//function make()


    /**
    * Make DateTime from unix timestamp (amount of seconds)
    *
    * Returns UTC time.
    */
    @:from
    static public inline function fromTime (time:Float) : DateTime {
        return new DateTime(time);
    }//function fromTime()


    /**
    * Convert 'YYYY-MM-DD hh:mm:ss' or 'YYYY-MM-DD' or 'YYYY-MM-DDThh:mm:ss[.SSS]Z' to DateTime
    *
    * Assumes provided string represents UTC time.
    *
    * Returns UTC time.
    *
    * @throws String - if provided string is not in correct format
    */
    @:from
    static public inline function fromString (str:String) : DateTime {
        return DateTimeUtils.fromString(str);
    }//function fromString()


    /**
    * Make DateTime instance using unix timestamp retreived from `date`
    *
    * Returns UTC time.
    */
    @:from
    static public inline function fromDate (date:Date) : DateTime {
        return Math.ffloor(date.getTime() / 1000);
    }//function fromDate()


    /**
    * Get amount of days in specified `month` (1-12). If `month` is 2 (February), you need to
    * specify whether you want to get amount of days in leap year or not.
    */
    static public inline function daysInMonth (month:Int, isLeapYear:Bool = false) : Int {
        return month.days(isLeapYear);
    }//function daysInMonth()


    /**
    * Get amount of weeks in `year` (52 or 53)
    *
    */
    static public function weeksInYear (year:Int) : Int {
        var start   : DateTime = year.yearToStamp() - UNIX_EPOCH_DIFF;
        var weekDay : Int = start.getWeekDay();

        if (weekDay == 4 || (weekDay == 3 && start.isLeapYear()) ) {
            return 53;
        } else {
            return 52;
        }
    }//function weeksInYear()


    /**
    * Check if specified `year` is a leap year
    *
    */
    static public inline function isLeap (year:Int) : Bool {
        return (
            year % 4 == 0
                ? (year % 100 == 0 ? year % 400 == 0 : true)
                : false
        );
    }//function isLeap()


    /**
    * Get current local time offset (in seconds) relative to UTC time.
    *
    */
    static public function getLocalOffset () : Int {
        var now   = Date.now();
        var local = make(now.getFullYear(), now.getMonth() + 1, now.getDate(), now.getHours(), now.getMinutes(), now.getSeconds());

        return Std.int(local.getTime() - Std.int(now.getTime() / 1000));
    }//function getLocalOffset()


    /**
    * Constructor
    *
    * @param time - unix timestamp (amount of seconds since `1970-01-01 00:00:00`)
    */
    public inline function new (time:Float) : Void {
        this = time + UNIX_EPOCH_DIFF;
    }//function new()


    /**
    * Assuming this instance is your local time, convert it ot UTC using current
    * time offset of your timezone.
    *
    * Does not use your timezone data, just current time offset.
    *
    * If you dont care about your timezone and just need to convert your local time to utc,
    * use this method instead of `Timezone` class.
    *
    * Returns new DateTime instance
    */
    public function utc () : DateTime {
        return getTime() - getLocalOffset();
    }//function utc()


    /**
    * Get year number (4 digits)
    *
    */
    public function getYear () : Int {
        var cquads    = Std.int(this / SECONDS_IN_CQUAD) * SECONDS_IN_CQUAD;
        var centuries = Std.int((this - cquads) / SECONDS_IN_CENTURY) * SECONDS_IN_CENTURY;
        if (centuries > 3 * SECONDS_IN_CENTURY) {
            centuries -= SECONDS_IN_CENTURY;
        }
        var quads = Std.int((this - cquads - centuries) / SECONDS_IN_QUAD) * SECONDS_IN_QUAD;
        var years : Int = Std.int((this - cquads - centuries - quads) / SECONDS_IN_YEAR);

        return
              Std.int(cquads / SECONDS_IN_CQUAD) * 400
            + Std.int(centuries / SECONDS_IN_CENTURY) * 100
            + Std.int(quads / SECONDS_IN_QUAD) * 4
            + (years == 4 ? years : years + 1);
    }//function getYear()


    /**
    * Get unix timestamp of a first second of this year
    *
    */
    private function yearStart () : Float {
        var cquads    = Std.int(this / SECONDS_IN_CQUAD) * SECONDS_IN_CQUAD;
        var centuries = Std.int((this - cquads) / SECONDS_IN_CENTURY) * SECONDS_IN_CENTURY;
        if (centuries > 3 * SECONDS_IN_CENTURY) {
            centuries -= SECONDS_IN_CENTURY;
        }
        var quads = Std.int((this - cquads - centuries) / SECONDS_IN_QUAD) * SECONDS_IN_QUAD;

        var years : Int = Std.int((this - cquads - centuries - quads) / SECONDS_IN_YEAR);
        if (years == 4) {
            years --;
        }

        return cquads + centuries + quads + years * SECONDS_IN_YEAR - UNIX_EPOCH_DIFF;
    }//function yearStart()


    /**
    * Get unix timestamp of the first second for specified `month` in this year (1-12)
    *
    * If `month` == 0, returns timestamp of current month of this DateTime instance.
    *
    */
    private function monthStart (month:Int = 0) : Float {
        if (month == 0) month = getMonth();
        return yearStart() + month.toSeconds(isLeapYear());
    }//function monthStart()


    /**
    * Get date/time of the first second of specified `month`.
    *
    */
    public inline function getMonthStart (month:DTMonth) : DateTime {
        return monthStart(month);
    }//function getMonthStart()


    /**
    * Check if this is leap year
    *
    */
    public function isLeapYear () : Bool {
        return isLeap(getYear());
    }//function isLeapYear()


    /**
    * Get month number (1-12)
    *
    */
    public inline function getMonth () : Int {
        var days : Int = Std.int( (getTime() - yearStart()) / SECONDS_IN_DAY ) + 1;
        return days.getMonth( isLeapYear() );
    }//function getMonth()


    /**
    * Get day number (1-31)
    *
    */
    public inline function getDay () : Int {
        var days : Int = Std.int( (getTime() - yearStart()) / SECONDS_IN_DAY ) + 1;
        return days.getMonthDay( isLeapYear() );
    }//function getDay()


    /**
    * Return amount of days in current month
    *
    */
    public inline function daysInThisMonth () : Int {
        var month : Int = getMonth();
        return month.days( month == 2 && isLeapYear() );
    }//function daysInThisMonth()


    /**
    * Get day number within a year (1-366)
    *
    */
    public inline function getYearDay () : Int {
        return Std.int( (getTime() - yearStart()) / SECONDS_IN_DAY ) + 1;
    }//function getYearDay()


    /**
    * Get amount of weeks in this year (52 or 53)
    *
    */
    public function weeksInThisYear () : Int {
        return weeksInYear( getYear() );
    }//function weeksInThisYear()


    /**
    * Get day of the week.
    *
    * Returns 0-6 (Sunday-Saturday) by default.
    *
    * Returns 1-7 (Monday-Sunday) if `mondayBased` = true
    *
    */
    public function getWeekDay (mondayBased:Bool = false) : Int {
        var month : Int = getMonth();
        var a : Int = Std.int((14 - month) / 12);
        var y : Int = getYear() - a;
        var m : Int = month + 12 * a - 2;

        var weekDay : Int = (7000 + (getDay() + y + Std.int(y / 4) - Std.int(y / 100) + Std.int(y / 400) + Std.int(31 * m / 12))) % 7;

        return (mondayBased && weekDay == 0 ? 7 : weekDay);
    }//function getWeekDay()


    /**
    * Get DateTime of a specified `weekDay` in this month, which is the `num`st in current month.
    *
    *   E.g. get DateTime of the second Sunday in current month.
    *   If `num` is negative, then required `weekDay` will be searched from the end of this month.
    *   If `num` == 0, returns a copy of this DateTime instance
    */
    public inline function getWeekDayNum (weekDay:DTWeekDay, num:Int = 1) : DateTime {
        return new DateTime( DateTimeUtils.getWeekDayNum(getTime(), weekDay, num) );
    }//function getWeekDayNum()


    /**
    * Get current week number within a year according to the ISO 8601 date and time standard
    *
    */
    public function getWeek () : Int {
        var week : Int = Std.int((getYearDay() - getWeekDay(true) + 10) / 7);
        var year : Int = getYear();

        return (
            week < 1
                ? weeksInYear(year - 1)
                : (week > 52 && week > weeksInYear(year) ? 1 : week)
        );
    }//function getWeek()


    /**
    * Get hour number (0-23)
    *
    */
    public inline function getHour () : Int {
        return Std.int((this - Math.ffloor(this / SECONDS_IN_DAY) * SECONDS_IN_DAY) / SECONDS_IN_HOUR);
    }//function getHour()


    /**
    * Get hour number in 12-hour-clock
    *
    */
    public function getHour12 () : Int {
        var hour = getHour();
        if (hour == 0) {
            return 12;
        } else if (hour > 12) {
            return hour - 12;
        } else {
            return hour;
        }
    }//function getHour12()


    /**
    * Get minumte number (0-59)
    *
    */
    public inline function getMinute () : Int {
        return Std.int((this - Math.ffloor(this / SECONDS_IN_HOUR) * SECONDS_IN_HOUR) / SECONDS_IN_MINUTE);
    }//function getMinute()


    /**
    * Get second number (0-59)
    *
    */
    public inline function getSecond () : Int {
        return Std.int(this - Math.ffloor(this / SECONDS_IN_MINUTE) * SECONDS_IN_MINUTE);
    }//function getSecond()


    /**
    * Add time period to this timestamp.
    * Returns new DateTime.
    */
    public function add (period:DTPeriod) : DateTime {
        return new DateTime(
            switch (period) {
                case Year(n)   : DateTimeUtils.addYear(getTime(), n);
                case Month(n)  : DateTimeUtils.addMonth(getTime(), n);
                case Day(n)    : getTime() + n * SECONDS_IN_DAY;
                case Hour(n)   : getTime() + n * SECONDS_IN_HOUR;
                case Minute(n) : getTime() + n * SECONDS_IN_MINUTE;
                case Second(n) : getTime() + n;
                case Week(n)   : getTime() + n * 7 * SECONDS_IN_DAY;
            }
        );
    }//function add()


    /**
    * Substruct time period from this timestamp.
    * This method is used for operator overloading.
    */
    private function sub (period:DTPeriod) : DateTime {
        return new DateTime(
            switch (period) {
                case Year(n)   : DateTimeUtils.addYear(getTime(), -n);
                case Month(n)  : DateTimeUtils.addMonth(getTime(), -n);
                case Day(n)    : getTime() - n * SECONDS_IN_DAY;
                case Hour(n)   : getTime() - n * SECONDS_IN_HOUR;
                case Minute(n) : getTime() - n * SECONDS_IN_MINUTE;
                case Second(n) : getTime() - n;
                case Week(n)   : getTime() - n * 7 * SECONDS_IN_DAY;
            }
        );
    }//function sub()


    /**
    * Snap to nearest year, month, day, hour, minute, second or week.
    * Returns new DateTime.
    */
    public function snap (period:DTSnap) : DateTime {
        return new DateTime(
            switch (period) {
                case Year(d)      : DateTimeSnapUtils.snapYear(getTime(), d);
                case Month(d)     : DateTimeSnapUtils.snapMonth(getTime(), d);
                case Day(d)       : DateTimeSnapUtils.snapDay(getTime(), d);
                case Hour(d)      : DateTimeSnapUtils.snapHour(getTime(), d);
                case Minute(d)    : DateTimeSnapUtils.snapMinute(getTime(), d);
                case Second(d)    : (d == Up ? getTime() + 1 : getTime());
                case Week(d, day) : DateTimeSnapUtils.snapWeek(getTime(), d, day);
            }
        );
    }//function snap()


    /**
    * Convert to string representation in format YYYY-MM-DD HH:MM:SS
    *
    */
    public function toString () : String {
        var Y = getYear();
        var M = getMonth();
        var D = getDay();
        var h = getHour();
        var m = getMinute();
        var s = getSecond();

        return '$Y-' + (M < 10 ? '0$M' : '$M') + '-' + (D < 10 ? '0$D' : '$D') + ' ' + (h < 10 ? '0$h' : '$h') + ':' + (m < 10 ? '0$m' : '$m') + ':' + (s < 10 ? '0$s' : '$s');
    }//function toString()


    /**
    * Format this timestamp according to `format`
    *
    * Day
    *
    *   - `%d`  Two-digit day of the month (with leading zeros) 01 to 31
    *   - `%e`  Day of the month, with a space preceding single digits. 1 to 31
    *   - `%j`  Day of the year, 3 digits with leading zeros    001 to 366
    *   - `%u`  ISO-8601 numeric representation of the day of the week  1 (for Monday) though 7 (for Sunday)
    *   - `%w`  Numeric representation of the day of the week   0 (for Sunday) through 6 (for Saturday)
    *
    * Month
    *
    *   - `%m`  Two digit representation of the month   01 (for January) through 12 (for December)
    *
    * Year
    *
    *   - `%C`  Two digit representation of the century (year divided by 100, truncated to an integer)  19 for the 20th Century
    *   - `%y`  Two digit representation of the year    Example: 09 for 2009, 79 for 1979
    *   - `%Y`  Four digit representation for the year  Example: 2038
    *
    * Week
    *
    *   - `%V`  ISO-8601:1988 week number of the given year, starting with the first week of the year with at least 4 weekdays,
    *   -     with Monday being the start of the week 01 through 53
    *
    * Time
    *
    *   - `%H`  Two digit representation of the hour in 24-hour format  00 through 23
    *   - `%k`  Two digit representation of the hour in 24-hour format, with a space preceding single digits    0 through 23
    *   - `%I`  Two digit representation of the hour in 12-hour format  01 through 12
    *   - `%l`  (lower-case 'L') Hour in 12-hour format, with a space preceding single digits    1 through 12
    *   - `%M`  Two digit representation of the minute  00 through 59
    *   - `%p`  upper-case 'AM' or 'PM' based on the given time Example: AM for 00:31, PM for 22:23
    *   - `%P`  lower-case 'am' or 'pm' based on the given time Example: am for 00:31, pm for 22:23
    *   - `%r`  Same as "%I:%M:%S %p"   Example: 09:34:17 PM for 21:34:17
    *   - `%R`  Same as "%H:%M" Example: 00:35 for 12:35 AM, 16:44 for 4:44 PM
    *   - `%S`  Two digit representation of the second  00 through 59
    *   - `%T`  Same as "%H:%M:%S"  Example: 21:34:17 for 09:34:17 PM
    *
    * Time and Date Stamps
    *
    *   - `%D`  Same as "%m/%d/%y"  Example: 02/05/09 for February 5, 2009
    *   - `%F`  Same as "%Y-%m-%d" (commonly used in database datestamps)   Example: 2009-02-05 for February 5, 2009
    *   - `%s`  Unix Epoch Time timestamp Example: 305815200 for September 10, 1979 08:40:00 AM
    *
    * Miscellaneous
    *
    *   - `%%`  A literal percentage character ("%")
    */
    public function format (format:String) : String {
        return DateTimeUtils.strftime(getTime(), format);
    }//function format()


    /**
    * Get unix timestamp (amount of seconds)
    *
    */
    @:to
    public inline function getTime () : Float {
        return this - UNIX_EPOCH_DIFF;
    }//function toFloat()


    /**
    * Create standart `Date` class instance using unix timestamp of this one
    *
    */
    @:to
    public inline function getDate () : Date {
        return Date.fromTime(getTime() * 1000);
    }//function getDate()


    /**
    * DateTime comparison
    *
    */
    @:op(A > B)  private inline function gt (dt:DateTime)  : Bool return getTime() > dt.getTime();
    @:op(A >= B) private inline function gte (dt:DateTime) : Bool return getTime() >= dt.getTime();
    @:op(A < B)  private inline function lt (dt:DateTime)  : Bool return getTime() < dt.getTime();
    @:op(A <= B) private inline function lte (dt:DateTime) : Bool return getTime() <= dt.getTime();
    @:op(A == B) private inline function eq (dt:DateTime)  : Bool return getTime() == dt.getTime();
    @:op(A != B) private inline function neq (dt:DateTime) : Bool return getTime() != dt.getTime();


    /**
    * Operator overloading for simple writing `.add()` method
    *
    */
    @:op(A + B)  private inline function mathPlus1 (period:DTPeriod) : DateTime return add(period);
    @:op(B + A)  private inline function mathPlus2 (period:DTPeriod) : DateTime return add(period);
    @:op(A += B) private inline function mathPlus3 (period:DTPeriod) : DateTime return this = add(period).getTime() + UNIX_EPOCH_DIFF;
    @:op(A - B)  private inline function mathMinus1 (period:DTPeriod) : DateTime return sub(period);
    @:op(A += B) private inline function mathMinus2 (period:DTPeriod) : DateTime return this = sub(period).getTime() + UNIX_EPOCH_DIFF;


    /**
    * Operator overloading for simple usage of DateTimeInterval
    *
    */
    @:op(A - B)  private inline function dtiCreate (begin:DateTime)      : DateTimeInterval return DateTimeInterval.create(begin, getTime());
    @:op(A - B)  private inline function dtiMinus (dti:DateTimeInterval) : DateTime return dti.subFrom(getTime());
    @:op(A + B)  private inline function dtiPlus1 (dti:DateTimeInterval) : DateTime return dti.addTo(getTime());
    @:op(B + A)  private inline function dtiPlus2 (dti:DateTimeInterval) : DateTime return dti.addTo(getTime());
    @:op(A -= B) private inline function dtiMinus2 (dti:DateTimeInterval) : DateTime return this = dti.subFrom(getTime()).getTime() + UNIX_EPOCH_DIFF;
    @:op(A += B) private inline function dtiPlus3 (dti:DateTimeInterval) : DateTime return this = dti.addTo(getTime()).getTime() + UNIX_EPOCH_DIFF;


}//abstract DateTime
