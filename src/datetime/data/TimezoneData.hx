package datetime.data;



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
    private var records : Array<TimezoneDataRecord>;
    /** last period */
    private var last (get,never) : TimezoneDataRecord;


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
                    zone.records = [new TimezoneDataRecord()];
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
    public function getPeriodFor (utc:DateTime) : TimezoneDataRecord {
        var time : Float = utc.getTime();

        for (i in (-records.length + 2)...1) {
            if (time > records[-i].time) return records[-i + 1];
        }

        return records[0];
    }//function getPeriodFor()


    /**
    * Getter `last`.
    *
    */
    private inline function get_last () : TimezoneDataRecord {
        return records[ records.length - 1 ];
    }//function get_last

}//class TimezoneData


/**
* Describes one time period in timezone
*
*/
class TimezoneDataRecord {

    /** daylight saving time */
    public var isDst : Bool = false;
    /** utc time of last second of this period */
    public var time : Float = 0;
    /** offset of local time relative to UTC in seconds */
    public var offset : Int = 0;
    /** timezone abbreviation for this period */
    public var abr : String = 'UTC';


    /**
    * Constructor
    *
    */
    public function new () : Void {
        //code...
    }//function new()

}//class TimezoneDataRecord



/**
* Automatically generated timezone data.
* Any changes in this class will be lost.
*
*/
private class TimezoneDataStorage {

    static public var data : Map<String,String> =
        #if NO_TZDATA
            new Map();
        #else
            datetime.utils.MacroUtils.embedCode('timezones.dat');
        #end

}//class TimezoneDataStorage