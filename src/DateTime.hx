package ;


using DateTimeUtils;
using StringTools;


/**
* DateTime implementation based on amount of seconds since unix epoch.
* Does nothing with time zones.
*
*/
abstract DateTime (Float) from Float to Float {
    /** Amount of seconds in one minute */
    static public inline var SECONDS_IN_MINUTE = 60;
    /** Amount of seconds in one hour */
    static public inline var SECONDS_IN_HOUR = 3600;
    /** Seconds per day */
    static public inline var SECONDS_IN_DAY = 86400;
    /** Amount of sconds in year */
    static public inline var SECONDS_IN_YEAR           = 31536000;
    static public inline var SECONDS_IN_LEAP_YEAR      = 31622400;
    static public inline var SECONDS_IN_QUAD           = 126230400;
    static public inline var SECONDS_IN_HALF_QUAD      = 63072000; //normal year + normal year
    static public inline var SECONDS_IN_3_PART_QUAD    = 94694400; //normal year + normal year + leap year
    static public inline var SECONDS_IN_HALF_QUAD_LEAP = 63158400; //normal year + leap year


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

        if (year == null || month == null || day == null || hour == null || minute == null || second == null ) {
            throw '`$str` - incorrect date/time format. Should be either `YYYY-MM-DD hh:mm:ss` or `YYYY-MM-DD`';
        }

        var stamp : Float = DateTimeUtils.yearToStamp(year)
                            + DateTimeUtils.monthToSeconds(month, (year % 4 == 0))
                            + (day - 1) * SECONDS_IN_DAY
                            + hour * SECONDS_IN_HOUR
                            + minute * SECONDS_IN_MINUTE
                            + second;

        return stamp;
    }//function fromString()


    /**
    * Constructor
    *
    */
    public inline function new (stamp:Float) : Void {
        this = stamp;
    }//function new()


    /**
    * Get year number since 1970 (starting from 0 as 1970)
    *
    */
    public function getUnixYear () : Int {
        var quad : Int   = Std.int(this / SECONDS_IN_QUAD);
        var left : Float = this.sign() * (this - 1.0 * quad * SECONDS_IN_QUAD);

        //before unix epoch
        if (this < 0) {
            return quad * 4 - (
                left == 0
                    ?  0
                    : (
                        left <= SECONDS_IN_YEAR
                            ? 1
                            : (
                                left <= SECONDS_IN_HALF_QUAD_LEAP
                                    ? 2
                                    : (left <= SECONDS_IN_3_PART_QUAD ? 3 : 4)
                            )
                    )
            );
        //after unix epoch
        } else {
            return quad * 4 + (
                left < SECONDS_IN_YEAR
                    ? 0
                    : (
                        left < SECONDS_IN_HALF_QUAD
                            ? 1
                            : (left < SECONDS_IN_3_PART_QUAD ? 2 : 3)
                    )
            );
        }
    }//function getUnixYear()


    /**
    * Get year number (4 digits)
    *
    */
    public inline function getYear () : Int {
        return 1970 + getUnixYear();
    }//function getYear()


    /**
    * Get timestamp of a first second of this year
    *
    */
    public function yearStart () : Float {
        var year      : Int = getUnixYear();
        var leapYears : Int = Std.int((this < 0 ? 2 - year  : year + 1) / 4);

        return 1.0 * year * SECONDS_IN_YEAR + 1.0 * sign() * leapYears * SECONDS_IN_DAY;
    }//function yearStart()


    /**
    * Check if this is leap year
    *
    */
    public inline function isLeapYear () : Bool {
        return (getYear() % 4 == 0);
    }//function isLeapYear()


    /**
    * Get month number (1-12)
    *
    */
    public inline function getMonth () : Int {
        return DateTimeUtils.getMonth(
            Std.int( (this - yearStart()) / SECONDS_IN_DAY ) + 1,
            isLeapYear()
        );
    }//function getMonth()


    /**
    * Get day number (1-31)
    *
    */
    public inline function getDay () : Int {
        return return DateTimeUtils.getDay(
            Std.int( (this - yearStart()) / SECONDS_IN_DAY ) + 1,
            isLeapYear()
        );
    }//function getDay()


    /**
    * Get hour number (0-23)
    *
    */
    public inline function getHour () : Int {
        var days : Float = Math.ffloor(this / SECONDS_IN_DAY);
        return Std.int((this - days * SECONDS_IN_DAY) / SECONDS_IN_HOUR);
    }//function getHour()


    /**
    * Get minumte number (0-59)
    *
    */
    public inline function getMinute () : Int {
        var hours : Float = Math.ffloor(this / SECONDS_IN_HOUR);
        return Std.int((this - hours * SECONDS_IN_HOUR) / SECONDS_IN_MINUTE);
    }//function getMinute()


    /**
    * Get second number (0-59)
    *
    */
    public inline function getSecond () : Int {
        var minutes : Float = Math.ffloor(this / SECONDS_IN_MINUTE);
        return Std.int(this - minutes * SECONDS_IN_MINUTE);
    }//function getSecond()


    /**
    * Add time period to this timestamp.
    * Returns new DateTime.
    */
    public function add (period:EDateTime) : DateTime {
        return switch (period) {
            case Year(n)   : this.addYear(n);
            case Month(n)  : this.addMonth(n);
            case Day(n)    : this + n * SECONDS_IN_DAY;
            case Hour(n)   : this + n * SECONDS_IN_HOUR;
            case Minute(n) : this + n * SECONDS_IN_MINUTE;
            case Second(n) : this + n;
            case Week(n)   : this + n * 7 * SECONDS_IN_DAY;
        }
    }//function add()


    /**
    * Convert to string representation in format YYYY-MM-DD HH:MM:SS
    *
    */
    public inline function toString () : String {
        var Y = getYear();
        var M = getMonth();
        var D = getDay();
        var h = getHour();
        var m = getMinute();
        var s = getSecond();

        return '$Y-' + (M < 10 ? '0$M' : '$M') + '-' + (D < 10 ? '0$D' : '$D') + ' ' + (h < 10 ? '0$h' : '$h') + ':' + (m < 10 ? '0$m' : '$m') + ':' + (s < 10 ? '0$s' : '$s');
    }//function toString()


    /**
    * To use in expressions with Int
    *
    */
    @:op(A + B) private inline function int1 (b:Int) : Float return this + b;
    @:op(A - B) private inline function int2 (b:Int) : Float return this - b;
    @:op(B + A) private inline function int3 (b:Int) : Float return this + b;
    @:op(B - A) private inline function int4 (b:Int) : Float return b - this;
    @:op(A + B) private inline function float1 (b:Float) : Float return this + b;
    @:op(A - B) private inline function float2 (b:Float) : Float return this - b;
    @:op(B + A) private inline function float3 (b:Float) : Float return this + b;
    @:op(B - A) private inline function float4 (b:Float) : Float return b - this;

}//abstract DateTime