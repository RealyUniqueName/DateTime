package ;

import haxe.unit.TestCase;
import haxe.unit.TestRunner;
import datetime.DateTime;


/**
* DateTime module tests
*
*/
class DateTimeTest extends TestCase {

    /** 2014-09-15 17:51:35 */
    static public inline var STAMP_01 = 1410803495;
    /** 1973-01-01 00:00:00 */
    static public inline var STAMP_02 = 94694400;
    /** 2014-08-31 23:59:59 */
    static public inline var STAMP_03 = 1409529599;
    /** 2012-02-29 00:00:00 */
    static public inline var STAMP_04 = 1330473600;
    /** 1972-02-29 23:59:59 */
    static public inline var STAMP_05 = 68255999;
    /** 1970-03-01 00:00:00 */
    static public inline var STAMP_06 = 5097600;
    /** 1967-01-01 00:00:00 */
    static public inline var STAMP_07 = -94694400;
    /** 1964-06-15 19:48:32 */
    static public inline var STAMP_08 = -174975088;


    /**
    * Test year-related methods
    *
    */
    public function testYear () : Void {

        // 2014-09-15 17:51:35
        var dt = new DateTime(STAMP_01);
        assertEquals(2014, dt.getYear());
        assertFalse(dt.isLeapYear());
        assertEquals(1388534400.0, dt.yearStart());

        // 1973-01-01 00:00:00
        var dt = new DateTime(STAMP_02);
        assertEquals(1973, dt.getYear());
        assertFalse(dt.isLeapYear());
        assertEquals(STAMP_02 * 1.0, dt.yearStart());

        // 2014-08-31 23:59:59
        var dt = new DateTime(STAMP_03);
        assertEquals(2014, dt.getYear());
        assertFalse(dt.isLeapYear());
        assertEquals(1388534400.0, dt.yearStart());

        // 2012-02-29 00:00:00
        var dt = new DateTime(STAMP_04);
        assertEquals(2012, dt.getYear());
        assertTrue(dt.isLeapYear());
        assertEquals(1325376000.0, dt.yearStart());

        // 1972-02-29 23:59:59
        var dt = new DateTime(STAMP_05);
        assertEquals(1972, dt.getYear());
        assertTrue(dt.isLeapYear());
        assertEquals(63072000.0, dt.yearStart());

        // 1970-03-01 00:00:00
        var dt = new DateTime(STAMP_06);
        assertEquals(1970, dt.getYear());
        assertFalse(dt.isLeapYear());
        assertEquals(0.0, dt.yearStart());

        // 1967-01-01 00:00:00
        var dt = new DateTime(STAMP_07);
        assertEquals(1967, dt.getYear());
        assertFalse(dt.isLeapYear());
        assertEquals(STAMP_07 * 1.0, dt.yearStart());

        // 1964-06-15 19:48:32
        var dt = new DateTime(STAMP_08);
        assertEquals(1964, dt.getYear());
        assertTrue(dt.isLeapYear());
        assertEquals(-189388800.0, dt.yearStart());

    }//function testYear()


    /**
    * Test month-related methods
    *
    */
    public function testMonth () : Void {
        // // 2014-09-15 17:51:35
        var dt = new DateTime(STAMP_01);
        assertEquals(9, dt.getMonth());

        // 1973-01-01 00:00:00
        var dt = new DateTime(STAMP_02);
        assertEquals(1, dt.getMonth());

        // 2014-08-31 23:59:59
        var dt = new DateTime(STAMP_03);
        assertEquals(8, dt.getMonth());

        // 2012-02-29 00:00:00
        var dt = new DateTime(STAMP_04);
        assertEquals(2, dt.getMonth());

        // 1972-02-29 23:59:59
        var dt = new DateTime(STAMP_05);
        assertEquals(2, dt.getMonth());

        // 1970-03-01 00:00:00
        var dt = new DateTime(STAMP_06);
        assertEquals(3, dt.getMonth());

        // 1967-01-01 00:00:00
        var dt = new DateTime(STAMP_07);
        assertEquals(1, dt.getMonth());

        // 1964-06-15 19:48:32
        var dt = new DateTime(STAMP_08);
        assertEquals(6, dt.getMonth());
    }//function testMonth()


