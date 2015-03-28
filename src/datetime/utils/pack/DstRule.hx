package datetime.utils.pack;

import datetime.DateTime;
import datetime.DateTimeInterval;
import datetime.utils.pack.TZPeriod;

using StringTools;


/**
* Period of strict DST switching rules
*
*/
@:allow(datetime.utils.pack)
@:allow(TZBuilder)
class DstRule implements IPeriod {

    /** utc time of the first second of this period */
    public var utc (default,null) : DateTime;
    /** day of week to switch to DST (in local time) */
    public var wdayToDst (default,null) : Int;
    /** day of week to switch to non-DST (in local time) */
    public var wdayFromDst (default,null) : Int;
    /**
    * Which one of specified days in month is required to switch to DST.
    * E.g. second Sunday. -1 for last one in this month.
    */
    public var wdayNumToDst (default,null) : Int;
    /**
    * Which one of specified days in month is required to switch to DST.
    * E.g. second Sunday. -1 for last one in this month.
    */
    public var wdayNumFromDst (default,null) : Int;
    /** Month in wich time is switching to DST */
    public var monthToDst (default,null) : Int;
    /** Month in wich time is switching from DST */
    public var monthFromDst (default,null) : Int;
    /** Local hour,minute,second to switch to DST (in seconds) */
    public var timeToDst (default,null) : Int;
    /** Local hour,minute,second to switch from DST (in seconds) */
    public var timeFromDst (default,null) : Int;
    /** Time offset during DST phase */
    public var offsetDst (default,null) : Int;
    /** Time offset during non-DST phase */
    public var offset (default,null) : Int;
    /** Timezone abbreviation for DST phase */
    public var abrDst (default,null) : String;
    /** Timezone abbreviation for non-DST phase */
    public var abr (default,null) : String;


    /**
    * For internal usage.
    * If user request TZPeriod instance for the same utc several times in a row,
    * we will not calculate period data for every request, but instead return this cached instance
    */
    private var _period           : TZPeriod;
    private var _lastRequestedUtc : DateTime;
    private var _noRequestsYet    : Bool = true;


    /**
    * Constructor
    *
    */
    public function new () {
    }//function new()


    /**
    * Get time offset at the first second of this period
    *
    */
    public function getStartingOffset () : Int {
        return (utc.getMonth() == monthToDst ? offsetDst : offset);
    }//function getStartingOffset()


    /**
    * IPeriod. Get period from one time switch to another switch, which contains `utc`
    * Does not check if `utc` is earlier than this DstRule starts
    *
    */
    public function getTZPeriod (utc:DateTime) : TZPeriod {
        if (!_noRequestsYet && _lastRequestedUtc == utc) {
            return _period;
        }
        _noRequestsYet    = false;
        _lastRequestedUtc = utc;

        var yearDt      = utc.snap(Year(Down));
        var switchToDst = estimatedSwitch(yearDt);

        _period = new TZPeriod();

        //surely non-DST period
        if (utc < switchToDst) {
            _period.utc    = estimatedSwitch( yearDt - Day(182) ); //move by half a year behind to find previous switch
            _period.isDst  = false;
            _period.abr    = abr;
            _period.offset = offset;

        //check DST period
        } else {
            var switchFromDst = estimatedSwitch(switchToDst + Day(60)); //move out of border month to calculate `switchFromDst` faster

            //DST period
            if (utc < switchFromDst) {
                _period.utc    = switchToDst;
                _period.isDst  = true;
                _period.abr    = abrDst;
                _period.offset = offsetDst;

            //non-DST
            } else {
                _period.utc    = switchFromDst;
                _period.isDst  = false;
                _period.abr    = abr;
                _period.offset = offset;
            }
        }

        return _period;
    }//function getTZPeriod()


