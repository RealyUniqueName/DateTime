package datetime.utils.pack;

import datetime.data.TimezoneData;
import datetime.utils.pack.DstRule;
import datetime.utils.pack.IPeriod;
import datetime.utils.pack.TZAbr;
import datetime.utils.pack.TZPeriod;
import haxe.io.Bytes;
#if !php
    import haxe.crypto.Base64;
#end



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
        #if php
            data = untyped __call__('base64_decode', data);
            return Bytes.ofString(data);
        #else
            return Base64.decode(data);
        #end
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
        //if this zone if symlink to another zone
        if (bytes.get(pos) == 0xFF) {
            pos = Std.int(bytes.getFloat(pos + 1));
        }

        var tzd = new TimezoneData();

        var abrs : Array<TZAbr> = [];
        pos = extractAbbreviations(bytes, pos, abrs);

        var offsets : Array<Int> = [];
        pos = extractOffsets(bytes, pos, offsets);

        //extract periods {
            var count = bytes.get(pos ++);

            tzd.periods[count - 1] = null;

            for (i in 0...count) {
                //DstRule
                if (bytes.get(pos) >= 0xFE) {
                    pos = extractDstRule(bytes, pos, tzd.periods, i, abrs, offsets);
                //TZPeriod
                } else {
                    pos = extractTZPeriod(bytes, pos, tzd.periods, i, abrs, offsets);
                }
            }
        //}

        return tzd;
    }//function getZone()


    /**
    * Extract abbreviations dictionary.
    * Returns position of next byte after last byte of abbreviations dictionary.
    *
    */
    static private inline function extractAbbreviations (bytes:Bytes, pos:Int, abrs:Array<TZAbr>) : Int {
        var count = bytes.get(pos ++);
        abrs[count - 1] = null;

        var length,length_isDst : Int;
        var isDst : Bool;
        var name  : String;
        for (i in 0...count) {
            length = bytes.get(pos ++);

            name = bytes.getString(pos, length);
            pos += length;

            abrs[i] = new TZAbr(name, i);//, isDst);
        }

        return pos;
    }//function extractAbbreviations()


    /**
    * Extract offsets dictionary.
    * Returns position of next byte after last byte of offsets dictionary.
    *
    */
    static private function extractOffsets (bytes:Bytes, pos:Int, offsets:Array<Int>) : Int {
        var offset : Int;
        var count = bytes.get(pos ++);
        offsets[count - 1] = 0;

        for (i in 0...count) {

            //offset divisible by 15 minutes
            if (bytes.get(pos) == 0xFF) {
                pos ++;
                offset = bytes.get(pos ++);
                if (offset >= 100) {
                    offset = -(offset - 100);
                }
                offset *= 900;

            //plain float
            } else {
                offset = Std.int(bytes.getFloat(pos));
                pos += 4;
            }

            offsets[i] = offset;
        }

        return pos;
    }//function extractOffsets()


    /**
    * Extract DstRule from position `pos` at `bytes` and assign it to `periods` at index `idx`
    * Returns position of next byte after last byte of extracted DstRule
    *
    */
    static private function extractDstRule (bytes:Bytes, pos:Int, periods:Array<IPeriod>, idx:Int, abrs:Array<TZAbr>, offsets:Array<Int>) : Int {
        var rule = new DstRule();

        var southernHemisphere = (bytes.get(pos ++ ) == 0xFF);

        pos = extractUtc(bytes, pos, rule);

        var wday = bytes.get(pos ++);
        rule.wdayToDst   = Std.int(wday / 10);
        rule.wdayFromDst = wday - rule.wdayToDst * 10;

        var wdayNum = bytes.get(pos ++);
        rule.wdayNumToDst   = Std.int(wdayNum / 10);
        rule.wdayNumFromDst = wdayNum - rule.wdayNumToDst * 10;
        if (rule.wdayNumToDst > 5) {
            rule.wdayNumToDst -= 10;
        }
        if (rule.wdayNumFromDst > 5) {
            rule.wdayNumFromDst -= 10;
        }

        var month = bytes.get(pos ++);
        if (southernHemisphere) {
            rule.monthToDst   = Std.int(month / 10);
            rule.monthFromDst = month - rule.monthToDst * 10;
        } else {
            rule.monthFromDst = Std.int(month / 10);
            rule.monthToDst   = month - rule.monthFromDst * 10;
        }

        //timeToDst
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
        rule.timeToDst = h * 3600 + m * 60 + s;

        //timeFromDst
        h = bytes.get(pos ++);
        m = 0;
        s = 0;
        if (h < 100) {
            m = bytes.get(pos ++);
            s = bytes.get(pos ++);
        } else if (h < 200) {
            h -= 100;
            m = bytes.get(pos ++);
        } else {
            h -= 200;
        }
        rule.timeFromDst = h * 3600 + m * 60 + s;

        var offAbrDst  = bytes.get(pos ++);
        var offsetIdx  = Std.int(offAbrDst / 10);
        var abrIdx     = offAbrDst - offsetIdx * 10;
        rule.offsetDst = offsets[offsetIdx];
        rule.abrDst    = abrs[abrIdx].name;

        var offAbr    = bytes.get(pos ++);
        var offsetIdx = Std.int(offAbr / 10);
        var abrIdx    = offAbr - offsetIdx * 10;
        rule.offset   = offsets[offsetIdx];
        rule.abr      = abrs[abrIdx].name;

        periods[idx] = rule;

        return pos;
    }//function extractDstRule()


    /**
    * Extract TZPeriod from position `pos` at `bytes` and assign it to `periods` at index `idx`
    * Returns position of next byte after last byte of extracted TZPeriod
    *
    */
    static private function extractTZPeriod (bytes:Bytes, pos:Int, periods:Array<IPeriod>, idx:Int, abrs:Array<TZAbr>, offsets:Array<Int>) : Int {
        var period = new TZPeriod();

        period.isDst = (bytes.get(pos ++) == 1);

        pos = extractUtc(bytes, pos, period);

        var offAbr    = bytes.get(pos ++);

        var offsetIdx = Std.int(offAbr / 10);
        var abrIdx    = offAbr - offsetIdx * 10;
        var abr       = abrs[abrIdx];

        period.offset = offsets[offsetIdx];
        period.abr    = abr.name;

        periods[idx] = period;

        return pos;
    }//function extractTZPeriod


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