    /**
    * Test day-related methods
    *
    */
    public function testDay () : Void {
        // 2014-09-15 17:51:35
        var dt = new DateTime(STAMP_01);
        assertEquals(15, dt.getDay());

        // 1973-01-01 00:00:00
        var dt = new DateTime(STAMP_02);
        assertEquals(1, dt.getDay());

        // 2014-08-31 23:59:59
        var dt = new DateTime(STAMP_03);
        assertEquals(31, dt.getDay());

        // 2012-02-29 00:00:00
        var dt = new DateTime(STAMP_04);
        assertEquals(29, dt.getDay());

        // 1972-02-29 23:59:59
        var dt = new DateTime(STAMP_05);
        assertEquals(29, dt.getDay());

        // 1970-03-01 00:00:00
        var dt = new DateTime(STAMP_06);
        assertEquals(1, dt.getDay());

        // 1967-01-01 00:00:00
        var dt = new DateTime(STAMP_07);
        assertEquals(1, dt.getDay());

        // 1964-06-15 19:48:32
        var dt = new DateTime(STAMP_08);
        assertEquals(15, dt.getDay());
    }//function testDay()


    /**
    * Test hour-related methods
    *
    */
    public function testHour () : Void {
        // 2014-09-15 17:51:35
        var dt = new DateTime(STAMP_01);
        assertEquals(17, dt.getHour());

        // 1973-01-01 00:00:00
        var dt = new DateTime(STAMP_02);
        assertEquals(0, dt.getHour());

        // 2014-08-31 23:59:59
        var dt = new DateTime(STAMP_03);
        assertEquals(23, dt.getHour());

        // 2012-02-29 00:00:00
        var dt = new DateTime(STAMP_04);
        assertEquals(0, dt.getHour());

        // 1972-02-29 23:59:59
        var dt = new DateTime(STAMP_05);
        assertEquals(23, dt.getHour());

        // 1970-03-01 00:00:00
        var dt = new DateTime(STAMP_06);
        assertEquals(0, dt.getHour());

        // 1967-01-01 00:00:00
        var dt = new DateTime(STAMP_07);
        assertEquals(0, dt.getHour());

        // 1964-06-15 19:48:32
        var dt = new DateTime(STAMP_08);
        assertEquals(19, dt.getHour());
    }//function testHour()


    /**
    * Test minute-related methods
    *
    */
    public function testMinute () : Void {
        // 2014-09-15 17:51:35
        var dt = new DateTime(STAMP_01);
        assertEquals(51, dt.getMinute());

        // 1973-01-01 00:00:00
        var dt = new DateTime(STAMP_02);
        assertEquals(0, dt.getMinute());

        // 2014-08-31 23:59:59
        var dt = new DateTime(STAMP_03);
        assertEquals(59, dt.getMinute());

        // 2012-02-29 00:00:00
        var dt = new DateTime(STAMP_04);
        assertEquals(0, dt.getMinute());

        // 1972-02-29 23:59:59
        var dt = new DateTime(STAMP_05);
        assertEquals(59, dt.getMinute());

        // 1970-03-01 00:00:00
        var dt = new DateTime(STAMP_06);
        assertEquals(0, dt.getMinute());

        // 1967-01-01 00:00:00
        var dt = new DateTime(STAMP_07);
        assertEquals(0, dt.getMinute());

        // 1964-06-15 19:48:32
        var dt = new DateTime(STAMP_08);
        assertEquals(48, dt.getMinute());
    }//function testMinute()


    /**
    * Test second-related methods
    *
    */
    public function testSecond () : Void {
        // 2014-09-15 17:51:35
        var dt = new DateTime(STAMP_01);
        assertEquals(35, dt.getSecond());

        // 1973-01-01 00:00:00
        var dt = new DateTime(STAMP_02);
        assertEquals(0, dt.getSecond());

        // 2014-08-31 23:59:59
        var dt = new DateTime(STAMP_03);
        assertEquals(59, dt.getSecond());

        // 2012-02-29 00:00:00
        var dt = new DateTime(STAMP_04);
        assertEquals(0, dt.getSecond());

        // 1972-02-29 23:59:59
        var dt = new DateTime(STAMP_05);
        assertEquals(59, dt.getSecond());

        // 1970-03-01 00:00:00
        var dt = new DateTime(STAMP_06);
        assertEquals(0, dt.getSecond());

        // 1967-01-01 00:00:00
        var dt = new DateTime(STAMP_07);
        assertEquals(0, dt.getSecond());

        // 1964-06-15 19:48:32
        var dt = new DateTime(STAMP_08);
        assertEquals(32, dt.getSecond());
    }//function testSecond()


