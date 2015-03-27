package ;

import datetime.DateTime;
import datetime.utils.pack.Encoder;
import haxe.io.BytesBuffer;
import haxe.Serializer;
import haxe.Unserializer;
import haxe.zip.Compress;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
import utils.FSUtils;
import datetime.data.TimezoneData;
import datetime.utils.pack.TZPeriod;

using Lambda;
using Std;
using StringTools;
using utils.FSUtils;
using datetime.utils.pack.Encoder;



/**
* Tool to build timezone data based on IANA tz database.
*
* Run with `haxe -cp ../src -x TZBuilder`
* Overrides data in `src/datetime/data/timezones*.dat`
*
*/
@:access(datetime.utils.pack)
class TZBuilder {
    /** File to save results to */
    static public inline var PATH_TZ_DAT = '../src/datetime/data/tz.dat';
    /** path to directory where to download & build IANA tz data&code */
    static public inline var PATH_TZDATA = '../build/iana';
    /**
    * If run with -debug flag this files will be used to store cache of zdump,
    * which later can be used to skip download,build,zdump,parse steps with -D TZBUILDER_USE_CACHE
    */
    static public inline var PATH_DUMP_CACHE  = 'zdump.cache';
    static public inline var PATH_PARSE_CACHE = 'parse.cache';
    /** Current time */
    static public var now = DateTime.now();
    /** Buffer to pack timezones data to */
    static public var db : BytesBuffer;


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
    public var parsed : Map<String,Array<TZPeriod>>;


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
        // removeDuplicates();

        pack();

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

            var records : Array<TZPeriod> = [];

            var lines : Array<String> = dump.get(zone).split('\n');
            var rec : TZPeriod;
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
    public function parseDumpLine (line:String) : TZPeriod {
        var p : Array<String> = ~/\s+/g.split(line);
        if (p.length < 16) return null;

        var time : Array<String> = p[4].split(':');

        var rec = new TZPeriod();
        rec.utc = DateTime.make(
            p[5].parseInt(),     //year
            months.get(p[2]),    //month
            p[3].parseInt(),     //day of month
            time[0].parseInt(),  //hours
            time[1].parseInt(),  //minutes
            time[2].parseInt()   //seconds
        );
        rec.abr    = p[13];
        rec.isDst  = (p[14] == 'isdst=1');
        rec.offset = p[15].replace('gmtoff=', '').parseInt();

        //workaround for Factory timezone
        if (rec.offset == null) {
            rec.offset = 0;
        }

        return rec;
    }//function parseDumpLine()


    /**
    * Pack zones to bytes buffer
    *
    */
    public function pack () : Void {
        db = new BytesBuffer();

        var p = 1;
        var total = parsed.count();
        for (zone in parsed.keys()) {
            Sys.print('\rPacking: ' + Std.int(p++ / total * 100) + '%\t\t');

            db.addZone(zone, parsed.get(zone));
        }

        File.saveContent(PATH_TZ_DAT, db.encode());

        Sys.println('');
    }//function pack()


    /**
    * Find number of week day in month. E.g. second Sunday or First Wednesday or last Monday etc.
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
