package datetime.data;

import datetime.DateTime;
import datetime.utils.pack.IPeriod;
import datetime.utils.pack.TZPeriod;
import haxe.io.Bytes;

using datetime.utils.pack.Decoder;


/**
* List of all timezones
*
*/
@:allow(datetime)
@:access(datetime)
class TimezoneData {
    /** tzdata */
    static private var tzdata : Bytes = { datetime.utils.MacroUtils.embedString('tz.dat').decode(); };
    /** tzmap */
    static private var tzmap : Map<String,Int> = null;
    /** cache of already instantiated timezones */
    static private var cache : Map<String,TimezoneData> = new Map();

    /** IANA timezone name */
    public var name (default,null) : String;
    /** periods between time switches in this timezone */
    private var periods : Array<IPeriod>;


    /**
    * Get timezone data by IANA timezone `name` (e.g. `Europe/Moscow`)
    *
    */
    static public function get (name:String) : Null<TimezoneData> {
        //build timezones map
        if (tzmap == null) {
            tzmap = tzdata.getTzMap();
        }

        var zone = cache.get(name);
        if (zone == null) {
            if (tzmap.exists(name)) {
                zone = tzdata.getZone(tzmap.get(name));
                zone.name = name;
                cache.set(name, zone);
            }
        }

        return zone;
    }//function get()


    /**
    * Constructor
    *
    */
    private function new () : Void {
        periods = [];
    }//function new()


    /**
    * Find appropriate period for specified `dt` time
    *
    * @param `isLocal` - wether `dt` is UTC or local time
    */
    public function getPeriodForUtc (utc:DateTime) : TZPeriod {
        return null;
    }//function getPeriodForUtc()


    /**
    * Find appropriate period for specified `dt` time
    *
    * @param `isLocal` - wether `dt` is UTC or local time
    */
    public function getPeriodForLocal (dt:DateTime) : TZPeriod {
        return null;
    }//function getPeriodForLocal()


}//class TimezoneData