    /**
    * Test DateTime.now()
    *
    */
    public function testNow () : Void {
        assertEquals(Math.ffloor(Date.now().getTime() / 1000), DateTime.now().getTime());
    }//function testNow()


    /**
    * Test Date.make()
    *
    */
    public function testMake () : Void {
        // 2014-09-15 17:51:35
        var dt = DateTime.make(2014, 09, 15, 17, 51, 35);
        assertEquals(STAMP_01 * 1.0, dt.getTime());

        // 1973-01-01 00:00:00
        var dt = DateTime.make(1973);
        assertEquals(STAMP_02 * 1.0, dt.getTime());

        // 2014-08-31 23:59:59
        var dt = DateTime.make(2014, 08, 31, 23, 59, 59);
        assertEquals(STAMP_03 * 1.0, dt.getTime());

        // 2012-02-29 00:00:00
        var dt = DateTime.make(2012, 02, 29);
        assertEquals(STAMP_04 * 1.0, dt.getTime());

        // 1972-02-29 23:59:59
        var dt = DateTime.make(1972, 02, 29, 23, 59, 59);
        assertEquals(STAMP_05 * 1.0, dt.getTime());

        // 1970-03-01 00:00:00
        var dt = DateTime.make(1970, 03);
        assertEquals(STAMP_06 * 1.0, dt.getTime());

        // 1967-01-01 00:00:00
        var dt = DateTime.make(1967);
        assertEquals(STAMP_07 * 1.0, dt.getTime());

        // 1964-06-15 19:48:32
        var dt = DateTime.make(1964, 06, 15, 19, 48, 32);
        assertEquals(STAMP_08 * 1.0, dt.getTime());
    }//function testMake()


    /**
    * Test date-time arithmetics
    *
    */
    public function testMath () : Void {
        // 2012-02-29 00:00:00
        var dt = new DateTime(STAMP_04);

        assertEquals('2010-03-01 00:00:00', dt.add( Year(-2) ).toString());
        assertEquals('2012-03-29 00:00:00', dt.add( Month(1) ).toString());
        assertEquals('2012-12-03 00:00:00', dt.add( Month(9) ).add( Day(4) ).toString());
        assertEquals('2016-02-29 00:00:00', dt.add( Year(4) ).toString());
        assertEquals('2012-01-31 00:00:00', dt.add( Month(-1) ).add( Day(2) ).toString());
        assertEquals('2012-02-29 00:00:00', dt.add( Month(-1) ).add( Day(2) ).add( Month(1) ).toString());
        assertEquals('2013-03-01 04:00:00', dt.add( Hour(4) ).add( Year(1) ).toString());
        assertEquals('2012-02-29 00:45:00', dt.add( Minute(45) ).toString());
        assertEquals('2012-02-29 00:00:10', dt.add( Second(10) ).toString());
        assertEquals('2012-03-07 00:00:00', dt.add( Week(1) ).toString());
    }//function testMath()


    /**
    * Test snapping
    *
    */
    public function testSnap () : Void {
        /** 2014-09-15 17:51:35 */
        var dt = new DateTime(STAMP_01);

        assertEquals('2014-01-01 00:00:00', dt.snap( Year(Down) ).toString());
        assertEquals('2015-01-01 00:00:00', dt.snap( Year(Up) ).toString());
        assertEquals('2015-01-01 00:00:00', dt.snap( Year(Nearest) ).toString());

        assertEquals('2014-09-01 00:00:00', dt.snap( Month(Down) ).toString());
        assertEquals('2014-10-01 00:00:00', dt.snap( Month(Up) ).toString());
        assertEquals('2014-09-01 00:00:00', dt.snap( Month(Nearest) ).toString());

        assertEquals('2014-09-15 00:00:00', dt.snap( Day(Down) ).toString());
        assertEquals('2014-09-16 00:00:00', dt.snap( Day(Up) ).toString());
        assertEquals('2014-09-16 00:00:00', dt.snap( Day(Nearest) ).toString());

        assertEquals('2014-09-15 17:00:00', dt.snap( Hour(Down) ).toString());
        assertEquals('2014-09-15 18:00:00', dt.snap( Hour(Up) ).toString());
        assertEquals('2014-09-15 18:00:00', dt.snap( Hour(Nearest) ).toString());

        assertEquals('2014-09-15 17:51:00', dt.snap( Minute(Down) ).toString());
        assertEquals('2014-09-15 17:52:00', dt.snap( Minute(Up) ).toString());
        assertEquals('2014-09-15 17:52:00', dt.snap( Minute(Nearest) ).toString());

        assertEquals('2014-09-15 17:51:35', dt.snap( Second(Down) ).toString());
        assertEquals('2014-09-15 17:51:36', dt.snap( Second(Up) ).toString());
        assertEquals('2014-09-15 17:51:35', dt.snap( Second(Nearest) ).toString());

        assertEquals('2014-09-14 00:00:00', dt.snap( Week(Down, Sunday) ).toString());
        assertEquals('2014-09-21 00:00:00', dt.snap( Week(Up, Sunday) ).toString());
        assertEquals('2014-09-14 00:00:00', dt.snap( Week(Nearest, Sunday) ).toString());
        assertEquals('2014-09-15 00:00:00', dt.snap( Week(Down, Monday) ).toString());
        assertEquals('2014-09-22 00:00:00', dt.snap( Week(Up, Monday) ).toString());
        assertEquals('2014-09-15 00:00:00', dt.snap( Week(Nearest, Monday) ).toString());
        assertEquals('2014-09-11 00:00:00', dt.snap( Week(Down, Thursday) ).toString());
        assertEquals('2014-09-17 00:00:00', dt.snap( Week(Nearest, Wednesday) ).toString());
    }//function testSnap()


