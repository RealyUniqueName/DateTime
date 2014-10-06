package datetime;

import datetime.data.TimezoneData;
import datetime.DateTime;
import datetime.utils.TimezoneDetect;
import datetime.utils.TimezoneUtils;



/**
* Timezone data.
*
*/
abstract Timezone (TimezoneData) from TimezoneData to TimezoneData {
    /** cache for local timezone */
    static private var _local : TimezoneData = null;


    /**
    * Get local timezone on current machine
    *
    */
    static public function local () : Timezone {
        if (Timezone._local == null) {
            Timezone._local = TimezoneData.get( TimezoneDetect.detect() );
        }

        return Timezone._local;
    }//function local()


    /**
    * Get timezone by IANA timezone name
    *
    */
    @:from
    static public inline function get (name:String) : Timezone {
        return TimezoneData.get(name);
    }//function get()


    /**
    * Constructor
    *
    */
    private inline function new (tz:TimezoneData) : Void {
        this = tz;
    }//function new()


    /**
    * Get timezone name
    *
    */
    public inline function getName () : String {
        return this.name;
    }//function getName()


    /**
    * Find out what was the date/time at specified UTC time in this timezone
    *
    * E.g.
    *
    *   `var utc = DateTime.fromString('2012-01-01 00:00:00');`
    *
    *   `var tz = Timezone.get('Europe/Moscow');`
    *
    *   `tz.at(utc).toString();  // 2012-01-01 04:00:00`
    */
    public inline function at (utc:DateTime) : DateTime {
        return utc.getTime() + this.getPeriodFor(utc).offset;
    }//function at()


    /**
    * Check if Daylight Saving time is in effect in this zone at `utc` time
    *
    */
    public inline function isDst (utc:DateTime) : Bool {
        return this.getPeriodFor(utc).isDst;
    }//function isDst()


    /**
    * Get timezone abbreviation at specified moment. E.g. EST for Eastern Standart Time
    *
    */
    public inline function getAbbreviation (utc:DateTime) : String {
        return this.getPeriodFor(utc).abr;
    }//function getAbbreviation()


    /**
    * Get time offset relative to UTC time at specified moment.
    *   Returns amount of seconds.
    */
    public inline function getOffset (utc:DateTime) : Int {
        return this.getPeriodFor(utc).offset;
    }//function getOffset()


    /**
    * Get time offset relative to UTC time at specified moment in HHMM format.
    *
    */
    public inline function getHHMM (utc:DateTime) : Int {
        var offset : Int = this.getPeriodFor(utc).offset;
        var hours  : Int = Std.int(offset / DateTime.SECONDS_IN_HOUR);

        return hours * 100 + Std.int((offset - hours * DateTime.SECONDS_IN_HOUR) / DateTime.SECONDS_IN_MINUTE);
    }//function getHHMM()


    /**
    * Make a string according to `format`.
    *
    *   - `%z`  The time zone offset. Example: -0500 for US Eastern Time
    *   - `%Z`  The time zone abbreviation. Example: EST for Eastern Standart Time
    *   - `%q`  ISO8691 date/time format. Example: 2014-10-04T19:42:56+00:00
    *
    * After timezone placeholders in `format` are processed `at(utc).format(format)` is called.
    */
    public inline function format (utc:DateTime, format:String) : String {
        return TimezoneUtils.format(this, utc, format);
    }//function format()


}//class Timezone



