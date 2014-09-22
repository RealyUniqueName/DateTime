package datetime;

import datetime.DateTime;

using datetime.DateTimeMonthUtils;
using datetime.DateTimeUtils;


/**
* Snap implementations
*
*/
@:allow(datetime)
@:access(datetime)
class DateTimeSnapUtils {


    /**
    * Snap to nearest year.
    * Returns unix timestamp.
    */
    static private function snapYear (dt:DateTime, direction:DTSnapDirection) : Float {
        switch (direction) {
            case Down :
                return dt.yearStart();

            case Up :
                var next : DateTime = dt.addYear(1);
                return next.yearStart();

            case Nearest :
                var next     : Float = new DateTime( dt.addYear(1) ).yearStart();
                var previous : Float = dt.yearStart();

                return (
                    next - dt.getTime() > dt.getTime() - previous
                        ? previous
                        : next
                );
        }
    }//function snapYear()


    /**
    * Snap to nearest month
    * Returns unix timestamp
    */
    static private function snapMonth (dt:DateTime, direction:DTSnapDirection) : Float {
        var month  : Int = dt.getMonth();
        var isLeap : Bool = dt.isLeapYear();

        switch (direction) {
            case Down :
                return dt.yearStart() + month.toSeconds(isLeap);

            case Up :
                return dt.yearStart() + month.toSeconds(isLeap) + month.days(isLeap) * DateTime.SECONDS_IN_DAY;

            case Nearest :
                var previous = dt.yearStart() + month.toSeconds(isLeap);
                var next     = dt.yearStart() + month.toSeconds(isLeap) + month.days(isLeap) * DateTime.SECONDS_IN_DAY;

                return (
                    next - dt.getTime() > dt.getTime() - previous
                        ? previous
                        : next
                );
        }
    }//function snapMonth()


    /**
    * Snap to nearest day
    * Returns unix timestamp
    */
    static private function snapDay (dt:DateTime, direction:DTSnapDirection) : Float {
        var days : Float = dt.getTime() / DateTime.SECONDS_IN_DAY;

        return switch (direction) {
            case Down    : Math.ffloor(days) * DateTime.SECONDS_IN_DAY;
            case Up      : Math.fceil(days) * DateTime.SECONDS_IN_DAY;
            case Nearest : Math.fround(days) * DateTime.SECONDS_IN_DAY;
        }
    }//function snapDay()


    /**
    * Snap to nearest hour
    * Returns unix timestamp
    */
    static private function snapHour (dt:DateTime, direction:DTSnapDirection) : Float {
        var hours : Float = dt.getTime() / DateTime.SECONDS_IN_HOUR;

        return switch (direction) {
            case Down    : Math.ffloor(hours) * DateTime.SECONDS_IN_HOUR;
            case Up      : Math.fceil(hours) * DateTime.SECONDS_IN_HOUR;
            case Nearest : Math.fround(hours) * DateTime.SECONDS_IN_HOUR;
        }
    }//function snapHour()


    /**
    * Snap to nearest minute
    * Returns unix timestamp
    */
    static private function snapMinute (dt:DateTime, direction:DTSnapDirection) : Float {
        var minutes : Float = dt.getTime() / DateTime.SECONDS_IN_MINUTE;

        return switch (direction) {
            case Down    : Math.ffloor(minutes) * DateTime.SECONDS_IN_MINUTE;
            case Up      : Math.fceil(minutes) * DateTime.SECONDS_IN_MINUTE;
            case Nearest : Math.fround(minutes) * DateTime.SECONDS_IN_MINUTE;
        }
    }//function snapMinute()


    /**
    * Snap to nearest specified week day
    * Returns unix timestamp
    */
    static private function snapWeek (dt:DateTime, direction:DTSnapDirection, day:DTWeekDay) : Float {
        var current  : Int = dt.getWeekDay();
        var required : Int = cast day;

        var days : Float = Math.ffloor(dt.getTime() / DateTime.SECONDS_IN_DAY);

        switch (direction) {
            case Down :
                var diff : Int = (current >= required ? current - required : current + 7 - required);
                return (days - diff) * DateTime.SECONDS_IN_DAY;

            case Up :
                var diff : Int = (required > current ? required - current : required + 7 - current);
                return (days + diff) * DateTime.SECONDS_IN_DAY;

            case Nearest :
                var diff     : Int = (current >= required ? current - required : current + 7 - required);
                var previous : Float =  (days - diff) * DateTime.SECONDS_IN_DAY;

                var diff : Int = (required > current ? required - current : required + 7 - current);
                var next : Float = (days + diff) * DateTime.SECONDS_IN_DAY;

                return (
                    next - dt.getTime() > dt.getTime() - previous
                        ? previous
                        : next
                );
        }
    }//function snapWeek()


    /**
    * Instantiating is not allowed
    *
    */
    private function new () : Void {
    }//function new()

}//class DateTimeSnapUtils