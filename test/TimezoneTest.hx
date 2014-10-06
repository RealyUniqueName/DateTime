package ;

import datetime.DateTimeInterval;
import datetime.Timezone;
import haxe.unit.TestCase;
import haxe.unit.TestRunner;
import datetime.DateTime;


/**
* DateTimeInterval module tests
*
*/
class TimezoneTest extends TestCase {


    /**
    * Test local <--> utc conversions
    *
    */
    public function testLocalUtc () : Void {
        var tz = Timezone.get('America/New_York');

        var stOffset  = -18000;
        var dstOffset = -14400;

        //according to TZ DB switch to DST in New York happens on second Sunday of March at 07:00 UTC
        for (month in 2...5) {
            for (day in 1...(DateTime.daysInMonth(month) + 1)) {
                for (hour in [0, 6, 7, 8, 23]) {
                    for (minute in [0, 30, 59]) {
                        for (second in [0, 30, 59]) {
                            var utc   = DateTime.make(2013, month, day, hour, minute, second);
                            var local = tz.at(utc);

                            if (month == 2 || !tz.isDst(utc)) {
                                assertEquals(local.getTime() - utc.getTime(), stOffset);

                            } else {
                                assertEquals(local.getTime() - utc.getTime(), dstOffset);
                            }

                            var utc2 = tz.utc(local);
                            assertTrue(utc == utc2);
                        }
                    }
                }
            }
        }
    }//function testLocalUtc()


    /**
    * Test `format()` method
    *
    */
    public function testAll () : Void {
        var utc : DateTime = '2014-02-06 16:41:09';

        var moscow  = Timezone.get('Europe/Moscow');
        var newYork = Timezone.get('America/New_York');

        assertEquals('2014-02-06T20:41:09+04:00 +0400 MSK', moscow.format(utc, '%q %z %Z'));
        assertEquals('2014-02-06T11:41:09-05:00 -0500 EST', newYork.format(utc, '%q %z %Z'));
    }//function testAll()

}//class TimezoneTest