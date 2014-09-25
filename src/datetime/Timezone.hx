package datetime;

import datetime.data.TimezoneData;
import datetime.DateTime;
import datetime.utils.TimezoneDetect;



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


    // /**
    // * Make a timezone using time offset (seconds) relative to UTC.
    // *
    // */
    // static public inline function fromOffset (offset:Int) : Timezone {
    //     return new Timezone( Std.int(offset / 100) );
    // }//function fromOffset()


    // /**
    // * Make a timezone using offset specified in HHMM format
    // * E.g.
    // *   400     - for +4:00
    // *   -1230   - for -12:30
    // */
    // static public inline function fromHHMM (hhmm:Int) : Timezone {
    //     var hh : Int = Std.int(hhmm / 100);
    //     var mm : Int = hhmm - hh * 100;

    //     var offset : Int = hh * DateTime.SECONDS_IN_HOUR + mm * DateTime.SECONDS_IN_MINUTE;

    //     return new Timezone( Std.int(offset / 100) );
    // }//function fromHHMM()


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
    * E.g.
    *   var utc = DateTime.fromString('2012-01-01 00:00:00');
    *   var tz = Timezone.fromHHMM(400);
    *   tz.at(utc).toString()  // 2014-01-01 04:00:00
    */
    public inline function at (utc:DateTime) : DateTime {
        return utc.getTime() + this.getPeriodFor(utc).offset;
    }//function at()


    // /**
    // * Time offset in seconds relative to UTC time
    // *
    // */
    // public inline function getOffset () : Int {
    //     return (
    //         this < 0
    //             ? -100 * ((-this) & 0xFFF)
    //             : 100 * (this & 0xFFFF)
    //     );
    // }//function getOffset


    // /**
    // * Get offset as HHMM.
    // * E.g.
    // *   400 for +4:00,
    // *   -1230 for -12:30
    // *
    // */
    // public function getHHMM () : Int {
    //     var offset : Int = getOffset();

    //     var hh : Int = Std.int(offset / DateTime.SECONDS_IN_HOUR);
    //     var mm : Int = Std.int( (offset - hh * DateTime.SECONDS_IN_HOUR) / DateTime.SECONDS_IN_MINUTE );

    //     return hh * 100 + mm;
    // }//function getHHMM()


    // /**
    // * Make a string according to `format`.
    // *
    // *   - `%z`  The time zone offset. Example: -0500 for US Eastern Time
    // *   - (TODO) `%Z`  The time zone abbreviation. Example: EST for Eastern Time
    // *
    // * After timezone placeholders in `format` are processed `at(dt).format(format)` is called.
    // */
    // public function format (format:String, dt:DateTime = 0) : String {
    //     var hhmm : Int = getHHMM();

    //     var strHHMM : String = if (hhmm < 0) {
    //         hhmm = -hhmm;
    //         '-' + StringTools.lpad('$hhmm', '0', 4);
    //     } else {
    //         '+' + StringTools.lpad('$hhmm', '0', 4);
    //     }

    //     format = StringTools.replace(format, '%z', strHHMM);

    //     return at(dt).format(format);
    // }//function format()


    // /**
    // * Getter `id`.
    // *
    // */
    // private inline function get_id () : Int {
    //     return (this & 0xFFF000) >> 12;
    // }//function get_id

}//class Timezone



