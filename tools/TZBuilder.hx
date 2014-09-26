package ;

import datetime.DateTime;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
import utils.FSUtils;
import datetime.data.TimezoneData;


using Lambda;
using Std;
using StringTools;
using utils.FSUtils;


typedef TZoneData = {time:Array<Float>, abr:Array<String>, offset:Array<Int>, isDst:Array<Bool>}
typedef TZDstRecord = {
    isDst   : Bool,
    wday    : Int,
    wdayNum : Int,
    month   : Int,
    time    : Int,
    abr      : String,
    offset   : Int
}


/**
* Tool to build timezone data based on /usr/share/zoneinfo in your system.
*
* Run with `haxe -cp ../src -x TZBuilder`
* Overrides data in `src/datetime/TimezoneData.hx`
*
*/
class TZBuilder {
    /** path to tz_database downloaded from ftp://ftp.iana.org/tz/tzdata-latest.tar.gz */
    static public inline var PATH_TZDATA = 'tzdatabase/';
    /** path to /usr/share/zoneinfo in your system */
    static public inline var PATH_ZONEINFO = '/usr/share/zoneinfo/';
    /** Current time */
    static public var now = DateTime.now();


    /** months */
    static public var months : Map<String,Int> = [
        'Jan' => 1,
        'Feb' => 2,
        'Mar' => 3,
        'Apr' => 4,
        'May' => 5,
        'Jun' => 6,
        'Jul' => 7,
        'Aug' => 8,
        'Sep' => 9,
        'Oct' => 10,
        'Nov' => 11,
        'Dec' => 12
    ];
    /** days */
    static public var days : Map<String,Int> = [
        'Mon' => 1,
        'Tue' => 2,
        'Wed' => 3,
        'Thu' => 4,
        'Fri' => 5,
        'Sat' => 6,
        'Sun' => 7
    ];


    /** zdump data */
    public var dump : Map<String,String>;
    /** parsed zdump data */
    public var parsed : Map<String,TZoneData>;


    /**
    * Entry point
    *
    */
    static public function main () : Void {
        new TZBuilder().run();
    }//function main()


    /**
    * Constructor
    *
    */
    public function new () : Void {
        dump   = new Map();
        parsed = new Map();
    }//function new()


    /**
    * Start process
    *
    */
    public function run () : Void {
        // zic();
        zdump();
        parseDump();
        writeData();
        writeDataLight();

        Sys.println('Done');
    }//function run()


    /**
    * Parse IANA tz_database
    *
    */
    public function zic () : Void {
        var zicDir = '../build/zic';

        FSUtils.rmdir(zicDir);
        FSUtils.mkdir(zicDir, true);

        var files : Array<String> = [
            'africa',
            'antarctica',
            'asia',
            'australasia',
            'etcetera',
            'europe',
            'northamerica',
            'southamerica',
            'pacificnew',
            'backward'
        ];

        var p = 1;
        for (f in files) {
            Sys.print('\rzdump: ' + Std.int(p++ / files.length * 100) + '%\t\t');

            var src = FSUtils.ensureSlash(PATH_TZDATA) + f;
            Sys.command('zic', ['-d', zicDir, src]);
        }

        Sys.println('');
    }//function zic()


    /**
    * Dump data frome zoneinfo using `zdump` utility
    *
    */
    public function zdump () : Void {
        var files : Array<String> = FSUtils.listDir(PATH_ZONEINFO, FilesOnly, true);
        files = files.filter(function(f:String) return !~/^(posix|right|SystemV)/.match(f) && f.toUpperCase().charAt(0) == f.charAt(0));

        for (i in 0...files.length) {
            Sys.print('\rzdump: ' + Std.int((i + 1) / files.length * 100) + '%\t\t');

            var path = PATH_ZONEINFO.ensureSlash() + files[i];
            dump.set(files[i], new Process('zdump', ['-v', path]).stdout.readAll().toString());
        }
        Sys.println('');
    }//function zdump()


