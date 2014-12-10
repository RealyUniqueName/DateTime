package datetime;


import datetime.DateTime;
import datetime.cores.DateTimeIntervalCore;
import datetime.utils.DateTimeIntervalUtils;



/**
* Intervals implementation.
*
*/
@:forward(negative,getYears,getMonths,getDays,getHours,getMinutes,getSeconds,getTotalMonths,getTotalDays,getTotalHours,getTotalMinutes,getTotalSeconds,getTotalWeeks)
abstract DateTimeInterval (DateTimeIntervalCore) to DateTimeIntervalCore from DateTimeIntervalCore {


    /**
    * Create interval as difference between two DateTime instances
    *
    */
    static public function create (begin:DateTime, end:DateTime) : DateTimeInterval {
        var dtic = new DateTimeIntervalCore();
        dtic.begin    = (end < begin ? end : begin);
        dtic.end      = (end < begin ? begin : end);
        dtic.negative = (end < begin);

        return dtic;
    }//function create()


    /**
    * Constructor.
    *
    */
    public inline function new (dtic:DateTimeIntervalCore) : Void {
        this = dtic;
    }//function new()


    /**
    * Invert the sign of this interval. Modifies internal state. Returns itself.
    *
    */
    public inline function invert () : DateTimeInterval {
        this.negative = !this.negative;
        return this;
    }//function invert()


    /**
    * Add this interval to specified DateTime instance.
    *
    * Returns new DateTime.
    */
    public function addTo (dt:DateTime) : DateTime {
        return dt.getTime() + sign() * (this.end.getTime() - this.begin.getTime());
    }//function addTo()


    /**
    * Substract this interval from specified DateTime instance.
    *
    * Returns new DateTime.
    */
    public function subFrom (dt:DateTime) : DateTime {
        return dt.getTime() - sign() * (this.end.getTime() - this.begin.getTime());
    }//function subFrom()


    /**
    * Get string representation of this interval.
    *
    */
    public function toString () : String {
        var years   = this.getYears();
        var months  = this.getMonths();
        var days    = this.getDays();
        var hours   = this.getHours();
        var minutes = this.getMinutes();
        var seconds = this.getSeconds();

        var parts : Array<String> = [];
        if (years != 0)     parts.push('${years}y');
        if (months != 0)    parts.push('${months}m');
        if (days != 0)      parts.push('${days}d');
        if (hours != 0)     parts.push('${hours}hrs');
        if (minutes != 0)   parts.push('${minutes}min');
        if (seconds != 0)   parts.push('${seconds}sec');

        return (this.negative ? '-' : '') + '(' + (parts.length == 0 ? '0sec' : parts.join(', ')) + ')';
    }//function toString()


    /**
    *  Returns -1 if this is a negative interval, +1 otherwise
    *
    */
    public inline function sign () : Int {
        return (this.negative ? -1 : 1);
    }//function sign()


    /**
    * Formats the interval
    *
    *   - `%%` Literal %. Example:   %
    *   - `%Y` Years, numeric, at least 2 digits with leading 0. Example:    01, 03
    *   - `%y` Years, numeric. Example:  1, 3
    *   - `%M` Months, numeric, at least 2 digits with leading 0. Example:   01, 03, 12
    *   - `%m` Months, numeric. Example: 1, 3, 12
    *   - `%b` Total number of months. Example:   2, 15, 36
    *   - `%D` Days, numeric, at least 2 digits with leading 0. Example: 01, 03, 31
    *   - `%d` Days, numeric. Example:   1, 3, 31
    *   - `%a` Total number of days. Example:   4, 18, 8123
    *   - `%H` Hours, numeric, at least 2 digits with leading 0. Example:    01, 03, 23
    *   - `%h` Hours, numeric. Example:  1, 3, 23
    *   - `%c` Total number of hours. Example:   4, 18, 8123
    *   - `%I` Minutes, numeric, at least 2 digits with leading 0. Example:  01, 03, 59
    *   - `%i` Minutes, numeric. Example:    1, 3, 59
    *   - `%e` Total number of minutes. Example:   4, 18, 8123
    *   - `%S` Seconds, numeric, at least 2 digits with leading 0. Example:  01, 03, 57
    *   - `%s` Seconds, numeric. Example:    1, 3, 57
    *   - `%f` Total number of seconds. Example:   4, 18, 8123
    *   - `%R` Sign "-" when negative, "+" when positive. Example:   -, +
    *   - `%r` Sign "-" when negative, empty when positive. Example: -,
    */
    public inline function format (format:String) : String {
        return DateTimeIntervalUtils.strftime(this, format);
    }//function format()


    /**
    * Formats  each string in `format` array. Each string can have only one placeholder.
    *
    * Supported placeholders: see `format()` method description except `r,R,%` placeholders.
    *
    * Returns new array with elements, whose corresponding strings in `format` array were filled with non-zero values.
    *
    * Example: if interval contains 0 years, 2 months and 10 days, then
    * `interval.format(['%y years', '%m months', '%d days']).join(',')` will return `'2 months, 10 days'`
    *
    */
    public inline function formatPartial (format:Array<String>) : Array<String> {
        return DateTimeIntervalUtils.formatPartial(this, format);
    }//function formatPartial()


    /**
    * DateTimeInterval comparison
    *
    */
    @:op(A == B) private inline function eq (dtic:DateTimeInterval)  return this.getTotalSeconds() == dtic.getTotalSeconds();
    @:op(A > B) private inline function gt (dtic:DateTimeInterval)   return this.getTotalSeconds() > dtic.getTotalSeconds();
    @:op(A >= B) private inline function gte (dtic:DateTimeInterval) return this.getTotalSeconds() >= dtic.getTotalSeconds();
    @:op(A < B)  private inline function lt (dtic:DateTimeInterval)  return this.getTotalSeconds() < dtic.getTotalSeconds();
    @:op(A <= B) private inline function lte (dtic:DateTimeInterval) return this.getTotalSeconds() <= dtic.getTotalSeconds();
    @:op(A != B) private inline function neq (dtic:DateTimeInterval) return this.getTotalSeconds() != dtic.getTotalSeconds();


    // /**
    // * Get amount of full years in this interval.
    // *
    // */
    // public function getYears () : Int {
    //     return 0;
    // }//function getYears()


    // /**
    // * Get amount of full months in this interval (always less then 12)
    // *
    // */
    // public function getMonths () : Int {
    //     return 0;
    // }//function getMonths()


    // /**
    // * Get total amount of months in this interval.
    // *
    // * E.g. if interval contains 3 years and 5 months, then `interval.getTotalMonths()` returns 3 * 12 + 5 = 41
    // *
    // */
    // public function getTotalMonths () : Int {
    //     return 0;
    // }//function getTotalMonths()


    // /**
    // * Get amount of full days in this interval (always less then 31)
    // *
    // */
    // public function getDays () : Int {
    //     return 0;
    // }//function getDays()


    // /**
    // * Get total amount of days in this interval.
    // *
    // */
    // public function getTotalDays () : Int {
    //     return 0;
    // }//function getTotalDays()


    // /**
    // * Get amount of full hours in this interval (always less then 24)
    // *
    // */
    // public function getHours () : Int {
    //     return 0;
    // }//function getHours()


    // /**
    // * Get total amount of hours in this interval.
    // *
    // */
    // public function getTotalHours () : Int {
    //     return 0;
    // }//function getTotalHours()


    // /**
    // * Get amount of full minutes in this interval (always less then 60)
    // *
    // */
    // public function getMinutes () : Int {
    //     return 0;
    // }//function getMinutes()


    // /**
    // * Get total amount of minutes in this interval.
    // *
    // */
    // public function getTotalMinutes () : Int {
    //     return 0;
    // }//function getTotalMinutes()


    // /**
    // * Get amount of full seconds in this interval (always less then 60)
    // *
    // */
    // public function getSeconds () : Int {
    //     return 0;
    // }//function getSeconds()


    // /**
    // * Get total amount of seconds in this interval.
    // *
    // */
    // public function getTotalSeconds () : Float {
    //     return 0;
    // }//function getTotalSeconds()


    // /**
    // * Get total amount of weeks in this interval.
    // *
    // * Not calendar weeks, but each 7 days.
    // */
    // public function getTotalWeeks () : Int {
    //     return 0;
    // }//function getTotalWeeks()

}//class DateTimeInterval