package datetime.utils.pack;

import datetime.utils.pack.DstRule;
import datetime.utils.pack.TZPeriod;
import haxe.crypto.Base64;
import haxe.io.BytesBuffer;
import datetime.DateTime;
import haxe.zip.Compress;

using Lambda;
using datetime.utils.pack.Decoder;


/**
* Pack timezones data
*
*/
class Encoder {


    /**
    * Add timezone data to `buf`
    *
    */
    static public function addZone (buf:BytesBuffer, name:String, records:Array<TZPeriod>) : Void {
        removeDuplicates(records);

        var abrs    : Map<String,TZAbr> = collectAbbreviations(records);
        var offsets : Map<Int,Int>    = collectOffsets(records);
        var periods : Array<IPeriod>  = setDstRules(records);

        buf.addByte(name.length);
        buf.addString(name);

        var data = new BytesBuffer();
        addAbbreviations(data, abrs);
        addOffsets(data, offsets);

        //pack periods to bytes buffer {
            var count = periods.length;
            data.addByte(count);

            for (i in 0...count) {
                if (Std.is(periods[i], TZPeriod)) {
                    addTZPeriod(data, cast periods[i], abrs, offsets);

                } else {
                    addDstRule(data, cast periods[i], abrs, offsets);
                }
            }
        //}

        var bytes = data.getBytes();
        buf.addFloat(bytes.length);
        buf.add(bytes);

        //ensure everything will be decoded as expected {
            var decodedPeriods = bytes.getZone(0).periods;
            if (decodedPeriods.length != count) {
                throw 'Encoding or decoding works incorrectly for $name timezone.';
            }
            for (i in 0...count) {
                // if (name == 'America/Barbados') {
                //     Sys.println('');
                //     Sys.println(periods[i].toString());
                //     Sys.println(decodedPeriods[i].toString());
                //     Sys.println('');
                // }
                if (periods[i].toString() != decodedPeriods[i].toString()) {
                    Sys.println('');
                    Sys.println(periods[i].toString());
                    Sys.println(decodedPeriods[i].toString());
                    Sys.println('');

                    throw 'Encoding or decoding works incorrectly for $name timezone.';
                }
            }
        //}
    }//function addZone()


    /**
    * Every switch to/from DST in iana tz database has two records with difference in one second.
    * Remove remove one record from each pair to reduce database size.
    *
    */
    static private function removeDuplicates (records:Array<TZPeriod>) : Void {
        var i = 0;
        var rec1, rec2;

        while (i < records.length - 1) {
            rec1 = records[i];
            rec2 = records[i + 1];

            if (rec2.utc.getTime() - rec1.utc.getTime() <= 1) {
                var r = records.splice(i, 1)[0];
            }

            i ++;
        }
    }//function removeDuplicates()


    /**
    * Collect possible abbreviations for timezone described by `records` data
    *
    */
    static private function collectAbbreviations (records:Array<TZPeriod>) : Map<String,TZAbr> {
        var abrs = new Map<String,TZAbr>();

        var cnt = 0;
        for (rec in records) {
            if (!abrs.exists(rec.abr)) {
                abrs.set(rec.abr, new TZAbr(rec.abr, cnt/*, rec.isDst*/));
                cnt ++;
            }
        }

        return abrs;
    }//function collectAbbreviations()


    /**
    * Collect possible offsets for timezone described by `records` data
    *
    */
    static private function collectOffsets (records:Array<TZPeriod>) : Map<Int,Int> {
        var offsets = new Map<Int,Int>();

        var cnt = 0;
        for (rec in records) {
            if (!offsets.exists(rec.offset)) {
                offsets.set(rec.offset, cnt);
                cnt ++;
            }
        }

        return offsets;
    }//function collectOffsets()