    /**
    * Parse dumped data
    *
    */
    public function parseDump () : Void {
        var p     = 1;
        var total = dump.count();
        for (zone in dump.keys()) {
            Sys.print('\rparsing dump: ' + Std.int(p++ / total * 100) + '%\t\t');

            var time   : Array<Float> = [];
            var abr    : Array<String> = [];
            var offset : Array<Int> = [];
            var isDst  : Array<Bool> = [];

            var lines : Array<String> = dump.get(zone).split('\n');

            for (l in 0...lines.length) {
                if (lines[l].trim() == '') continue;

                var obj = parseDumpLine(lines[l]);

                time.push( obj.utc.getTime() );
                abr.push( obj.abr );
                offset.push( obj.offset );
                isDst.push( obj.isDst );
            }

            parsed.set(zone, {
                time   : time,
                abr    : abr,
                offset : offset,
                isDst  : isDst
            });

        }

        Sys.println('');
    }//function parseDump()


    /**
    * Parse provided line from zdump
    *
    */
    public function parseDumpLine (line:String) : {utc:DateTime, abr:String, isDst:Bool, offset:Int} {
        var p : Array<String> = ~/\s+/g.split(line);

        var utcTime   : Array<String> = p[4].split(':');
        var localTime : Array<String> = p[11].split(':');

        var obj = {
            utc : DateTime.make(
                p[5].parseInt(),
                months.get(p[2]),
                p[3].parseInt(),
                utcTime[0].parseInt(),
                utcTime[1].parseInt(),
                utcTime[2].parseInt()
            ),
            // local : DateTime.make(
            //    p[12].parseInt(),
            //    months.get(p[9]),
            //    p[10].parseInt(),
            //    localTime[0].parseInt(),
            //    localTime[1].parseInt(),
            //    localTime[2].parseInt()
            // ),
            abr    : p[13],
            isDst  : (p[14] == 'isdst=1'),
            offset : p[15].replace('gmtoff=', '').parseInt()
        };

        return obj;
    }//function parseDumpLine()


    /**
    * Write all parsed data to datetime/data/timezones.dat
    *
    */
    public function writeData () : Void {
        var content ='[\n';

        var p     = 1;
        var total = parsed.count();
        for (zone in parsed.keys()) {
            Sys.print('\rwriting data: ' + Std.int(p++ / total * 100) + '%\t\t');

            content += '"$zone" => ' + serializeZone(parsed.get(zone)) + ',\n';
        }
        content = content.substring(0, content.length - 2);

        content += '\n]\n';

        File.saveContent('../src/datetime/data/timezones.dat', content);

        Sys.println('');
    }//function writeData()


    /**
    * Serialize timezone data to write to TimezoneDataStorage class
    *
    */
    public function serializeZone (data:TZoneData) : String {
        var records : Array<TimezoneDataRecord> = [];
        for (i in 0...data.time.length) {
            var r = new TimezoneDataRecord();
            r.time   = data.time[i];
            r.offset = data.offset[i];
            r.abr    = data.abr[i];
            r.isDst  = data.isDst[i];

            records.push(r);
        }

        return '"' + haxe.Serializer.run(records)  + '"';
    }//function serializeZone()


    /**
    * Write 'light' version of parsed data to datetime/data/timezones_light.dat
    *
    */
    public function writeDataLight () : Void {
        var content ='[\n';

        var p     = 1;
        var total = parsed.count();
        for (zone in parsed.keys()) {
            Sys.print('\rwriting light data: ' + Std.int(p++ / total * 100) + '%\t\t');

            content += '"$zone" => ' + serializeZoneLight(zone) + ',\n';
        }
        content = content.substring(0, content.length - 2);

        content += '\n]\n';

        File.saveContent('../src/datetime/data/timezones_light.dat', content);

        Sys.println('');
    }//function writeDataLight()


    /**
    * Serialize zone with minimal required data
    *
    */
    public function serializeZoneLight (name:String) : String {
        var zone : TZoneData = parsed.get(name);

        var hasDst : Bool = hasDst(zone);
        var rules  : Array<TZDstRecord> = null;
        if (hasDst) {
            rules = getDstRules(zone);
            if (rules == null) {
                trace('DST expected, but not found in $name');
            }
        }

        if (rules == null) {
            var curIdx : Int = getCurrentPeriod(zone);
            rules = [{
                isDst   : false,
                wday    : 0,
                wdayNum : 0,
                month   : 0,
                time    : 0,
                abr    : zone.abr[curIdx],
                offset : zone.offset[curIdx]
            }];
        }

        var arr : Array<TimezoneDstRule> = [];
        for (i in 0...rules.length) {
            var tzr = new TimezoneDstRule();
            tzr.isDst   = rules[i].isDst;
            tzr.wday    = rules[i].wday;
            tzr.wdayNum = rules[i].wdayNum;
            tzr.month   = rules[i].month;
            tzr.abr     = rules[i].abr;
            tzr.offset  = rules[i].offset;
            tzr.time    = rules[i].time;
            arr.push(tzr);
        }

        return "'" + haxe.Serializer.run(arr) + "'";
    }//function serializeZoneLight()


