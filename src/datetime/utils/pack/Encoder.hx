package datetime.utils.pack;

import datetime.utils.pack.DstRule;
import datetime.utils.pack.TZPeriod;
import haxe.crypto.Base64;
import haxe.io.BytesBuffer;
import datetime.DateTime;
import haxe.zip.Compress;



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

        var abrs    : Map<String,Int> = collectAbbreviations(records);
        var offsets : Map<Int,Int>    = collectOffsets(records);
        var periods : Array<IPeriod>  = setDstRules(records);

        //pack periods to bytes buffer {
            var count = periods.length;

            buf.addByte(name.length);
            buf.addString(name);
            buf.addByte(count);

            //add abbreviations dictionary {
                var abrArr : Array<String> = [];
                for (abr in abrs.keys()) {
                    abrArr[abrs.get(abr)] = abr;
                }

                buf.addByte(abrArr.length);
                for (i in 0...abrArr.length) {
                    buf.addByte(abrArr[i].length);
                    buf.addString(abrArr[i]);
                }
            //}

            //add offsets dictionary {
                var offsetArr : Array<Int> = [];
                for (offset in offsets.keys()) {
                    offsetArr[offsets.get(offset)] = offset;
                }

                buf.addByte(offsetArr.length);
                for (i in 0...offsetArr.length) {
                    // buf.addFloat(offsetArr[i]);
                    if (Std.int(offsetArr[i] / 1800) * 1800 == offsetArr[i]) {
                        buf.addByte(1);
                        buf.addByte(Std.int(offsetArr[i] / 1800) + (offsetArr[i] < 0 ? 100 : 0));
                    } else {
                        buf.addByte(0);
                        buf.addFloat(offsetArr[i]);
                    }
                }
            //}

            for (i in 0...count) {
                if (Std.is(periods[i], TZPeriod)) {
                    addTZPeriod(buf, cast periods[i], abrs, offsets);

                } else {
                    addDstRule(buf, cast periods[i], abrs, offsets);
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

            if (rec2.isDst != rec1.isDst && rec2.utc.getTime() - rec1.utc.getTime() <= 1) {
                records.splice(i, 1);
            } else {
                i ++;
            }
        }
    }//function removeDuplicates()


    /**
    * Collect possible abbreviations for timezone described by `records` data
    *
    */
    static private function collectAbbreviations (records:Array<TZPeriod>) : Map<String,Int> {
        var abrs = new Map<String,Int>();

        var cnt = 0;
        for (rec in records) {
            if (!abrs.exists(rec.abr)) {
                abrs.set(rec.abr, cnt);
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
    * Find and periods of strict rules for changing to/from DST and build a list of
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

            wdayToDst      = localToDst.getWeekDay();
            wdayFromDst    = localFromDst.getWeekDay();
            wdayNumToDst   = getDayNum(localToDst);
            wdayNumFromDst = getDayNum(localFromDst);
            monthToDst     = toDst.utc.getMonth();
            monthFromDst   = fromDst.utc.getMonth();
            timeToDst      = localToDst.getHour() * 3600 + localToDst.getMinute() * 60 + localToDst.getSecond();
            timeFromDst    = localFromDst.getHour() * 3600 + localFromDst.getMinute() * 60 + localFromDst.getSecond();
            offsetDst      = toDst.offset;
            offset         = fromDst.offset;
            abrDst         = toDst.abr;
            abr            = fromDst.abr;

            rule = new DstRule(
                start,
                wdayToDst,
                wdayFromDst,
                wdayNumToDst,
                wdayNumFromDst,
                monthToDst,
                monthFromDst,
                timeToDst,
                timeFromDst,
                offsetDst,
                offset,
                abrDst,
                abr
            );

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
    * Pack TZPeriod to bytes buffer
    *
    * Returns amount of bytes written
    */
    static private function addTZPeriod (buf:BytesBuffer, period:TZPeriod, abrMap:Map<String,Int>, offsetMap:Map<Int,Int>) : Int {
        var c = 0;

        // //isDst
        // buf.addByte(period.isDst ? 1 : 0);
        //utc
        c += addUtc(buf, period.utc);
        // buf.addFloat(period.utc.getTime());
        // buf.addFloat(period.utc.getTime());

        var offAbr = offsetMap.get(period.offset) * 10 + abrMap.get(period.abr);
        buf.addByte(offAbr);
        c ++;

        // //abr
        // buf.addByte(abrMap.get(period.abr));
        // //offset
        // buf.addByte(offsetMap.get(period.offset));

        return c;
    }//function addTZPeriod()


    /**
    * Pack DstRule to bytes buffer
    *
    * Returns amount of bytes written
    */
    static private function addDstRule (buf:BytesBuffer, rule:DstRule, abrMap:Map<String,Int>, offsetMap:Map<Int,Int>) : Int {
        var c = 0;
        //marker, this is DstRule
        buf.addByte(2);
        c++;
        //utc
        c += addUtc(buf, rule.utc);
        // buf.addFloat(rule.utc.getTime());
        // buf.addFloat(rule.utc.getTime());

        var wday = rule.wdayToDst * 10 + rule.wdayFromDst;
        buf.addByte(wday);
        c ++;

        // //wdayToDst
        // buf.addByte(rule.wdayToDst);
        // //wdayFromDst
        // buf.addByte(rule.wdayFromDst);

        var wdayNum = (rule.wdayNumToDst < 0 ? 10 + rule.wdayNumToDst : rule.wdayNumToDst) * 10 + (rule.wdayNumFromDst < 0 ? 10 + rule.wdayNumFromDst : rule.wdayNumFromDst);
        buf.addByte(wdayNum);
        c ++;

        // //wdayNumToDst
        // buf.addByte(rule.wdayNumToDst < 0 ? 10 - rule.wdayNumToDst : rule.wdayNumToDst);
        // //wdayNumFromDst
        // buf.addByte(rule.wdayNumFromDst < 0 ? 10 - rule.wdayNumFromDst : rule.wdayNumFromDst);

        var month = rule.monthToDst + rule.monthFromDst * 10;
        buf.addByte(month);
        c ++;

        // //monthToDst
        // buf.addByte(rule.monthToDst);
        // //monthFromDst
        // buf.addByte(rule.monthFromDst);

        c += addTime(buf, rule.timeToDst);
        c += addTime(buf, rule.timeFromDst);
        // if (Std.int(rule.timeToDst / 1800) * 1800 == rule.timeToDst && Std.int(rule.timeFromDst / 1800) * 1800 == rule.timeFromDst) {
        //     buf.addByte(0xFF);
        //     buf.addByte(Std.int(rule.timeToDst / 1800));
        //     buf.addByte(Std.int(rule.timeFromDst / 1800));
        // } else {
        //     // timeToDst
        //     buf.addByte(rule.timeToDst >> 16);
        //     buf.addByte((rule.timeToDst >> 8) & 0xFF);
        //     buf.addByte(rule.timeToDst & 0xFF);
        //     //timeFromDst
        //     buf.addByte(rule.timeFromDst >> 16);
        //     buf.addByte((rule.timeFromDst >> 8) & 0xFF);
        //     buf.addByte(rule.timeFromDst & 0xFF);
        // }

        var offAbrDst = offsetMap.get(rule.offset) * 10 + abrMap.get(rule.abr);
        buf.addByte(offAbrDst);
        c ++;

        var offAbr = offsetMap.get(rule.offset) * 10 + abrMap.get(rule.abr);
        buf.addByte(offAbr);
        c ++;

        // //offsetDst
        // buf.addByte(offsetMap.get(rule.offsetDst));
        // //offset
        // buf.addByte(offsetMap.get(rule.offset));
        // //abrDst
        // buf.addByte(abrMap.get(rule.abrDst));
        // //abr
        // buf.addByte(abrMap.get(rule.abr));

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
            if (s < 100) {
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