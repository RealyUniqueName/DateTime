package ;

using StringTools;


/**
* DateTime implementation based on amount of seconds since unix epoch.
* Does nothing with time zones.
*
*/
abstract DateTime (Float) {
    /** Difference bitween unix epoch and internal number of seconds */
    static public inline var UNIX_EPOCH_DIFF = 62136892800.0;

    static public inline var SECONDS_IN_MINUTE    = 60;
    static public inline var SECONDS_IN_HOUR      = 3600;
    static public inline var SECONDS_IN_DAY       = 86400;
    static public inline var SECONDS_IN_WEEK      = 604800;
    static public inline var SECONDS_IN_YEAR      = 31536000;
    static public inline var SECONDS_IN_LEAP_YEAR = 31622400;
    /** 3 normal years */
    static public inline var SECONDS_IN_3_YEARS = 94608000;
    /** Amount of seconds in 4 years (3 normal years + 1 leap year) */
    static public inline var SECONDS_IN_QUAD = 126230400.0;
    /** normal year + normal year */
    static public inline var SECONDS_IN_HALF_QUAD = 63072000.0;
    /** normal year + leap year */
    static public inline var SECONDS_IN_HALF_QUAD_LEAP = 63158400.0;
    /** normal year + normal year + leap year */
    static public inline var SECONDS_IN_3_PART_QUAD = 94694400.0;


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
            // #elseif cs
            //     Math.ffloor((cs.system.DateTime.Now.ToUniversalTime().Ticks - 621355968000000000.0) / 10000000)
            #else
                Math.ffloor(Date.now().getTime() / 1000)
            #end
        );
    }//function now()


    /**
    * Build DateTime using specified components
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
                + DateTimeUtils.monthToSeconds(month, (year % 4 == 0))
                + (day - 1) * SECONDS_IN_DAY
                + hour * SECONDS_IN_HOUR
                + minute * SECONDS_IN_MINUTE
                + second
                - UNIX_EPOCH_DIFF;
    }//function make()


    /**
    * Make DateTime from unix timestamp (amount of seconds)
    *
    */
    @:from
    static public inline function fromTime (time:Float) : DateTime {
        return new DateTime(time);
    }//function fromTime()


    /**
    * Convert 'YYYY-MM-DD hh:mm:ss' or 'YYYY-MM-DD' to DateTime
    *
    * @throws String - if provided string is not in correct format
    */
    static public function fromString (str:String) : DateTime {
        var ylength : Int = str.indexOf('-');

        if (ylength == -1 || (str.length - ylength != 6 && str.length - ylength != 15)) {
            throw '`$str` - incorrect date/time format. Should be either `YYYY-MM-DD hh:mm:ss` or `YYYY-MM-DD`';
        }

        if (str.length - ylength == 6) {
            str += ' 00:00:00';
        }

        // YYYY-MM-DD hh:mm:ss
        var year    : Null<Int> = Std.parseInt(str.substr(0, ylength));
        var month   : Null<Int> = Std.parseInt(str.substr(ylength + 1, 2));
        var day     : Null<Int> = Std.parseInt(str.substr(ylength + 4, 2));
        var hour    : Null<Int> = Std.parseInt(str.substr(ylength + 7, 2));
        var minute  : Null<Int> = Std.parseInt(str.substr(ylength + 10, 2));
        var second  : Null<Int> = Std.parseInt(str.substr(ylength + 13, 2));

        if (year == null || month == null || day == null || hour == null || minute == null || second == null) {
            throw '`$str` - incorrect date/time format. Should be either `YYYY-MM-DD hh:mm:ss` or `YYYY-MM-DD`';
        }

        return make(year, month, day, hour, minute, second);
    }//function fromString()


    /**
    * Constructor
    *
    * @param time - unix timestamp (amount of seconds since `1970-01-01 00:00:00`)
    */
    public inline function new (time:Float) : Void {
        this = time + UNIX_EPOCH_DIFF;
    }//function new()


    /**
    * Get year number (4 digits)
    *
    */
    public function getYear () : Int {
        var quad  : Int = Std.int(this / SECONDS_IN_QUAD);
        var years : Int = Std.int((this - quad * SECONDS_IN_QUAD) / SECONDS_IN_YEAR);

        return quad * 4 + (years == 4 ? years : years + 1);
    }//function getYear()


    /**
    * Get unix timestamp of a first second of this year
    *
    */
    public function yearStart () : Float {
        var quad  : Float = Std.int(this / SECONDS_IN_QUAD) * SECONDS_IN_QUAD;
        var years : Int   = Std.int((this - quad) / SECONDS_IN_YEAR);
        if (years == 4) {
            years --;
        }

        return quad + years * SECONDS_IN_YEAR - UNIX_EPOCH_DIFF;
    }//function yearStart()


    /**
    * Check if this is leap year
    *
    */
    public inline function isLeapYear () : Bool {
        return (this - Std.int(this / SECONDS_IN_QUAD) * SECONDS_IN_QUAD) > SECONDS_IN_3_YEARS - 1;
    }//function isLeapYear()


    /**
    * Get month number (1-12)
    *
    */
    public inline function getMonth () : Int {
        return DateTimeUtils.getMonth(
            Std.int( (this - yearStart() - UNIX_EPOCH_DIFF) / SECONDS_IN_DAY ) + 1,
            isLeapYear()
        );
    }//function getMonth()


    /**
    * Get day number (1-31)
    *
    */
    public inline function getDay () : Int {
        return return DateTimeUtils.getDay(
            Std.int( (this - yearStart() - UNIX_EPOCH_DIFF) / SECONDS_IN_DAY ) + 1,
            isLeapYear()
        );
    }//function getDay()


    /**
    * Get day of the week.
    * Returns 0-6 (Sunday-Saturday) by default.
    * Returns 1-7 (Monday-Sunday) if `mondayBased` = true
    *
    */
    public function getWeekDay (mondayBased:Bool = false) : Int {
        var month : Int = getMonth();
        var a : Int = Std.int((14 - month) / 12);
        var y : Int = getYear() - a;
        var m : Int = month + 12 * a - 2;

        var weekDay : Int = (7000 + (getDay() + y + Std.int(y / 4) - Std.int(y / 100) + Std.int(y / 400) + Std.int(31 * m / 12))) % 7;

        return (mondayBased ? weekDay + 1 : weekDay);
    }//function getWeekDay()


    /**
    * Get hour number (0-23)
    *
    */
    public inline function getHour () : Int {
        return Std.int((this - Math.ffloor(this / SECONDS_IN_DAY) * SECONDS_IN_DAY) / SECONDS_IN_HOUR);
    }//function getHour()


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
    public function add (period:EDateTime) : DateTime {
        return new DateTime(
            switch (period) {
                case Year(n)   : DateTimeUtils.addYear(this - UNIX_EPOCH_DIFF, n);
                case Month(n)  : DateTimeUtils.addMonth(this - UNIX_EPOCH_DIFF, n);
                case Day(n)    : this + n * SECONDS_IN_DAY - UNIX_EPOCH_DIFF;
                case Hour(n)   : this + n * SECONDS_IN_HOUR - UNIX_EPOCH_DIFF;
                case Minute(n) : this + n * SECONDS_IN_MINUTE - UNIX_EPOCH_DIFF;
                case Second(n) : this + n - UNIX_EPOCH_DIFF;
                case Week(n)   : this + n * 7 * SECONDS_IN_DAY - UNIX_EPOCH_DIFF;
            }
        );
    }//function add()


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
    * Get unix timestamp (amount of seconds)
    *
    */
    @:to
    public inline function getTime () : Float {
        return this - UNIX_EPOCH_DIFF;
    }//function toFloat()


    /**
    * To convert from/to different types
    *
    */
    @from static private inline function _fromInt (time:Int) : DateTime return time + UNIX_EPOCH_DIFF;
    // @to private inline function _toDynamic () : Dynamic return this - UNIX_EPOCH_DIFF;

}//abstract DateTime