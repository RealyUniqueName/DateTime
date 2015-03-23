package datetime.utils.pack;

import datetime.utils.pack.DstRule;
import datetime.utils.pack.TZPeriod;
import haxe.crypto.Base64;
import haxe.io.BytesBuffer;
import datetime.DateTime;
// import haxe.zip.Compress;



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
        var periods : Array<IPeriod>  = setDstRules(records);

        // //pack periods to bytes buffer {
        //     var count = periods.length;

        //     buf.addByte(name.length);
        //     buf.addString(name);
        //     buf.addFloat(count);

        //     var period : TZPeriod;
        //     var rule   : DstRule;
        //     for (i in 0...count) {
        //         buf.addFloat(data.time[i]);
        //         buf.addFloat(data.offset[i] == null ? 0 : data.offset[i]);
        //         buf.addByte(data.abr[i].length);
        //         buf.addString(data.abr[i]);
        //         buf.addByte(data.isDst[i] ? 1 : 0);
        //     }
        // //}
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
            if (lastIdx - startIdx >= 3) {
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


    // /**
    // * Writes timezone data to `buf`
    // *
    // */
    // static public function addZone (buf:BytesBuffer, name:String, data:TZoneData) : Void {
    //     var count = data.time.length;

    //     buf.addByte(name.length);
    //     buf.addString(name);
    //     buf.addFloat(count);

    //     for (i in 0...count) {
    //         buf.addFloat(data.time[i]);
    //         buf.addFloat(data.offset[i] == null ? 0 : data.offset[i]);
    //         buf.addByte(data.abr[i].length);
    //         buf.addString(data.abr[i]);
    //         buf.addByte(data.isDst[i] ? 1 : 0);
    //     }
    // }//function addZone()


    // /**
    // * Writes timezone DST rules to `buf`
    // *
    // */
    // static public function addZoneLight (buf:BytesBuffer, name:String, rules:Array<TZDstRecord>) : Void {
    //     var count = rules.length;

    //     buf.addByte(name.length);
    //     buf.addString(name);
    //     buf.addFloat(count);

    //     for (i in 0...count) {
    //         buf.addFloat(rules[i].time);
    //         buf.addFloat(rules[i].offset == null ? 0 : rules[i].offset);
    //         buf.addByte(rules[i].abr.length);
    //         buf.addString(rules[i].abr);
    //         buf.addByte(rules[i].isDst ? 1 : 0);
    //         buf.addByte(rules[i].wday);
    //         buf.addFloat(rules[i].wdayNum);
    //         buf.addByte(rules[i].month);
    //         buf.addFloat(rules[i].time);
    //     }
    // }//function addZoneLight()


    // /**
    // * Encode collected timezones data to string
    // *
    // */
    // static public function encode (buf:BytesBuffer) : String {
    //     return Base64.encode(Compress.run(buf.getBytes(), 4));
    // }//function encode()

}//class Encoder