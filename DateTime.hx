package ;



abstract DateTime (Int) from Int to Int {
    /** Seconds per day */
    static public var SECONDS_PER_DAY = 86400;
    /** Amount of sconds in year */
    static private inline var SECONDS_IN_YEAR           = 31536000;
    static private inline var SECONDS_IN_LEAP_YEAR      = 31622400;
    static private inline var SECONDS_IN_QUAD           = 126230400;
    static private inline var SECONDS_IN_HALF_QUAD      = 63072000;
    static private inline var SECONDS_IN_LEAP_PART_QUAD = 94694400;

    /** amount of seconds in each month */
    static private var spm : Array<Int> = [
        2678400, //Jan
        2419200, //Feb
        2678400, //Mar
        2592000, //Apr
        2678400, //May
        2592000, //Jun
        2678400, //Jul
        2678400, //Aug
        2592000, //Sep
        2678400, //Oct
        2592000, //Nov
        2678400  //Dec
    ];


    /**
    * Constructor
    *
    */
    public inline function new (stamp:Int) : Void {
        this = stamp;
    }//function new()


    /**
    * Get year number since 1970 (starting from 0 as 1970)
    *
    */
    public inline function getUnixYear () : Int {
        var quad : Int = Std.int(this / SECONDS_IN_QUAD);
        var left : Int = this - quad * SECONDS_IN_QUAD;

        return quad * 4 + (
            left < SECONDS_IN_YEAR
                ? 0
                : (
                    left < SECONDS_IN_HALF_QUAD
                        ? 1
                        : (left < SECONDS_IN_LEAP_PART_QUAD ? 2 : 3)
                )
        );
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
    public inline function yearStart () : DateTime {
        var quad : Int = Std.int(this / SECONDS_IN_QUAD);
        var left : Int = this - quad * SECONDS_IN_QUAD;

        return new DateTime(quad * SECONDS_IN_QUAD + (
            left < SECONDS_IN_YEAR
                ? 0
                : (
                    left < SECONDS_IN_HALF_QUAD
                        ? SECONDS_IN_YEAR
                        : (left < SECONDS_IN_LEAP_PART_QUAD ? SECONDS_IN_HALF_QUAD : SECONDS_IN_LEAP_PART_QUAD)
                )
        ));
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
        var time : Int = this - yearStart();

        var month : Int = 1;
        for (m in 0...spm.length) {
            time -= spm[m];
            if (m == 1 && isLeapYear()) {
                time -= SECONDS_PER_DAY;
            }

            if (time <= 0) {
                month = m + 1;
                break;
            }
        }

        return month;
    }//function getMonth()


    /**
    * Convert to string representation in format YYYY-MM-DD HH:MM:SS
    *
    */
    // public inline function toString () : String {

    // }//function toString()

}//abstract DateTime