package datetime;


import datetime.DateTime;
import datetime.cores.DateTimeIntervalCore;



/**
* Intervals implementation.
*
*/
@:forward(negative,getYears,getMonths,getDays,getHours,getMinutes,getSeconds,getTotalMonths,getTotalDays,getTotalHours,getTotalMinutes,getTotalSeconds)
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
    * Invert the sign of this interval. Returns itself.
    *
    */
    public inline function invert () : DateTimeInterval {
        this.negative = !this.negative;
        return this;
    }//function invert()


    /**
    * Add this interval to specified DateTime instance.
    * Returns new DateTime.
    */
    public function addTo (dt:DateTime) : DateTime {
        return dt.getTime() + sign() * (this.end.getTime() - this.begin.getTime());
    }//function addTo()


    /**
    * Substract this interval from specified DateTime instance.
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

        return strSign() + '(' + (parts.length == 0 ? '0sec' : parts.join(', ')) + ')';
    }//function toString()


    /**
    *  Returns -1 if this is a negative interval, +1 otherwise
    *
    */
    public inline function sign () : Int {
        return (this.negative ? -1 : 1);
    }//function sign()


    /**
    * Returns '-' if this is a negative interval, empty string otherwise
    *
    */
    private inline function strSign () : String {
        return (this.negative ? '-' : '');
    }//function strSign()


    /**
    * DateTimeInterval comparison
    *
    */
    @:op(A == B) private function eq (dtic:DateTimeInterval)  : Bool {
        return (
               this.getYears() == dtic.getYears()
            && this.getMonths() == dtic.getMonths()
            && this.getDays() == dtic.getDays()
            && this.getHours() == dtic.getHours()
            && this.getMinutes() == dtic.getMinutes()
            && this.getSeconds() == dtic.getSeconds()
        );
    }
    @:op(A > B)  private function gt (dtic:DateTimeInterval)  : Bool {
        if (this.getYears() > dtic.getYears()) {
            return true;
        } else if (this.getYears() == dtic.getYears()) {

            if (this.getMonths() > dtic.getMonths()) {
                return true;
            } else if (this.getMonths() == dtic.getMonths()) {

                if (this.getDays() > dtic.getDays()) {
                    return true;
                } else if (this.getDays() == dtic.getDays()) {

                    if (this.getHours() > dtic.getHours()) {
                        return true;
                    } else if (this.getHours() == dtic.getHours()) {

                        if (this.getMinutes() > dtic.getMinutes()) {
                            return true;
                        } else if (this.getMinutes() == dtic.getMinutes() && this.getSeconds() > dtic.getSeconds()) {
                            return true;
                        }
                    }
                }
            }
        }

        return false;
    }
    @:op(A >= B) private inline function gte (dtic:DateTimeInterval) : Bool return ( eq(dtic) || gt(dtic) );
    @:op(A < B)  private inline function lt (dtic:DateTimeInterval)  : Bool return !( eq(dtic) || gt(dtic) );
    @:op(A <= B) private inline function lte (dtic:DateTimeInterval) : Bool return !gt(dtic);
    @:op(A != B) private inline function neq (dtic:DateTimeInterval) : Bool return !eq(dtic);

}//class DateTimeInterval