package datetime;

import datetime.DateTime;



/**
* Timezone data.
*
*/
abstract Timezone (Int) {

    /** time offset in seconds relative to UTC time */
    public var offset (get,never): Int;
    /** id of timezone to get additional information */
    private var id (get,never) : Int;


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
        return utc.getTime() + offset;
    }//function at()


    /**
    * Getter `offset`.
    *
    */
    private inline function get_offset () : Int {
        return (
            this < 0
                ? -100 * ((-this) & 0xFFF)
                : 100 * (this & 0xFFFF)
        );
    }//function get_offset


    /**
    * Getter `id`.
    *
    */
    private inline function get_id () : Int {
        return (this & 0xFFF000) >> 12;
    }//function get_id

}//class Timezone



