package datetime.utils.pack;

import datetime.data.TimezoneData;
import datetime.utils.pack.DstRule;
import datetime.utils.pack.IPeriod;
import datetime.utils.pack.TZAbr;
import haxe.crypto.Base64;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.zip.InflateImpl;
import haxe.zip.Uncompress;



/**
* Uncompress tz data compressed with tools/TZBuilder
*
*/
class Decoder {


    /**
    * Decode string to Bytes
    *
    */
    static public function decode (data:String) : Bytes {
        var bytes : Bytes = Base64.decode(data);

        return Uncompress.run(bytes);
    }//function decode()


    /**
    * Build map of timezones stored in `bytes` to be able to quickly find any timezone
    *
    */
    static public function getTzMap (bytes:Bytes) : Map<String,Int> {
        var pos = 0;
        var length : Int;
        var name   : String;

        var map = new Map<String,Int>();

        while (pos < bytes.length)
        {
            length = bytes.get(pos);
            pos ++;
            name = bytes.getString(pos, length);
            pos += length;

            length = Std.int(bytes.getFloat(pos));
            pos += 4;

            map.set(name, pos);

            pos += length;
        }

        return map;
    }//function getTzMap()


    /**
    * Get timezone data located at specified `pos` in `bytes`
    *
    */
    static public function getZone (bytes:Bytes, pos:Int) : TimezoneData {
        var tzd = new TimezoneData();

        var abrs : Map<String,TZAbr> = new Map();
        pos = extractAbbreviations(bytes, pos, abrs);

        var offsets : Map<Int,Int> = new Map();
        pos = extractOffsets(bytes, pos, offsets);

        //extract periods {
            var count = bytes.get(pos ++);
            tzd.periods[count - 1] = null;

            for (i in 0...count) {
                //DstRule
                if (bytes.get(pos) == 0xFF) {
                    pos ++;
                    pos = extractDstRule(bytes, pos, tzd.periods, i, abrs, offsets);

                } else {
                    // addDstRule(data, cast periods[i], abrs, offsets);
                }
            }
        //}

        return null;
    }//function getZone()


    /**
    * Extract abbreviations dictionary.
    * Returns position of next byte after last byte of abbreviations dictionary.
    *
    */
    static private inline function extractAbbreviations (bytes:Bytes, pos:Int, abrs:Map<String,TZAbr>) : Int {
        var count = bytes.get(pos ++);

        var length,length_isDst : Int;
        var isDst : Bool;
        var name  : String;
        for (i in 0...count) {
            length_isDst = bytes.get(pos ++);

            if (length_isDst < 100) {
                isDst  = false;
                length = length_isDst;
            } else {
                isDst  = true;
                length = length_isDst - 100;
            }

            name = bytes.getString(pos, length);
            pos += length;

            abrs.set(name, new TZAbr(name, i, isDst));
        }

        return pos;
    }//function extractAbbreviations()


    /**
    * Extract offsets dictionary.
    * Returns position of next byte after last byte of offsets dictionary.
    *
    */
    static private function extractOffsets (bytes:Bytes, pos:Int, offsets:Map<Int,Int>) : Int {
        var offset : Int;
        var count = bytes.get(pos ++);
        for (i in 0...count) {

            //offset divisible by 15 minutes
            if (bytes.get(pos) == 0xFF) {
                pos ++;
                offset = bytes.get(pos ++);
                if (offset >= 100) {
                    offset = -offset;
                }
                offset *= 900;

            //plain float
            } else {
                offset = Std.int(bytes.getFloat(pos));
                pos += 4;
            }

            offsets.set(offset, i);
        }

        return pos;
    }//function extractOffsets()


    /**
    * Extract DstRule from position `pos` at `bytes` and assign it to `periods` at index `idx`
    * Returns position of next byte after last byte of extracted DstRule
    *
    */
    static private function extractDstRule (bytes:Bytes, pos:Int, periods:Array<IPeriod>, idx:Int, abrs:Map<String,TZAbr>, offsets:Map<Int,Int>) : Int {
        var rule = new DstRule();
        pos = extractUtc(bytes, pos, rule);

        var wday = bytes.get(pos ++);
        rule.wdayToDst   = Std.int(wday / 10);
        rule.wdayFromDst = wday - rule.wdayToDst * 10;

        var wdayNum = bytes.get(pos ++);
        rule.wdayNumToDst   = Std.int(wday / 10);
        rule.wdayNumFromDst = wdayNum - rule.wdayNumToDst * 10;
        if (rule.wdayNumToDst > 5) {
            rule.wdayNumToDst -= 10;
        }
        if (rule.wdayNumFromDst > 5) {
            rule.wdayNumFromDst -= 10;
        }

        var month = bytes.get(pos ++);
        rule.monthToDst   = Std.int(month / 10);
        rule.monthFromDst = month - rule.monthToDst * 10;


        // //timeToDst
        // c += addTime(buf, rule.timeToDst);
        // //timeFromDst
        // c += addTime(buf, rule.timeFromDst);

        // //abrDst + offsetDst
        // var offAbrDst = offsetMap.get(rule.offsetDst) * 10 + abrMap.get(rule.abrDst).idx;
        // buf.addByte(offAbrDst);
        // c ++;

        // //abr + offset
        // var offAbr = offsetMap.get(rule.offset) * 10 + abrMap.get(rule.abr).idx;
        // buf.addByte(offAbr);
        // c ++;

        return pos;
    }//function extractDstRule()


    /**
    * Extract utc timestamp from position `pos` at `bytes`.
    * Returns position of the next byte after utc timestamp.
    *
    */
    static private function extractUtc (bytes:Bytes, pos:Int, period:IPeriod) : Int {
        var year  = bytes.get(pos ++) + 1900;
        var month = bytes.get(pos ++);
        var day   = bytes.get(pos ++);

        var h = bytes.get(pos ++);
        var m = 0;
        var s = 0;

        if (h < 100) {
            m = bytes.get(pos ++);
            s = bytes.get(pos ++);
        } else if (h < 200) {
            h -= 100;
            m = bytes.get(pos ++);
        } else {
            h -= 200;
        }

        period.utc = DateTime.make(year, month, day, h, m, s);

        return pos;
    }//function extractUtc()

}//class Decoder