    /**
    * Test week-related methods
    *
    */
    public function testWeek () : Void {
        /** 2014-09-15 17:51:35 */
        assertEquals(1, new DateTime(STAMP_01).getWeekDay());
        assertEquals(38, new DateTime(STAMP_01).getWeek());

        /** 2014-08-31 23:59:59 */
        assertEquals(0, new DateTime(STAMP_03).getWeekDay());
        assertEquals(7, new DateTime(STAMP_03).getWeekDay(true));
        assertEquals(35, new DateTime(STAMP_03).getWeek());

        assertEquals(1, DateTime.fromString('2014-12-30').getWeek());
        assertEquals(52, DateTime.fromString('2012-01-01').getWeek());

        assertEquals(53, DateTime.weeksInYear(2015));
        assertEquals(52, DateTime.weeksInYear(2014));


        var dt : DateTime = '2014-09-26 17:39:43';
        assertEquals('2014-09-26 00:00:00', dt.getWeekDayNum(Friday, -1).toString());
        assertEquals('2014-09-19 00:00:00', dt.getWeekDayNum(Friday, -2).toString());
        assertEquals('2014-09-05 00:00:00', dt.getWeekDayNum(Friday, 1).toString());
        assertEquals('2014-09-12 00:00:00', dt.getWeekDayNum(Friday, 2).toString());
        assertEquals('2014-09-01 00:00:00', dt.getWeekDayNum(Monday, 1).toString());
        assertEquals('2014-09-30 00:00:00', dt.getWeekDayNum(Tuesday, -1).toString());
    }//function testWeek()


