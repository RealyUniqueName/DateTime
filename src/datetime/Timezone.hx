package datetime;

import datetime.DateTime;



/**
* Timezone data.
*
*/
abstract Timezone (Int) {
    /** cache for local timezone */
    static private var _local : Int = 0;

    /** id of timezone to get additional information */
    private var id (get,never) : Int;


    /**
    * Get local timezone on current machine
    * :TODO:
    *   Get REAL timezone, not just offset
    */
    static public function local () : Timezone {
        if (Timezone._local == 0) {
            #if js
                Timezone._local = untyped __js__("-60 * (new Date()).getTimezoneOffset()");
            #elseif php
                Timezone._local = untyped __php__("intval(date('Z'))");
            #else
                var now         = Date.now();
                var localTime   = DateTime.make(now.getFullYear(), now.getMonth() + 1, now.getDate(), now.getHours(), now.getMinutes(), now.getSeconds());
                Timezone._local = Std.int(localTime.getTime() - DateTime.fromDate(now).getTime());
            #end
        }

        return Timezone.fromOffset( Timezone._local );
    }//function local()


    /**
    * Make a timezone using time offset (seconds) relative to UTC.
    *
    */
    static public inline function fromOffset (offset:Int) : Timezone {
        return new Timezone( Std.int(offset / 100) );
    }//function fromOffset()


    /**
    * Make a timezone using offset specified in HHMM format
    * E.g.
    *   400     - for +4:00
    *   -1230   - for -12:30
    */
    static public inline function fromHHMM (hhmm:Int) : Timezone {
        var hh : Int = Std.int(hhmm / 100);
        var mm : Int = hhmm - hh * 100;

        var offset : Int = hh * DateTime.SECONDS_IN_HOUR + mm * DateTime.SECONDS_IN_MINUTE;

        return new Timezone( Std.int(offset / 100) );
    }//function fromHHMM()


    /**
    * Constructor
    *
    */
    private inline function new (tz:Int) : Void {
        this = tz;
    }//function new()


    /**
    * Find out what was the date/time at specified UTC time in this timezone
    * E.g.
    *   var utc = DateTime.fromString('2012-01-01 00:00:00');
    *   var tz = Timezone.fromHHMM(400);
    *   tz.at(utc).toString()  // 2014-01-01 04:00:00
    */
    public inline function at (utc:DateTime) : DateTime {
        return utc.getTime() + getOffset();
    }//function at()


    /**
    * Time offset in seconds relative to UTC time
    *
    */
    public inline function getOffset () : Int {
        return (
            this < 0
                ? -100 * ((-this) & 0xFFF)
                : 100 * (this & 0xFFFF)
        );
    }//function getOffset


    /**
    * Get offset as HHMM.
    * E.g.
    *   400     - for +4:00
    *   -1230   - for -12:30
    *
    */
    public function getHHMM () : Int {
        var offset : Int = getOffset();

        var hh : Int = Std.int(offset / DateTime.SECONDS_IN_HOUR);
        var mm : Int = Std.int( (offset - hh * DateTime.SECONDS_IN_HOUR) / DateTime.SECONDS_IN_MINUTE );

        return hh * 100 + mm;
    }//function getHHMM()


    /**
    * Make a string according to `format`.
    *
    *   %z  The time zone offset. Example: -0500 for US Eastern Time
    *   (TODO) %Z  The time zone abbreviation. Example: EST for Eastern Time
    *
    * After timezone placeholders in `format` are processed `at(dt).format(format)` is called.
    */
    public function format (format:String, dt:DateTime = 0) : String {
        var hhmm : Int = getHHMM();

        var strHHMM : String = if (hhmm < 0) {
            hhmm = -hhmm;
            '-' + StringTools.lpad('$hhmm', '0', 4);
        } else {
            '+' + StringTools.lpad('$hhmm', '0', 4);
        }

        format = StringTools.replace(format, '%z', strHHMM);

        return at(dt).format(format);
    }//function format()


    /**
    * Getter `id`.
    *
    */
    private inline function get_id () : Int {
        return (this & 0xFFF000) >> 12;
    }//function get_id

}//class Timezone



