package;


import datetime.data.TimezoneData;
import haxe.crypto.Base64;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import haxe.Serializer;
import haxe.Unserializer;
import haxe.zip.Compress;
import sys.io.File;


typedef TZoneData = {
    time:Array<Float>,
    abr:Array<String>,
    offset:Array<Int>,
    isDst:Array<Bool>
}

/**
* Description
*
*/
@:access(datetime)
class CompressTzDataTest {

#if FULL_TZDATA

    /**
    * Description
    *
    */
    static public function main () : Void {
        var data : Map<String,String> = TimezoneDataStorage.data;
var all : BytesBuffer = new BytesBuffer();
        var records : Array<TimezoneDataRecord>;
        var bytes   : BytesBuffer;
        var buf : Bytes;
        var packed  : Array<String> = [];
        var offset  : Float = 0;
        var zip     : Bytes;
        for (tzName in data.keys()) {
            records = Unserializer.run( data.get(tzName) );

            bytes = new BytesBuffer();
            for (i in 0...records.length) {
                // r.time   = data.time[i];     //Float
                // r.offset = data.offset[i];   //Int
                // r.abr    = data.abr[i];      //String
                // r.isDst  = data.isDst[i];    //Bool

                offset = (records[i].offset == null ? 0 : records[i].offset);

                bytes.addFloat(records[i].time);
                bytes.addFloat(offset);
                bytes.addByte(records[i].abr.length);
                bytes.addString(records[i].abr);
                bytes.addByte(records[i].isDst ? 1 : 0);
            }
            buf = bytes.getBytes();
all.addByte(tzName.length);
all.addString(tzName);
all.addFloat(buf.length);
all.add(buf);
            zip = Compress.run(buf, 4);
            packed.push('"$tzName" => "' + Base64.encode(zip) + '"');
        }

        File.saveContent('build/timezones.dat', '[' + packed.join(',') + ']');

var str = Base64.encode(Compress.run(all.getBytes(), 4));
File.saveContent('build/timezones_all.dat', str);


haxe.Timer.measure(function(){
    buf = Base64.decode(str);
    buf = haxe.zip.Uncompress.run(buf);
});
    }//function main()


#else


    /**
    * Description
    *
    */
    static public function main () : Void {
        var data : Map<String,String> = TimezoneDataStorage.data;

        var records : Array<TimezoneDstRule>;
        var bytes   : BytesBuffer;
        var packed  : Array<String> = [];
        var tmp     : Float = 0;
        var zip     : Bytes;
        for (tzName in data.keys()) {
            records = Unserializer.run( data.get(tzName) );

            bytes = new BytesBuffer();
            for (i in 0...records.length) {
                // r.time   = data.time[i];         //Float
                // r.offset = data.offset[i];       //Int
                // r.abr    = data.abr[i];          //String
                // r.isDst  = data.isDst[i];        //Bool
                // tzr.wday    = rules[i].wday;     //Int (Byte)
                // tzr.wdayNum = rules[i].wdayNum;  //Int
                // tzr.month   = rules[i].month;    //Int (Byte)
                // tzr.time    = rules[i].time;     //Int


                bytes.addFloat(records[i].time);

                tmp = (records[i].offset == null ? 0 : records[i].offset);
                bytes.addFloat(tmp);

                bytes.addByte(records[i].abr.length);
                bytes.addString(records[i].abr);
                bytes.addByte(records[i].isDst ? 1 : 0);

                bytes.addByte(records[i].wday);

                tmp = records[i].wdayNum;
                bytes.addFloat(tmp);

                bytes.addByte(records[i].month);

                tmp = records[i].time;
                bytes.addFloat(tmp);
            }

            zip = Compress.run(bytes.getBytes(), 4);
            packed.push('"$tzName" => "' + Base64.encode(zip) + '"');
        }

        File.saveContent('build/timezones_light.dat', '[\n' + packed.join(',\n') + '\n]');
    }//function main()

#end

}//class CompressTzDataTest