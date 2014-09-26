package datetime.data;

import datetime.DateTime;


/**
* List of all timezones
*
*/
@:allow(datetime)
@:access(datetime)
class TimezoneData {
    /** already instantiated timezones */
    static private var _cache : Map<String,TimezoneData> = new Map();

    /** IANA timezone name */
    private var name : String;
    #if FULL_TZDATA
        private var records : Array<TimezoneDataRecord>;
    #else
        private var records : Array<TimezoneDstRule>;
    #end


    /**
    * Get timezone data by timezone `name`.
    * `name` is like `Europe/Moscow`
    *
    * If specified timezon does not exist, UTC timezone returned instead
    */
    static public function get (name:String) : TimezoneData {
        var zone = _cache.get(name);

        if (zone == null) {
            var data : String = TimezoneDataStorage.data.get(name);
            if (data == null) {
                //Can't find UTC timezone, create default one
                if (name == 'UTC') {
                    zone = new TimezoneData();
                    zone.name    = name;
                    zone.records = [#if FULL_TZDATA new TimezoneDataRecord() #else new TimezoneDstRule() #end];
                } else {
                    zone = get('UTC');
                }

            } else {
                var obj = haxe.Unserializer.run(data);

                zone = new TimezoneData();
                zone.name    = name;
                zone.records = obj;
            }

            _cache.set(name, zone);
        }

        return zone;
    }//function get()


    /**
    * Constructor
    *
    */
    private function new () : Void {
    }//function new()


    /**
    * Find appropriate period for specified utc time
    *
    */
    public function getPeriodFor (utc:DateTime) : TimezonePeriod {
        #if FULL_TZDATA
            var time : Float = utc.getTime();

            for (i in (-records.length + 2)...1) {
                if (time > records[-i].time) return records[-i + 1];
            }

            return records[0];

        #else
            //no DST time for this zone
            if (records.length == 1) return records[0];

            var month : Int  = utc.getMonth();

            //surely not a DST period (records[0] - dst period, records[1] - non-dst period)
            if (month < records[0].month || month > records[1].month){
                return records[1];

            //surely DST period
            } else if (month > records[0].month && month < records[1].month) {
                return records[0];

            //month when non_DST-->DST switch occurs
            } else if (month == records[0].month) {
                var switchDt : DateTime = utc.getWeekDayNum(records[0].wday, records[0].wdayNum) + Second(records[0].time);
                return (utc < switchDt ? records[1] : records[0]);

            //month when DST-->non_DST switch occurs
            } else {// if (month == records[1].month) {
                var switchDt : DateTime = utc.getWeekDayNum(records[1].wday, records[1].wdayNum) + Second(records[1].time);
                return (utc < switchDt ? records[0] : records[1]);
            }
        #end
    }//function getPeriodFor()


}//class TimezoneData



class TimezonePeriod {
    /** is this a DST period */
    public var isDst : Bool = false;
    /** offset of local time relative to UTC in seconds */
    public var offset : Int = 0;
    /** timezone abbreviation for this period */
    public var abr : String = 'UTC';

    public function new () {}
}


/**
* Describes one time period in timezone
*
*/
class TimezoneDataRecord extends TimezonePeriod {

    // /** daylight saving time */
    // public var isDst : Bool = false;
    /** utc time of last second of this period */
    public var time : Float = 0;
    // /** offset of local time relative to UTC in seconds */
    // public var offset : Int = 0;
    // /** timezone abbreviation for this period */
    // public var abr : String = 'UTC';

}//class TimezoneDataRecord


/**
* Rules for switching to DST
*
*/
class TimezoneDstRule extends TimezonePeriod {
    // /** is this a DST period */
    // public var isDst : Bool = false;
    //day of week to switch to this rule
    public var wday : Int = 0;
    //which one of specified days in this month is required to switch to this rule.
    //E.g. second Sunday. -1 for last one in this month.
    public var wdayNum : Int = -1;
    //month to switch to this rule
    public var month  : Int = 1;
    //utc hour,minute,second to switch to this rule (in seconds)
    public var time : Int = 0;
    // //this rule offset in seconds relative to utc time
    // public var offset : Int = 0;
    // //this rule timezone abbreviation
    // public var abr : String = 'UTC';

}//class TimezoneDstRule


/**
* Automatically generated timezone data.
* Any changes in this class will be lost.
*
*/
private class TimezoneDataStorage {

    #if FULL_TZDATA
        static public var data : Map<String,String> = datetime.utils.MacroUtils.embedCode('timezones.dat');
    #else
        static public var data : Map<String,String> = datetime.utils.MacroUtils.embedCode('timezones_light.dat');
    #end

}//class TimezoneDataStorage