    /**
    * Get current period index in zone data
    *
    */
    public function getCurrentPeriod (zone:TZoneData) : Int {
        var idx  : Int = zone.time.length - 1;
        var time : Float = now.getTime();

        //find current period
        for (i in (-zone.time.length + 2)...1) {
            if (time > zone.time[-i]) {
                idx = -i + 1;
                break;
            }
        }

        return idx;
    }//function getCurrentPeriod()


    /**
    * Check if this zone has DST
    *
    */
    public function hasDst (zone:TZoneData) : Bool {
        var curIdx : Int = getCurrentPeriod(zone);

        //check nearest future periods
        for (i in curIdx...(curIdx + 4)) {
            if (zone.isDst.length <= i) return false;
            if (zone.isDst[i]) return true;
        }

        return false;
    }//function hasDst()


    /**
    * Get rules of switching to DST for this `zone`
    *
    */
    public function getDstRules (zone:TZoneData) : Null<Array<TZDstRecord>> {
        var curIdx : Int = getCurrentPeriod(zone);

        //day of week to switch to DST
        var toDay    : Int = 0;
        //which one of specified days in this month is required to switch to DST.
        //E.g. second Sunday. -1 for last one in this month.
        var toDayNum : Int = -1;
        //month to switch to DST
        var toMonth  : Int = 1;
        //utc hour,minute,second to switch to DST (in seconds)
        var toTime   : Int = 0;
        //DST offset in seconds
        var toOffset : Int = 0;
        //DST zone abbreviation
        var toAbr    : String = 'UTC';

        var fromDay    : Int = 0;
        var fromDayNum : Int = -1;
        var fromMonth  : Int = 1;
        var fromTime   : Int = 0;
        var fromOffset : Int = 0;
        var fromAbr    : String = 'UTC';

        var dt : DateTime;
        var dstFound    : Bool = false;
        var nonDstFound : Bool = false;

        for (i in curIdx...zone.time.length) {
            //switch to non-dst
            if (!zone.isDst[i] && zone.isDst[i - 1] && zone.isDst[i - 2]) {
                nonDstFound = true;
                dt       = zone.time[i];
                fromDay    = dt.getWeekDay();
                fromDayNum = getDayNum(dt);
                fromMonth  = dt.getMonth();
                fromTime   = dt.getHour() * 3600 + dt.getMinute() * 60 + dt.getSecond();
                fromOffset = zone.offset[i];
                fromAbr    = zone.abr[i];
            //switch to dst
            } else if (zone.isDst[i] && !zone.isDst[i - 1] && !zone.isDst[i - 2]) {
                dstFound = true;
                dt       = zone.time[i];
                toDay    = dt.getWeekDay();
                toDayNum = getDayNum(dt);
                toMonth  = dt.getMonth();
                toTime   = dt.getHour() * 3600 + dt.getMinute() * 60 + dt.getSecond();
                toOffset = zone.offset[i];
                toAbr    = zone.abr[i];
            }
        }

        if (dstFound && nonDstFound) {
            return [
                {
                    isDst   : true,
                    wday    : toDay,
                    wdayNum : toDayNum,
                    month   : toMonth,
                    abr     : toAbr,
                    offset  : toOffset,
                    time    : toTime
                },
                {
                    isDst   : false,
                    wday    : fromDay,
                    wdayNum : fromDayNum,
                    month   : fromMonth,
                    abr     : fromAbr,
                    offset  : fromOffset,
                    time    : fromTime
                }
            ];
        } else {
    trace(curIdx);
    trace( new DateTime(zone.time[curIdx]) );
            return null;
        }
    }//function getDstRules()


    /**
    * Find number of week day in month. E.g. second Sunday of First Wednesday or last Monday etc.
    *
    */
    public function getDayNum (dt:DateTime) : Int {
        var month : Int = dt.getMonth();
        var wday  : Int = dt.getWeekDay();
        var n     : Int = 0;

        //last day?
        if ( (dt + Week(1)).getMonth() != month ) {
            return -1;
        }

        while (dt.getMonth() == month) {
            dt -= Week(1);
            n ++;
        }

        return n;
    }//function getDayNum()

}//class TZBuilder