    /**
    * Find estimated utc time of next switch to/from DST after specified `utc` time
    *
    */
    public function estimatedSwitch (utc:DateTime) : DateTime {
        if (utc < this.utc) {
            return this.utc;
        }

        var month    : Int  = (utc + Second(offset)).getMonth();
        var monthDst : Int  = (utc + Second(offsetDst)).getMonth();

        var southernHemisphere = (monthToDst > monthFromDst);

        if (southernHemisphere) {
            throw 'not implemented';
            return 0;

        //norhern hemisphere
        } else {
            //surely not a DST period
            if (month < monthToDst || monthDst > monthFromDst){
                var local = utc + Second(offsetDst);
                //switch will happen in next year?
                if (monthDst > monthFromDst) {
                    local = local.snap(Year(Up));
                }
                var switchLocal = (local.monthStart(monthToDst) : DateTime).getWeekDayNum(wdayToDst, wdayNumToDst) + Second(timeToDst);

                return switchLocal - Second(offsetDst);

            //surely DST period
            } else if (monthDst > monthToDst && monthDst < monthFromDst) {
                var local       = utc + Second(offset);
                var switchLocal = (local.monthStart(monthFromDst) : DateTime).getWeekDayNum(wdayFromDst, wdayNumFromDst) + Second(timeFromDst);

                return switchLocal - Second(offset);

            //month when non-DST-->DST switch occurs
            } else if (month == monthToDst || monthDst == monthToDst) {
                var local       = utc + Second(offsetDst);
                var switchLocal = (local.monthStart(monthToDst) : DateTime).getWeekDayNum(wdayToDst, wdayNumToDst) + Second(timeToDst);

                //switch is about to happen
                if (local < switchLocal) {
                    return switchLocal - Second(offsetDst);

                //switch already happened
                } else {
                    local       = utc + Second(offset);
                    switchLocal = (local.monthStart(monthFromDst) : DateTime).getWeekDayNum(wdayFromDst, wdayNumFromDst) + Second(timeFromDst);

                    return switchLocal - Second(offset);
                }

            //month when DST-->non-DST switch occurs
            } else {// if (month == monthFromDst) {
                var local       = utc + Second(offset);
                var switchLocal = (local.monthStart(monthFromDst) : DateTime).getWeekDayNum(wdayFromDst, wdayNumFromDst) + Second(timeFromDst);

                //switch is about to happen
                if (local < switchLocal) {
                    return switchLocal - Second(offset);

                //switch already happened
                } else {
                    local       = (utc + Second(offsetDst)).snap(Year(Up));
                    switchLocal = (local.monthStart(monthToDst) : DateTime).getWeekDayNum(wdayToDst, wdayNumToDst) + Second(timeToDst);

                    return switchLocal - Second(offsetDst);
                }
            }
        }//if ()
    }//function estimatedSwitch()


    /**
    * Get string representation of this rule
    *
    */
    public function toString () : String {
        var h = Std.int(timeToDst / 3600);
        var m = Std.int((timeToDst - h * 3600) / 60);
        var s = timeToDst - h * 3600 - m * 60;
        var timeToDstStr = '$h:'.lpad('0', 3) + '$m:'.lpad('0', 3) + '$s'.lpad('0', 2);

        var h = Std.int(timeFromDst / 3600);
        var m = Std.int((timeFromDst - h * 3600) / 60);
        var s = timeFromDst - h * 3600 - m * 60;
        var timeFromDstStr = '$h:'.lpad('0', 3) + '$m:'.lpad('0', 3) + '$s'.lpad('0', 2);

        return '{ offsetDst => $offsetDst, timeToDst => $timeToDstStr, timeFromDst => $timeFromDstStr, offset => $offset, monthFromDst => $monthFromDst, monthToDst => $monthToDst, abr => $abr, utc => $utc, abrDst => $abrDst, wdayNumFromDst => $wdayNumFromDst, wdayFromDst => $wdayFromDst, wdayNumToDst => $wdayNumToDst, wdayToDst => $wdayToDst }';
    }//function toString()

}//class DstRule