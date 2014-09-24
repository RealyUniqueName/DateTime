package datetime.cores;

import datetime.DateTime;


using datetime.utils.DateTimeMonthUtils;


/**
* Time interval representation.
*   Stores difference in seconds between two DateTime instances.
*   Amounts of years/months/days/hours/minutes/seconds are calculated accounting leap years.
*   Maximum allowed interval is ~4100 years.
*/
@:allow(datetime)
@:access(datetime)
class DateTimeIntervalCore {
    /** Indicates if this is negative interval */
    public var negative (default,null) : Bool = false;

    /** DateTime instance of the beginning of this interval */
    private var begin : DateTime;
    /** DateTime instance of the end of this interval */
    private var end : DateTime;

    /** amount of years */
    private var years : Int = -1;
    /** amount of months */
    private var months : Int = -1;
    /** amount of days */
    private var days : Int = -1;
    /** amount of hours */
    private var hours : Int = -1;
    /** amount of minutes */
    private var minutes : Int = -1;
    /** amount of seconds */
    private var seconds : Int = -1;


    /**
    * Constructor.
    * Manual instantiation is not allowed.
    *
    */
    private function new () : Void {
        //code...
    }//function new()


    /**
    * Get amount of full years in this interval.
    *
    */
    public function getYears () : Int {
        if (years < 0) {
            years = end.getYear() - begin.getYear();

            var m1 = begin.getMonth();
            var m2 = end.getMonth();
            if (m2 < m1) {
                years --;
            } else if (m1 == m2) {
                var d1 = begin.getDay();
                var d2 = end.getDay();
                if (d2 < d1) {
                    years --;
                } else if (d1 == d2) {
                    var h1 = begin.getHour();
                    var h2 = end.getHour();
                    if (h2 < h1) {
                        years --;
                    } else if (h2 == h1) {
                        var m1 = begin.getMinute();
                        var m2 = end.getMinute();
                        if (m2 < m1) {
                            years --;
                        } else if (m2 == m1 && end.getSecond() < begin.getSecond()) {
                            years --;
                        }
                    }
                }
            }
        }

        return years;
    }//function getYears()


    /**
    * Get amount of full months in this interval (always less then 12)
    *
    */
    public function getMonths () : Int {
        if (months < 0) {
            var monthBegin : Int = begin.getMonth();
            var monthEnd   : Int = end.getMonth();

            months = (
                monthBegin <= monthEnd
                    ? monthEnd - monthBegin
                    : 12 - monthBegin + monthEnd
            );

            var d1 = begin.getDay();
            var d2 = end.getDay();
            if (d2 < d1) {
                months --;
            } else if (d1 == d2) {
                var h1 = begin.getHour();
                var h2 = end.getHour();
                if (h2 < h1) {
                    months --;
                } else if (h2 == h1) {
                    var m1 = begin.getMinute();
                    var m2 = end.getMinute();
                    if (m2 < m1) {
                        months --;
                    } else if (m2 == m1 && end.getSecond() < begin.getSecond()) {
                        months --;
                    }
                }
            }
        }

        return months;
    }//function getMonths()


    /**
    * Get total amount of months in this interval.
    *   E.g. DateTimeInterval.fromString('(3y,5m)').getTotalMonths() returns 3 * 12 + 5 = 41
    *
    */
    public function getTotalMonths () : Int {
        return getYears() * 12 + getMonths();
    }//function getTotalMonths()


    /**
    * Get amount of full days in this interval (always less then 31)
    *
    */
    public function getDays () : Int {
        if (days < 0) {
            var dayBegin : Int = begin.getDay();
            var dayEnd   : Int = end.getDay();

            days = (
                dayBegin <= dayEnd
                    ? dayEnd - dayBegin
                    : begin.getMonth().days(begin.isLeapYear()) - dayBegin + dayEnd
            );

            var h1 = begin.getHour();
            var h2 = end.getHour();
            if (h2 < h1) {
                days --;
            } else if (h2 == h1) {
                var m1 = begin.getMinute();
                var m2 = end.getMinute();
                if (m2 < m1) {
                    days --;
                } else if (m2 == m1 && end.getSecond() < begin.getSecond()) {
                    days --;
                }
            }
        }

        return days;
    }//function getDays()


    /**
    * Get total amount of days in this interval.
    *
    */
    public function getTotalDays () : Int {
        return Std.int((end.getTime() - begin.getTime()) / DateTime.SECONDS_IN_DAY);
    }//function getTotalDays()


    /**
    * Get amount of full hours in this interval (always less then 24)
    *
    */
    public function getHours () : Int {
        if (hours < 0) {
            var hourBegin : Int = begin.getHour();
            var hourEnd   : Int = end.getHour();

            hours = (
                hourBegin <= hourEnd
                    ? hourEnd - hourBegin
                    : 24 - hourBegin + hourEnd
            );

            var m1 = begin.getMinute();
            var m2 = end.getMinute();
            if (m2 < m1) {
                hours --;
            } else if (m2 == m1 && end.getSecond() < begin.getSecond()) {
                hours --;
            }
        }

        return hours;
    }//function getHours()


    /**
    * Get total amount of hours in this interval.
    *
    */
    public function getTotalHours () : Int {
        return Std.int((end.getTime() - begin.getTime()) / DateTime.SECONDS_IN_HOUR);
    }//function getTotalHours()


    /**
    * Get amount of full minutes in this interval (always less then 60)
    *
    */
    public function getMinutes () : Int {
        if (minutes < 0) {
            var minuteBegin : Int = begin.getMinute();
            var minuteEnd   : Int = end.getMinute();

            minutes = (
                minuteBegin <= minuteEnd
                    ? minuteEnd - minuteBegin
                    : 60 - minuteBegin + minuteEnd
            );

            if (end.getSecond() < begin.getSecond()) {
                minutes --;
            }
        }

        return minutes;
    }//function getMinutes()


    /**
    * Get total amount of minutes in this interval.
    *
    */
    public function getTotalMinutes () : Int {
        return Std.int((end.getTime() - begin.getTime()) / DateTime.SECONDS_IN_MINUTE);
    }//function getTotalMinutes()


    /**
    * Get amount of full seconds in this interval (always less then 60)
    *
    */
    public function getSeconds () : Int {
        if (seconds < 0) {
            var secondBegin : Int = begin.getSecond();
            var secondEnd   : Int = end.getSecond();

            seconds = (
                secondBegin <= secondEnd
                    ? secondEnd - secondBegin
                    : 60 - secondBegin + secondEnd
            );
        }

        return seconds;
    }//function getSeconds()


    /**
    * Get total amount of seconds in this interval.
    *
    */
    public function getTotalSeconds () : Float {
        return end.getTime() - begin.getTime();
    }//function getTotalSeconds()


    /**
    * Get total amount of weeks in this interval.
    *   Not calendar weeks, but each 7 days.
    */
    public function getTotalWeeks () : Int {
        return Std.int((end.getTime() - begin.getTime()) / DateTime.SECONDS_IN_WEEK);
    }//function getTotalWeeks()

}//class DateTimeIntervalCore