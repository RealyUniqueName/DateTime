package ;

import datetime.DateTimeInterval;
import haxe.unit.TestCase;
import haxe.unit.TestRunner;
import datetime.DateTime;


/**
* DateTimeInterval module tests
*
*/
class DateTimeIntervalTest extends TestCase {


    /**
    * Test interval creation
    *
    */
    public function testCreate () : Void {
        var dt1 : DateTime = '2011-01-15 23:52:01';
        var dt2 : DateTime = '2014-10-03 12:24:48';

        var dti1 : DateTimeInterval = dt2 - dt1;
        var dti2 : DateTimeInterval = dt1 - dt2;

        assertEquals('(3y, 8m, 18d, 12hrs, 32min, 47sec)', dti1.toString());
        assertEquals('-(3y, 8m, 18d, 12hrs, 32min, 47sec)', dti2.toString());
    }//function testCreate()


    // /**
    // * Test interval math
    // *
    // */
    // public function testMath () : Void {
    //     var dt1 : DateTime = '2011-01-15 23:52:01';
    //     var dt2 : DateTime = '2014-10-03 12:24:48';

    //     var dti1 : DateTimeInterval = dt2 - dt1;
    //     var dti2 : DateTimeInterval = dt1 - dt2;

    //     assertEquals(dt1.toString(), (dt2 - dti1).toString());
    //     assertEquals(dt1.toString(), (dt2 + dti2).toString());
    //     assertEquals(dt2.toString(), DateTime.fromTime(dt1.getTime() - dti2.sign() * dti2.getTotalSeconds()).toString());
    //     assertEquals(dt2.toString(), (dt1 + dti1).toString());
    // }//function testMath()


    /**
    * Test interval comparison
    *
    */
    public function testComparison () : Void {
        var begin : DateTime = '2011-01-15 23:52:01';
        var end   : DateTime = '2014-10-03 12:24:48';
        var end2  : DateTime = '2014-10-04 12:24:48';

        assertTrue(end - begin == end - begin);
        assertFalse(end - begin != end - begin);
        assertTrue(end - begin >= end - begin);
        assertTrue(end - begin <= end - begin);
        assertFalse(end - begin > end - begin);
        assertFalse(end - begin < end - begin);

        assertFalse(end2 - begin == end - begin);
        assertTrue(end2 - begin != end - begin);
        assertTrue(end2 - begin >= end - begin);
        assertFalse(end2 - begin <= end - begin);
        assertTrue(end2 - begin > end - begin);
        assertFalse(end2 - begin < end - begin);
    }//function testComparison()


}//class DateTimeIntervalTest