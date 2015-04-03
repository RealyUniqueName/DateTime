package datetime.data;

import datetime.DateTime;
import datetime.utils.pack.DstRule;
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
    static private var tzdata : Bytes =
        #if TZBUILDER
            null;
        #else
            { datetime.utils.MacroUtils.embedString('tz.dat').join('').decode(); };
        #end
    /** tzmap */
    static private var tzmap : Map<String,Int> = null;
    /** cache of already instantiated timezones */
    static private var cache : Map<String,TimezoneData> = new Map();

    /** IANA timezone name */
    private var name (default,null) : String;
    /** periods between time switches in this timezone */
    private var periods : Array<IPeriod>;


    /**
    * Get timezone data by IANA timezone `name` (e.g. `Europe/Moscow`)
    *
    */
    static private function get (name:String) : Null<TimezoneData> {
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
    * Build list of available timezones
    *
    */
    static private function zonesList () : Array<String> {
        if (tzmap == null) {
            tzmap = tzdata.getTzMap();
        }

        return [for (zone in tzmap.keys()) zone];
    }//function zonesList()


    /**
    * Constructor
    *
    */
    private function new () : Void {
        periods = [];
    }//function new()


    /**
    * Find appropriate period between time changes for specified `utc` time
    *
    */
    public function getPeriodForUtc (utc:DateTime) : TZPeriod {
        for (i in (-periods.length + 1)...0) {
            if (utc >= periods[-i].utc) {
                return periods[-i].getTZPeriod(utc);
            }
        }

        return periods[0].getTZPeriod(utc);
    }//function getPeriodForUtc()


    /**
    * Find appropriate period between time changes for specified `dt` local time
    *
    */
    public function getPeriodForLocal (dt:DateTime) : TZPeriod {
        var time = dt.getTime();
        for (i in (-periods.length + 1)...0) {
            if (time - periods[-i].getStartingOffset() >= periods[-i].utc.getTime()) {
                return periods[-i].getTZPeriod(time - periods[-i].getStartingOffset());
            }
        }

        return periods[0].getTZPeriod(time - periods[0].getStartingOffset());
    }//function getPeriodForLocal()


    /**
    * Build an array of all periods between time switches in this zone
    *
    */
    public function getAllPeriods () : Array<TZPeriod> {
        var all : Array<TZPeriod> = [];

        var utc = periods[0].utc;
        var dstRule : DstRule;
        for (i in 0...periods.length) {
            if (Std.is(periods[i], DstRule)) {
                dstRule = cast periods[i];

                while (utc < periods[i + 1].utc) {
                    all.push(dstRule.getTZPeriod(utc));
                    utc = dstRule.estimatedSwitch( all[all.length - 1].utc );
                }

            } else {
                all.push(cast periods[i]);
            }
            if (periods.length > i + 1) {
                utc = periods[i + 1].utc;
            }
        }

        return all;
    }//function getAllPeriods()

}//class TimezoneData

