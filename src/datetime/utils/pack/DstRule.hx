package datetime.utils.pack;

import datetime.DateTime;
import datetime.DateTimeInterval;



/**
* Period of strict DST switching rules
*
*/
class DstRule implements IPeriod {

    /** utc time of the first second of this period */
    public var utc (default,null) : DateTime;
    /** Whether first period of this DstRule has daylight saving time */
    public var isDstStart (default,null) : Bool;
    /** day of week to switch to DST */
    public var wdayToDst (default,null) : Int;
    /** day of week to switch to non-DST */
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
    /** Utc hour,minute,second to switch to DST (in seconds) */
    public var timeToDst (default,null) : Int;
    /** Utc hour,minute,second to switch from DST (in seconds) */
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
    * Constructor
    *
    */
    public function new (
        utc            : DateTime,
        isDstStart     : Bool,
        wdayToDst      : Int,
        wdayFromDst    : Int,
        wdayNumToDst   : Int,
        wdayNumFromDst : Int,
        monthToDst     : Int,
        monthFromDst   : Int,
        timeToDst      : Int,
        timeFromDst    : Int,
        offsetDst      : Int,
        offset         : Int,
        abrDst         : String,
        abr            : String
    ) : Void {
        this.utc            = utc;
        this.isDstStart     = isDstStart;
        this.wdayToDst      = wdayToDst;
        this.wdayFromDst    = wdayFromDst;
        this.wdayNumToDst   = wdayNumToDst;
        this.wdayNumFromDst = wdayNumFromDst;
        this.monthToDst     = monthToDst;
        this.monthFromDst   = monthFromDst;
        this.timeToDst      = timeToDst;
        this.timeFromDst    = timeFromDst;
        this.offsetDst      = offsetDst;
        this.offset         = offset;
        this.abrDst         = abrDst;
        this.abr            = abr;
    }//function new()


    /**
    * Check if this period contains specified `utc` time
    *
    */
    public function containts (utc:DateTime) : Bool {
        return false;
    }//function containts()


    /**
    * Find estimated utc time of next switch to/from DST after specified `utc` time
    *
    */
    public function estimatedSwitch (utc:DateTime) : DateTime {
        if (utc < this.utc) {
            return this.utc;
        }

        var month : Int  = utc.getMonth();

        //surely not a DST period (records[0] - dst period, records[1] - non-dst period)
        if (month < monthToDst || month > monthFromDst){
            return utc + Second(offset);

        //surely DST period
        } else if (month > monthToDst && month < monthFromDst) {
            return utc + Second(offsetDst);

        //month when non-DST-->DST switch occurs
        } else if (month == monthToDst) {
            var switchTime : DateTime = utc.getWeekDayNum(wdayToDst, wdayNumToDst) + Second(timeToDst);
            if (utc < switchTime) {
                return switchTime;
            } else {
                return (utc.monthStart(monthFromDst) : DateTime).getWeekDayNum(wdayFromDst, wdayNumFromDst);
            }

        //month when DST-->non-DST switch occurs
        } else {// if (month == monthFromDst) {
            var switchTime : DateTime = utc.getWeekDayNum(wdayFromDst, wdayNumFromDst) + Second(timeFromDst);
            if (utc < switchTime) {
                return switchTime;
            } else {
                utc = utc.snap(Year(Up));
                return (utc.monthStart(monthFromDst) : DateTime).getWeekDayNum(wdayFromDst, wdayNumFromDst);
            }
        }

        return this.utc;
    }//function estimatedSwitch()

}//class DstRule