    /**
    * Find periods of strict rules for changing to/from DST and build a list of
    * periods in timezone using found rules.
    *
    */
    static private function setDstRules (records:Array<TZPeriod>) : Array<IPeriod> {
        var periods : Array<IPeriod> = [];

        /** day of week to switch to DST (0 for Sunday) */
        var wdayToDst : Int;
        /** day of week to switch to non-DST */
        var wdayFromDst : Int;
        /**
        * Which one of specified days in month is required to switch to DST.
        * E.g. second Sunday. -1 for last one in this month.
        */
        var wdayNumToDst : Int;
        /**
        * Which one of specified days in month is required to switch to DST.
        * E.g. second Sunday. -1 for last one in this month.
        */
        var wdayNumFromDst : Int;
        /** Month in wich time is switching to DST */
        var monthToDst : Int;
        /** Month in wich time is switching from DST */
        var monthFromDst : Int;
        /** Local hour,minute,second to switch to DST (in seconds) */
        var timeToDst : Int;
        /** Local hour,minute,second to switch from DST (in seconds) */
        var timeFromDst : Int;
        /** Time offset during DST phase */
        var offsetDst : Int;
        /** Time offset during non-DST phase */
        var offset : Int;
        /** Timezone abbreviation for DST phase */
        var abrDst : String;
        /** Timezone abbreviation for non-DST phase */
        var abr : String;

        var idx = 0;
        var qdx = 0;
        var startIdx,lastIdx : Int;
        var start,toDst,fromDst,estimated,localToDst,localFromDst : DateTime;
        var rule : DstRule;

        while (idx < records.length - 1) {
            toDst   = records[idx];
            fromDst = records[idx + 1];

            //it's not a part of DST rule period
            if (toDst.isDst == fromDst.isDst) {
                idx ++;
                periods.push(toDst);
                continue;
            }

            startIdx = idx;

            if (!toDst.isDst) {
                toDst      = fromDst;
                fromDst    = records[idx];
                start      = fromDst.utc;
            } else {
                start      = toDst.utc;
            }

            localToDst   = toDst.utc + Second(toDst.offset);
            localFromDst = fromDst.utc + Second(fromDst.offset);

            rule = new DstRule();
            rule.utc = start;
            rule.wdayToDst      = localToDst.getWeekDay();
            rule.wdayFromDst    = localFromDst.getWeekDay();
            rule.wdayNumToDst   = getDayNum(localToDst);
            rule.wdayNumFromDst = getDayNum(localFromDst);
            rule.monthToDst     = toDst.utc.getMonth();
            rule.monthFromDst   = fromDst.utc.getMonth();
            rule.timeToDst      = localToDst.getHour() * 3600 + localToDst.getMinute() * 60 + localToDst.getSecond();
            rule.timeFromDst    = localFromDst.getHour() * 3600 + localFromDst.getMinute() * 60 + localFromDst.getSecond();
            rule.offsetDst      = toDst.offset;
            rule.offset         = fromDst.offset;
            rule.abrDst         = toDst.abr;
            rule.abr            = fromDst.abr;
if (rule.utc.getYear() > 2014) {
    Sys.println('');
    Sys.println(rule.toString());
}
            estimated = start;
            lastIdx   = startIdx;

            qdx = idx;
            do {
                estimated = rule.estimatedSwitch(estimated);
                qdx ++;

                if (
                    estimated != records[qdx].utc
                    || records[qdx - 1].isDst == records[qdx].isDst
                    || (records[qdx].isDst  && records[qdx].offset != toDst.offset)
                    || (!records[qdx].isDst && records[qdx].offset != fromDst.offset)
                ) {
if (rule.utc.getYear() > 2014) {
    Sys.println({est:estimated.toString(), expected: records[qdx].utc.toString()});
}
                    lastIdx = qdx - 1;
                    break;
                }

            } while (qdx < records.length - 1);

            //found long enough DST-rule period
            if (lastIdx - startIdx >= 2) {
                periods.push(rule);
                idx = lastIdx + 1;
            } else {
                periods.push(records[idx]);
                idx ++;
            }

        }

        return periods;
    }//function setDstRules()


