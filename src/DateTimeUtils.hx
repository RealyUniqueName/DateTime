package;


/**
* Utility functions for DateTime
*
*/
@:allow(DateTime)
@:access(DateTime)
class DateTimeUtils {


    /**
    * Get absolute value
    *
    */
    static public inline function abs<T:Float> (n:T) : T {
        return (n < 0 ? -n : n);
    }//function abs()


    /**
    * returns -1 if `dt` is time before unix epoch, returns +1 otherwise
    *
    */
    static public inline function sign (dt:Float) : Int {
        return (dt < 0 ? -1 : 1);
    }//function sign()


    /**
    * Get month number based on number of `days` passed since start of a year
    *
    */
    static public function getMonth (days:Int, isLeapYear:Bool = false) : Int {
        if (days < 32) return 1 //Jan
        else if (isLeapYear) {
            if (days < 61) return 2 //Feb
            else if (days < 92) return 3 //Mar
            else if (days < 122) return 4 //Apr
            else if (days < 153) return 5 //May
            else if (days < 183) return 6 //Jun
            else if (days < 214) return 7 //Jul
            else if (days < 245) return 8 //Aug
            else if (days < 275) return 9 //Sep
            else if (days < 306) return 10 //Oct
            else if (days < 336) return 11 //Nov
            else return 12;  //Dec
        } else {
            if (days < 60) return 2 //Feb
            else if (days < 91) return 3 //Mar
            else if (days < 121) return 4 //Apr
            else if (days < 152) return 5 //May
            else if (days < 182) return 6 //Jun
            else if (days < 213) return 7 //Jul
            else if (days < 244) return 8 //Aug
            else if (days < 274) return 9 //Sep
            else if (days < 305) return 10 //Oct
            else if (days < 335) return 11 //Nov
            else return 12;  //Dec
        }
    }//function getMonth()


    /**
    * Get day number based on number of `days` passed since start of a year
    *
    */
    static public function getDay (days:Int, isLeapYear:Bool = false) : Int {
        if (days < 32) return days //Jan
        else if (isLeapYear) {
            if (days < 61) return days - 31 //Feb
            else if (days < 92) return days - 60 //Mar
            else if (days < 122) return days - 91 //Apr
            else if (days < 153) return days - 121 //May
            else if (days < 183) return days - 152 //Jun
            else if (days < 214) return days - 182 //Jul
            else if (days < 245) return days - 213 //Aug
            else if (days < 275) return days - 244 //Sep
            else if (days < 306) return days - 274 //Oct
            else if (days < 336) return days - 305 //Nov
            else return days - 335;  //Dec
        } else {
            if (days < 60) return days - 31 //Feb
            else if (days < 91) return days - 59  //Mar
            else if (days < 121) return days - 90 //Apr
            else if (days < 152) return days - 120 //May
            else if (days < 182) return days - 151 //Jun
            else if (days < 213) return days - 181 //Jul
            else if (days < 244) return days - 212 //Aug
            else if (days < 274) return days - 243 //Sep
            else if (days < 305) return days - 273 //Oct
            else if (days < 335) return days - 304 //Nov
            else return days - 334;  //Dec
        }
    }//function getDay()


    /**
    * Convert month number to amount of seconds passed since year start
    *
    */
    static public function monthToSeconds (month:Int, isLeapYear:Bool = false) : Int {
        return DateTime.SECONDS_PER_DAY *  if (month == 1) 0//Jan
            else if (isLeapYear) {
                if (month == 2) 31 //Feb
                else if (month == 3) 60 //Mar
                else if (month == 4) 91 //Apr
                else if (month == 5) 121 //May
                else if (month == 6) 152 //Jun
                else if (month == 7) 182 //Jul
                else if (month == 8) 213 //Aug
                else if (month == 9) 244 //Sep
                else if (month == 10) 274 //Oct
                else if (month == 11) 305 //Nov
                else 335;  //Dec
            } else {
                if (month == 2) 31 //Feb
                else if (month == 3) 59  //Mar
                else if (month == 4) 90 //Apr
                else if (month == 5) 120 //May
                else if (month == 6) 151 //Jun
                else if (month == 7) 181 //Jul
                else if (month == 8) 212 //Aug
                else if (month == 9) 243 //Sep
                else if (month == 10) 273 //Oct
                else if (month == 11) 304 //Nov
                else 334;  //Dec
            }
        ;
    }//function monthToSeconds()


    /**
    * Convert year number (4 digits) to unix time stamp
    *
    */
    static public function yearToStamp (year:Int) : Float {
        year -= 1970;
        var quad : Int = Std.int((year < 0 ? year : year) / 4);
        var left : Int = year - quad * 4;

        //before unix epoch
        if (year < 0) {
            return 1.0 * quad * DateTime.SECONDS_IN_QUAD - (
                left == -1
                    ? DateTime.SECONDS_IN_YEAR
                    : (
                        left == -2
                            ? DateTime.SECONDS_IN_HALF_QUAD_LEAP
                            : (left == -3 ? DateTime.SECONDS_IN_3_PART_QUAD : 0)
                    )
            );
        //after unix epoch
        } else {
            return 1.0 * quad * DateTime.SECONDS_IN_QUAD + (
                left < 1
                    ? 0
                    : (
                        left < 2
                            ? DateTime.SECONDS_IN_YEAR
                            : (left < 3 ? DateTime.SECONDS_IN_HALF_QUAD : DateTime.SECONDS_IN_3_PART_QUAD)
                    )
            );
        }
    }//function convertYearToStamp()


    /**
    * Instantiating is not allowed
    *
    */
    private function new () : Void {
    }//function new()

}//class DateTimeUtils