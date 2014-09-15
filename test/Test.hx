package test;

import haxe.unit.TestCase;
import haxe.unit.TestRunner;



/**
* Unit tests
*
*/
class Test extends TestCase {

    /** 2014-09-15 21:51:35 */
    static public inline var STAMP_01 = 1410803495;
    /** 1973-01-01 00:00:00 */
    static public inline var STAMP_02 = 94694400;
    /** 2012-02-29 00:00:00 */
    static public inline var STAMP_03 = 1330473600;
    /** 1972-02-29 23:59:59 */
    static public inline var STAMP_04 = 68255999;


    /**
    * Entry point
    *
    */
    static public function main () : Void {
        var runner = new TestRunner();
        runner.add(new Test());
        runner.run();
    }//function main()


    /**
    * Test year-related methods
    *
    */
    public function testYear () : Void {

        // 2014-09-15 21:51:35
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

        // 2012-02-29 00:00:00
        var dt = new DateTime(STAMP_03);
        assertEquals(42, dt.getUnixYear());
        assertEquals(2012, dt.getYear());
        assertTrue(dt.isLeapYear());
        assertEquals(1325376000, dt.yearStart());

        // 1972-02-29 23:59:59
        var dt = new DateTime(STAMP_04);
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
        // 2014-09-15 21:51:35
        var dt = new DateTime(STAMP_01);
        assertEquals(9, dt.getMonth());

        // 1973-01-01 00:00:00
        var dt = new DateTime(STAMP_02);
        assertEquals(1, dt.getMonth());

        // 2012-02-29 00:00:00
        var dt = new DateTime(STAMP_03);
        assertEquals(2, dt.getMonth());

        // 1972-02-29 23:59:59
        var dt = new DateTime(STAMP_04);
        assertEquals(2, dt.getMonth());

    }//function testMonth()


}//class Test