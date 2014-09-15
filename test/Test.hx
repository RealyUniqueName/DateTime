package test;

import haxe.unit.TestCase;
import haxe.unit.TestRunner;



/**
* Unit tests
*
*/
class Test extends TestCase {

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



    /**
    * Entry point
    *
    */
    static public function main () : Void {
        // Sys.command('php', ['-r', 'date_default_timezone_set("UTC");echo date("Y-m-d H:i:s", 1410803495);']);return;
        // Sys.command('php', ['-r', 'date_default_timezone_set("UTC");echo strtotime("2014-08-31 23:59:59");']);return;

        var runner = new TestRunner();
        runner.add(new Test());
        runner.run();
    }//function main()


    /**
    * Test year-related methods
    *
    */
    public function testYear () : Void {

        // 2014-09-15 17:51:35
        var dt = new DateTime(STAMP_01);
        assertEquals(44, dt.getUnixYear());
        assertEquals(2014, dt.getYear());
        assertFalse(dt.isLeapYear());
        assertEquals(1388534400, dt.yearStart());

        // 1973-01-01 00:00:00
        var dt = new DateTime(STAMP_02);
        assertEquals(3, dt.getUnixYear());
        assertEquals(1973, dt.getYear());
        assertFalse(dt.isLeapYear());
        assertEquals(STAMP_02, dt.yearStart());

        // 2014-08-31 23:59:59
        var dt = new DateTime(STAMP_03);
        assertEquals(44, dt.getUnixYear());
        assertEquals(2014, dt.getYear());
        assertFalse(dt.isLeapYear());
        assertEquals(1388534400, dt.yearStart());

        // 2012-02-29 00:00:00
        var dt = new DateTime(STAMP_04);
        assertEquals(42, dt.getUnixYear());
        assertEquals(2012, dt.getYear());
        assertTrue(dt.isLeapYear());
        assertEquals(1325376000, dt.yearStart());

        // 1972-02-29 23:59:59
        var dt = new DateTime(STAMP_05);
        assertEquals(2, dt.getUnixYear());
        assertEquals(1972, dt.getYear());
        assertTrue(dt.isLeapYear());
        assertEquals(63072000, dt.yearStart());

    }//function testYear()


    /**
    * Test month-related methods
    *
    */
    public function testMonth () : Void {
        // 2014-09-15 17:51:35
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
    }//function testSecond()

}//class Test