    /**
    * Find number of week day in month. E.g. second Sunday or first Wednesday or last Monday etc.
    *
    */
    static private function getDayNum (dt:DateTime) : Int {
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


    /**
    * Pack abbreviations dictionary to bytes buffer
    *
    */
    static private function addAbbreviations (buf:BytesBuffer, abrs:Map<String,TZAbr>) : Void {
        var count = abrs.count();
        buf.addByte(count);

        for (i in 0...count) {
            for (abr in abrs) {
                if (abr.idx == i) {
                    buf.addByte(abr.name.length);// + (abr.isDst ? 0 : 100));
                    buf.addString(abr.name);
                }
            }
        }
    }//function addAbbreviations()


    /**
    * Pack offsets dictionary to bytes buffer
    *
    */
    static private function addOffsets (buf:BytesBuffer, offsets:Map<Int,Int>) : Void {
        var offsetArr : Array<Int> = [];
        for (offset in offsets.keys()) {
            offsetArr[offsets.get(offset)] = offset;
        }

        var value : Int;
        buf.addByte(offsetArr.length);
        for (i in 0...offsetArr.length) {
            //if offset is divisible by 15 minutes, pack it as 2 bytes
            if (Std.int(offsetArr[i] / 900) * 900 == offsetArr[i]) {
                buf.addByte(0xFF);
                value = Std.int(offsetArr[i] / 900) - (offsetArr[i] < 0 ? 100 : 0);
                buf.addByte(value < 0 ? -value : value);
            } else {
                buf.addFloat(offsetArr[i]);
            }
        }
    }//function addOffsets()


    /**
    * Pack TZPeriod to bytes buffer
    *
    * Returns amount of bytes written
    */
    static private function addTZPeriod (buf:BytesBuffer, period:TZPeriod, abrMap:Map<String,TZAbr>, offsetMap:Map<Int,Int>) : Int {
        var c = 0;

        //isDst
        buf.addByte(period.isDst ? 1 : 0);
        c ++;

        //utc
        c += addUtc(buf, period.utc);
        // pos = extractUtc(bytes, pos, rule);

        //abr + offset
        var offAbr = offsetMap.get(period.offset) * 10 + abrMap.get(period.abr).idx;
        buf.addByte(offAbr);
        c ++;


        return c;
    }//function addTZPeriod()


    /**
    * Pack DstRule to bytes buffer
    *
    * Returns amount of bytes written
    */
    static private function addDstRule (buf:BytesBuffer, rule:DstRule, abrMap:Map<String,TZAbr>, offsetMap:Map<Int,Int>) : Int {
        var c = 0;
        //marker, this is DstRule
        buf.addByte(0xFF);
        c++;

        //utc
        c += addUtc(buf, rule.utc);

        //wday
        var wday = rule.wdayToDst * 10 + rule.wdayFromDst;
        buf.addByte(wday);
        c ++;

        //wdayNum
        var wdayNum = (rule.wdayNumToDst < 0 ? 10 + rule.wdayNumToDst : rule.wdayNumToDst) * 10 + (rule.wdayNumFromDst < 0 ? 10 + rule.wdayNumFromDst : rule.wdayNumFromDst);
        buf.addByte(wdayNum);
        c ++;

        //month
        var month = rule.monthToDst + rule.monthFromDst * 10;
        buf.addByte(month);
        c ++;

        //timeToDst
        c += addTime(buf, rule.timeToDst);
        //timeFromDst
        c += addTime(buf, rule.timeFromDst);

        //abrDst + offsetDst
        var offAbrDst = offsetMap.get(rule.offsetDst) * 10 + abrMap.get(rule.abrDst).idx;
        buf.addByte(offAbrDst);
        c ++;

        //abr + offset
        var offAbr = offsetMap.get(rule.offset) * 10 + abrMap.get(rule.abr).idx;
        buf.addByte(offAbr);
        c ++;

        return c;
    }//function addDstRule()


    /**
    * Write `utc` to bytes buffer
    *
    * Returns amount of bytes written
    */
    static private function addUtc (buf:BytesBuffer, utc:DateTime) : Int {
        buf.addByte(utc.getYear() - 1900);
        buf.addByte(utc.getMonth());
        buf.addByte(utc.getDay());

        var c = 3;

        var h = utc.getHour();
        var m = utc.getMinute();
        var s = utc.getSecond();

        c += addTime(buf, h * 3600 + m * 60 + s);

        return c;
    }//function addUtc()


    /**
    * Write `time` to bytes buffer
    *
    * 1. If seconds == 0, add 100 to hours
    * 2. If minutes == 0, add 100 to hours
    * 3. Write hours to buffer
    * 4. If hours < 200, write minutes to buffer
    * 5. If hours < 100, write seconds to buffer
    *
    * Returns amount of bytes written
    */
    static private function addTime (buf:BytesBuffer, time:Int) : Int {
        var c = 0;

        var h = Std.int(time / 3600);
        var m = Std.int((time - h * 3600) / 60);
        var s = time - h * 3600 - m * 60;

        if (s == 0) {
            h += 100;
            if (m == 0) {
                h += 100;
            }
        }

        buf.addByte(h);
        c ++;
        if (h < 200) {
            buf.addByte(m);
            c ++;
            if (h < 100) {
                buf.addByte(s);
                c ++;
            }
        }

        return c;
    }//function addTime()


    /**
    * Encode collected timezones data to string
    *
    */
    static public function encode (buf:BytesBuffer) : String {
        return Base64.encode(Compress.run(buf.getBytes(), 4));
        // return Base64.encode(buf.getBytes());
    }//function encode()

}//class Encoder