    /**
    * Test DateTime.format()
    *
    */
    public function testFormat () : Void {
        /** 1967-01-01 00:00:00 */
        var dt : DateTime = STAMP_07;

        //   %d  Two-digit day of the month (with leading zeros) 01 to 31
        assertEquals('01', dt.format('%d'));
        //   %e  Day of the month, with a space preceding single digits. 1 to 31
        assertEquals(' 1', dt.format('%e'));
        //   %j  Day of the year, 3 digits with leading zeros    001 to 366
        assertEquals('001', dt.format('%j'));
        //   %u  ISO-8601 numeric representation of the day of the week  1 (for Monday) though 7 (for Sunday)
        assertEquals('7', dt.format('%u'));
        //   %w  Numeric representation of the day of the week   0 (for Sunday) through 6 (for Saturday)
        assertEquals('0', dt.format('%w'));
        //   %m  Two digit representation of the month   01 (for January) through 12 (for December)
        assertEquals('01', dt.format('%m'));
        //   %C  Two digit representation of the century (year divided by 100, truncated to an integer)  19 for the 20th Century
        assertEquals('19', dt.format('%C'));
        //   %y  Two digit representation of the year    Example: 09 for 2009, 79 for 1979
        assertEquals('67', dt.format('%y'));
        //   %Y  Four digit representation for the year  Example: 2038
        assertEquals('1967', dt.format('%Y'));
        //   %H  Two digit representation of the hour in 24-hour format  00 through 23
        assertEquals('00', dt.format('%H'));
        //   %k  Two digit representation of the hour in 24-hour format, with a space preceding single digits    0 through 23
        assertEquals(' 0', dt.format('%k'));
        //   %I  Two digit representation of the hour in 12-hour format  01 through 12
        assertEquals('12', dt.format('%I'));
        assertEquals('01', dt.add(Hour(1)).format('%I'));
        //   %l  (lower-case 'L') Hour in 12-hour format, with a space preceding single digits    1 through 12
        assertEquals('12', dt.format('%l'));
        assertEquals(' 1', dt.add(Hour(1)).format('%l'));
        //   %M  Two digit representation of the minute  00 through 59
        assertEquals('00', dt.format('%M'));
        //   %p  UPPER-CASE 'AM' or 'PM' based on the given time Example: AM for 00:31, PM for 22:23
        assertEquals('AM', dt.format('%p'));
        //   %P  lower-case 'am' or 'pm' based on the given time Example: am for 00:31, pm for 22:23
        assertEquals('am', dt.format('%P'));
        //   %r  Same as "%I:%M:%S %p"   Example: 09:34:17 PM for 21:34:17
        assertEquals('12:00:00', dt.format('%r'));
        //   %R  Same as "%H:%M" Example: 00:35 for 12:35 AM, 16:44 for 4:44 PM
        assertEquals('00:00', dt.format('%R'));
        //   %S  Two digit representation of the second  00 through 59
        assertEquals('00', dt.format('%S'));
        //   %T  Same as "%H:%M:%S"  Example: 21:34:17 for 09:34:17 PM
        assertEquals('00:00:00', dt.format('%T'));
        //   %D  Same as "%m/%d/%y"  Example: 02/05/09 for February 5, 2009
        assertEquals('01/01/67', dt.format('%D'));
        //   %F  Same as "%Y-%m-%d" (commonly used in database datestamps)   Example: 2009-02-05 for February 5, 2009
        assertEquals('1967-01-01', dt.format('%F'));
        //   %s  Unix Epoch Time timestamp Example: 305815200 for September 10, 1979 08:40:00 AM
        assertEquals(STAMP_07 + '', dt.format('%s'));
        //   %%  A literal percentage character ("%")
        assertEquals('%', dt.format('%%'));

        assertEquals('+1967-01-01+00:00:00+', dt.format('+%F+%T+'));
    }//function testFormat()

    public function testFromIso8601String () : Void {
       var dateTimeFromIso = DateTime.fromIsoString('2014-12-07T20:14:15.253Z');
       var dateTime = DateTime.fromString('2014-12-07 20:14:15');
       assertEquals(dateTime.toString(), dateTimeFromIso.toString());
    }


/**
* :WARNING: These tests take A LOT of time.
*/
#if FULLTEST

    /**
    * Test DateTime.fromString()
    * Iterate through all date/time combinations from 1900-01-01 00:00:00 to 2100-12-31 23:59:59
    *
    */
    public function testFromString () : Void {
        var dt  : DateTime = 0;
        var str : String = null;

        var days : Int = 0;
        var dpm : Array<Int> = [
            31, //Jan
            28, //Feb
            31, //Mar
            30, //Apr
            31, //May
            30, //Jun
            31, //Jul
            31, //Aug
            30, //Sep
            31, //Oct
            30, //Nov
            31  //Dec
        ];

        var hr,sec,min;

        //years
        for (Y in 1900...2100) {

            //months
            for (M in 1...13) {
                days = dpm[M - 1] + (M == 2 && Y % 4 == 0 ? 1 : 0) + 1;

                //days
                for (D in 1...days) {

                    //hours
                    for (h in 0...3) {
                        hr = (h == 2 ? 23 : (h == 1 ? 12 : 0));

                        //minutes
                        for (m in 0...3) {
                            min = (m == 2 ? 59 : (m == 1 ? 15 : 0));

                            //seconds
                            for (s in 0...3) {
                                sec = (s == 2 ? 59 : (s == 1 ? 15 : 0));

                                str = '$Y-' + (M < 10 ? '0$M' : '$M') + '-' + (D < 10 ? '0$D' : '$D') + ' ' + (hr < 10 ? '0$hr' : '$hr') + ':' + (min < 10 ? '0$min' : '$min') + ':' + (sec < 10 ? '0$sec' : '$sec');
                                dt  = str;

                                assertEquals(str, dt.toString());
                            }
                        }
                    }
                }
            }
        }
    }//function testFromString()
#end

}//class DateTimeTest
