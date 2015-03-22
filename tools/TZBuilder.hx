package ;

import datetime.DateTime;
import haxe.Serializer;
import haxe.Unserializer;
import haxe.zip.Compress;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
import utils.FSUtils;
import datetime.data.TimezoneData;


using Lambda;
using Std;
using StringTools;
using utils.FSUtils;


typedef TZRecord = {
    utc    : DateTime,
    abr    : String,
    isDst  : Bool,
    offset : Int        //time offset in seconds relative to utc
}
// typedef TZOpt = {
//     abr : Array<String>,

// }



/**
* Tool to build timezone data based on IANA tz database.
*
* Run with `haxe -cp ../src -x TZBuilder`
* Overrides data in `src/datetime/data/timezones*.dat`
*
*/
class TZBuilder {
    /** path to directory to download & build IANA tz data&code */
    static public inline var PATH_TZDATA = '../build/iana';
    /**
    * If run with -debug flag this files will be used to store cache of zdump,
    * which later can be used to skip download,build,zdump,parse steps with -D TZBUILDER_USE_CACHE
    */
    static public inline var PATH_DUMP_CACHE  = 'zdump.cache';
    static public inline var PATH_PARSE_CACHE = 'parse.cache';
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
    public var parsed : Map<String,Array<TZRecord>>;
    // /** optimized representation of timezones data */
    // public var opt : Map<String, TZOpt>;


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

    }//function new()


    /**
    * Start process
    *
    */
    public function run () : Void {
        #if TZBUILDER_USE_CACHE
            if (!loadDumpCache()) {
                download();
                zdump();
            }
        #else
            download();
            zdump();
        #end

        parseDump();
        removeDuplicates();

        // writeData();
        // writeDataLight();

        Sys.println('Done');
    }//function run()


    /**
    * Download & build IANA tz data & code
    *
    */
    public function download () : Void {
        Sys.command('rm', ['-rf', PATH_TZDATA]);
        FSUtils.mkdir(PATH_TZDATA);

        var cwd = Sys.getCwd();
        Sys.setCwd(PATH_TZDATA);

        var out : String = '';

        Sys.println('Downloading IANA tz data&code...');
        out = new Process('wget', ['--retr-symlinks', 'ftp://ftp.iana.org/tz/tz*-latest.tar.gz']).stdout.readAll().toString();
        #if debug
            Sys.print(out);
        #end

        Sys.println('Unpacking...');
        out = new Process('tar', ['-xf', 'tzcode-latest.tar.gz']).stdout.readAll().toString();
        #if debug
            Sys.print(out);
        #end
        out = new Process('tar', ['-xf', 'tzdata-latest.tar.gz']).stdout.readAll().toString();
        #if debug
            Sys.print(out);
        #end

        Sys.println('Building...');
        out = new Process('make', ['TOPDIR=./tzdir', 'install']).stdout.readAll().toString();
        #if debug
            Sys.println(out);
        #end

        // Sys.print(new Process('./tzdir/etc/zdump', ['-v', 'Europe/Moscow']).stdout.readAll().toString());

        Sys.setCwd(cwd);
    }//function download()


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
            Sys.print('\rzic: ' + Std.int(p++ / files.length * 100) + '%\t\t');

            var src = FSUtils.ensureSlash(PATH_TZDATA) + f;
            Sys.command(PATH_TZDATA + '/tzdir/etc/zic', ['-d', zicDir, src]);
        }

        Sys.println('');
    }//function zic()


    /**
    * Dump data frome zoneinfo using `zdump` utility
    *
    */
    public function zdump () : Void {
        var cwd = Sys.getCwd();
        Sys.setCwd(PATH_TZDATA);

        dump = new Map();

        var files : Array<String> = FSUtils.listDir('./tzdir/etc/zoneinfo', FilesOnly, true);
        files = files.filter(function(f:String) return !~/localtime|\.tab$/.match(f) && f.toUpperCase().charAt(0) == f.charAt(0));

        var full = '';

        var row : String;
        for (i in 0...files.length) {
            Sys.print('\rzdump: ' + Std.int((i + 1) / files.length * 100) + '%\t\t');

            row = new Process('./tzdir/etc/zdump', ['-v', files[i]]).stdout.readAll().toString();
            dump.set(files[i], row);

            full += '!!${files[i]}\n$row\n';
        }
        Sys.println('');

        Sys.setCwd(cwd);

        #if TZBUILDER_USE_CACHE
            File.saveContent(PATH_DUMP_CACHE, full);
        #end
    }//function zdump()


    /**
    * Description
    *
    */
    public function loadDumpCache () : Bool {
        if (!FileSystem.exists(PATH_DUMP_CACHE)) {
            Sys.println('File not found: ' + PATH_DUMP_CACHE);
            return false;
        }

        dump = new Map();

        var cache : Array<String> = File.getContent(PATH_DUMP_CACHE).split('!!');
        var pos   : Int;
        var name  : String;
        var data  : String;
        for (zone in cache) {
            pos = zone.indexOf('\n');
            if (pos < 0) continue;

            name = zone.substring(0, pos);
            data = zone.substr(pos + 1);
            dump.set(name, data.trim());
        }

        return true;
    }//function loadDumpCache()


    /**
    * Parse dumped data
    *
    */
    public function parseDump () : Void {
        #if TZBUILDER_USE_CACHE
            if (FileSystem.exists(PATH_PARSE_CACHE)) {
                parsed = Unserializer.run(File.getContent(PATH_PARSE_CACHE));
                return;
            }
        #end

        parsed = new Map();

        var p     = 1;
        var total = dump.count();
        for (zone in dump.keys()) {
            Sys.print('\rparsing dump: ' + Std.int(p++ / total * 100) + '%\t\t');

            var records : Array<TZRecord> = [];

            var lines : Array<String> = dump.get(zone).split('\n');
            var rec : TZRecord;
            for (l in 0...lines.length) {
                if (lines[l].trim() == '') continue;

                rec = parseDumpLine(lines[l]);
                if (rec == null) continue;

                records.push(rec);
            }

            parsed.set(zone, records);
        }

        #if TZBUILDER_USE_CACHE
            File.saveContent(PATH_PARSE_CACHE, Serializer.run(parsed));
        #end

        Sys.println('');
    }//function parseDump()


    /**
    * Parse provided line from zdump
    *
    */
    public function parseDumpLine (line:String) : TZRecord {
        var p : Array<String> = ~/\s+/g.split(line);
        if (p.length < 16) return null;

        var time : Array<String> = p[4].split(':');

        var rec : TZRecord = {
            utc : DateTime.make(
                p[5].parseInt(),     //year
                months.get(p[2]),    //month
                p[3].parseInt(),     //day of month
                time[0].parseInt(),  //hours
                time[1].parseInt(),  //minutes
                time[2].parseInt()   //seconds
            ),
            abr    : p[13],
            isDst  : (p[14] == 'isdst=1'),
            offset : p[15].replace('gmtoff=', '').parseInt()
        };

        return rec;
    }//function parseDumpLine()


    /**
    * Every switch to/from DST in iana tz database has two records with difference in one second.
    * Remove remove one record from each pair to reduce database size.
    *
    */
    public function removeDuplicates () : Void {
        var p     = 1;
        var total = parsed.count();
        var records : Array<TZRecord>;
        var i, rec1, rec2;

        var recTotal   = 0;
        var recRemoved = 0;

        for (zone in parsed.keys()) {
            Sys.print('\rRemoving duplicates: ' + Std.int(p++ / total * 100) + '%\t\t');

            i = 0;
            records = parsed.get(zone);
            while (i < records.length - 1) {
                rec1 = records[i];
                rec2 = records[i + 1];

                if (rec2.isDst != rec1.isDst && rec2.utc.getTime() - rec1.utc.getTime() == 1) {
                    recRemoved ++;
                    records.splice(i, 1);
                } else {
                    i ++;
                }
            }
        }

        Sys.println('');
    }//function removeDuplicates()

    // /**
    // * Write all parsed data to datetime/data/timezones.dat
    // *
    // */
    // public function writeData () : Void {
    //     var content ='[\n';

    //     var p     = 1;
    //     var total = parsed.count();
    //     for (zone in parsed.keys()) {
    //         Sys.print('\rwriting data: ' + Std.int(p++ / total * 100) + '%\t\t');

    //         content += '"$zone" => ' + serializeZone(parsed.get(zone)) + ',\n';
    //     }
    //     content = content.substring(0, content.length - 2);

    //     content += '\n]\n';

    //     File.saveContent('../src/datetime/data/timezones.dat', content);

    //     Sys.println('');
    // }//function writeData()


    // /**
    // * Serialize timezone data to write to TimezoneDataStorage class
    // *
    // */
    // public function serializeZone (data:TZoneData) : String {
    //     var records : Array<TimezoneDataRecord> = [];
    //     for (i in 0...data.time.length) {
    //         var r = new TimezoneDataRecord();
    //         r.time   = data.time[i];
    //         r.offset = data.offset[i];
    //         r.abr    = data.abr[i];
    //         r.isDst  = data.isDst[i];

    //         records.push(r);
    //     }

    //     return '"' + haxe.Serializer.run(records)  + '"';
    // }//function serializeZone()


    // /**
    // * Write 'light' version of parsed data to datetime/data/timezones_light.dat
    // *
    // */
    // public function writeDataLight () : Void {
    //     var content ='[\n';

    //     var p     = 1;
    //     var total = parsed.count();
    //     for (zone in parsed.keys()) {
    //         Sys.print('\rwriting light data: ' + Std.int(p++ / total * 100) + '%\t\t');

    //         content += '"$zone" => ' + serializeZoneLight(zone) + ',\n';
    //     }
    //     content = content.substring(0, content.length - 2);

    //     content += '\n]\n';

    //     File.saveContent('../src/datetime/data/timezones_light.dat', content);

    //     Sys.println('');
    // }//function writeDataLight()


    // /**
    // * Serialize zone with minimal required data
    // *
    // */
    // public function serializeZoneLight (name:String) : String {
    //     var zone : TZoneData = parsed.get(name);

    //     var hasDst : Bool = hasDst(zone);
    //     var rules  : Array<TZDstRecord> = null;
    //     if (hasDst) {
    //         rules = getDstRules(zone);
    //         if (rules == null) {
    //             trace('DST expected, but not found in $name');
    //         }
    //     }

    //     if (rules == null) {
    //         var curIdx : Int = getCurrentPeriod(zone);
    //         rules = [{
    //             isDst   : false,
    //             wday    : 0,
    //             wdayNum : 0,
    //             month   : 0,
    //             time    : 0,
    //             abr    : zone.abr[curIdx],
    //             offset : zone.offset[curIdx]
    //         }];
    //     }

    //     var arr : Array<TimezoneDstRule> = [];
    //     for (i in 0...rules.length) {
    //         var tzr = new TimezoneDstRule();
    //         tzr.isDst   = rules[i].isDst;
    //         tzr.wday    = rules[i].wday;
    //         tzr.wdayNum = rules[i].wdayNum;
    //         tzr.month   = rules[i].month;
    //         tzr.abr     = rules[i].abr;
    //         tzr.offset  = rules[i].offset;
    //         tzr.time    = rules[i].time;
    //         arr.push(tzr);
    //     }

    //     return "'" + haxe.Serializer.run(arr) + "'";
    // }//function serializeZoneLight()


    // /**
    // * Get current period index in zone data
    // *
    // */
    // public function getCurrentPeriod (zone:TZoneData) : Int {
    //     var idx  : Int = zone.time.length - 1;
    //     var time : Float = now.getTime();

    //     //find current period
    //     for (i in (-zone.time.length + 2)...1) {
    //         if (time > zone.time[-i]) {
    //             idx = -i + 1;
    //             break;
    //         }
    //     }

    //     return idx;
    // }//function getCurrentPeriod()


    // /**
    // * Check if this zone has DST
    // *
    // */
    // public function hasDst (zone:TZoneData) : Bool {
    //     var curIdx : Int = getCurrentPeriod(zone);

    //     //check nearest future periods
    //     for (i in curIdx...(curIdx + 4)) {
    //         if (zone.isDst.length <= i) return false;
    //         if (zone.isDst[i]) return true;
    //     }

    //     return false;
    // }//function hasDst()


    // /**
    // * Get rules of switching to DST for this `zone`
    // *
    // */
    // public function getDstRules (zone:TZoneData) : Null<Array<TZDstRecord>> {
    //     var curIdx : Int = getCurrentPeriod(zone);

    //     //day of week to switch to DST
    //     var toDay    : Int = 0;
    //     //which one of specified days in this month is required to switch to DST.
    //     //E.g. second Sunday. -1 for last one in this month.
    //     var toDayNum : Int = -1;
    //     //month to switch to DST
    //     var toMonth  : Int = 1;
    //     //utc hour,minute,second to switch to DST (in seconds)
    //     var toTime   : Int = 0;
    //     //DST offset in seconds
    //     var toOffset : Int = 0;
    //     //DST zone abbreviation
    //     var toAbr    : String = 'UTC';

    //     var fromDay    : Int = 0;
    //     var fromDayNum : Int = -1;
    //     var fromMonth  : Int = 1;
    //     var fromTime   : Int = 0;
    //     var fromOffset : Int = 0;
    //     var fromAbr    : String = 'UTC';

    //     var dt : DateTime;
    //     var dstFound    : Bool = false;
    //     var nonDstFound : Bool = false;

    //     for (i in curIdx...zone.time.length) {
    //         //switch to non-dst
    //         if (!zone.isDst[i] && zone.isDst[i - 1] && zone.isDst[i - 2]) {
    //             nonDstFound = true;
    //             dt       = zone.time[i];
    //             fromDay    = dt.getWeekDay();
    //             fromDayNum = getDayNum(dt);
    //             fromMonth  = dt.getMonth();
    //             fromTime   = dt.getHour() * 3600 + dt.getMinute() * 60 + dt.getSecond();
    //             fromOffset = zone.offset[i];
    //             fromAbr    = zone.abr[i];
    //         //switch to dst
    //         } else if (zone.isDst[i] && !zone.isDst[i - 1] && !zone.isDst[i - 2]) {
    //             dstFound = true;
    //             dt       = zone.time[i];
    //             toDay    = dt.getWeekDay();
    //             toDayNum = getDayNum(dt);
    //             toMonth  = dt.getMonth();
    //             toTime   = dt.getHour() * 3600 + dt.getMinute() * 60 + dt.getSecond();
    //             toOffset = zone.offset[i];
    //             toAbr    = zone.abr[i];
    //         }
    //     }

    //     if (dstFound && nonDstFound) {
    //         return [
    //             {
    //                 isDst   : true,
    //                 wday    : toDay,
    //                 wdayNum : toDayNum,
    //                 month   : toMonth,
    //                 abr     : toAbr,
    //                 offset  : toOffset,
    //                 time    : toTime
    //             },
    //             {
    //                 isDst   : false,
    //                 wday    : fromDay,
    //                 wdayNum : fromDayNum,
    //                 month   : fromMonth,
    //                 abr     : fromAbr,
    //                 offset  : fromOffset,
    //                 time    : fromTime
    //             }
    //         ];
    //     } else {
    //         return null;
    //     }
    // }//function getDstRules()


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
