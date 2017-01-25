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


    /**
    * Test interval math
    *
    */
    public function testMath () : Void {
        var dt1 : DateTime = '2011-01-15 23:52:01';
        var dt2 : DateTime = '2014-10-03 12:24:48';

        var dti1 : DateTimeInterval = dt2 - dt1;
        var dti2 : DateTimeInterval = dt1 - dt2;

        assertEquals(dt1.toString(), (dt2 - dti1).toString());
        assertEquals(dt1.toString(), (dt2 + dti2).toString());
        assertEquals(dt2.toString(), (dt1 - dti2).toString());
        assertEquals(dt2.toString(), (dt1 + dti1).toString());
    }//function testMath()


    /**
    * Test interval comparison
    *
    */
    public function testComparison () : Void {
        var begin : DateTime = '2011-01-15 23:52:01';
        var end   : DateTime = '2014-10-03 12:24:48';
        var end2  : DateTime = '2014-10-04 12:24:48';

        //negative
		{
			assertTrue((begin - end).negative);
			assertFalse((end - begin).negative);
		}

		//eq
		{
			assertTrue(begin - end == begin - end);
			assertTrue(end - begin == end - begin);
			assertFalse(begin - end == end - begin);
			assertFalse(end - begin == begin - end);
		}

		//gt
		{
			assertTrue(end - begin > begin - end);
			assertTrue(end2 - begin > end - begin);
			assertFalse(begin - end > end - begin);
			assertFalse(end - begin > end2 - begin);
			assertFalse(begin - end > begin - end);
		}

		//gte
		{
			assertTrue(end - begin >= begin - end);
			assertTrue(end2 - begin >= end - begin);
			assertFalse(begin - end >= end - begin);
			assertFalse(end - begin >= end2 - begin);

			assertTrue(begin - end >= begin - end);
			assertTrue(end - begin >= end - begin);
		}

		//lt
		{
			assertTrue(begin - end < end - begin);
			assertTrue(end - begin < end2 - begin);
			assertFalse(end - begin < begin - end);
			assertFalse(end2 - begin < end - begin);
			assertFalse(begin - end < begin - end);
		}

		//lte
		{
			assertTrue(begin - end <= end - begin);
			assertTrue(end - begin <= end2 - begin);
			assertFalse(end - begin <= begin - end);
			assertFalse(end2 - begin <= end - begin);

			assertTrue(begin - end <= begin - end);
			assertTrue(end - begin <= end - begin);
		}

		//neq
		{
			assertFalse(begin - end != begin - end);
			assertFalse(end - begin != end - begin);
			assertTrue(begin - end != end - begin);
			assertTrue(end - begin != begin - end);
		}
    }//function testComparison()


    /**
    * Test DateTimeInterval.format()
    *
    */
    public function testFormat () : Void {
        var begin : DateTime = '2011-01-15 23:52:01';
        var end   : DateTime = '2014-10-03 12:24:48';

        //(3y, 8m, 18d, 12hrs, 32min, 47sec)
        var dti = end - begin;

        // Y - Years, numeric, at least 2 digits with leading 0. Example:    01, 03
        assertEquals('03', dti.format('%Y'));
        // y - Years, numeric. Example:  1, 3
        assertEquals('3', dti.format('%y'));
        // M - Months, numeric, at least 2 digits with leading 0. Example:   01, 03, 12
        assertEquals('08', dti.format('%M'));
        // m - Months, numeric. Example: 1, 3, 12
        assertEquals('8', dti.format('%m'));
        // b - Total number of months. Example:   2, 15, 36
        assertEquals('44', dti.format('%b'));
        // D - Days, numeric, at least 2 digits with leading 0. Example: 01, 03, 31
        assertEquals('18', dti.format('%D'));
        // d - Days, numeric. Example:   1, 3, 31
        assertEquals('18', dti.format('%d'));
        // a - Total number of days. Example:   4, 18, 8123
        assertEquals('1356', dti.format('%a'));
        // H - Hours, numeric, at least 2 digits with leading 0. Example:    01, 03, 23
        assertEquals('12', dti.format('%H'));
        // h - Hours, numeric. Example:  1, 3, 23
        assertEquals('12', dti.format('%h'));
        // c - Total number of hours. Example:   4, 18, 8123
        assertEquals('32556', dti.format('%c'));
        // I - Minutes, numeric, at least 2 digits with leading 0. Example:  01, 03, 59
        assertEquals('32', dti.format('%I'));
        // i - Minutes, numeric. Example:    1, 3, 59
        assertEquals('32', dti.format('%i'));
        // e - Total number of minutes. Example:   4, 18, 8123
        assertEquals('1953392', dti.format('%e'));
        // S - Seconds, numeric, at least 2 digits with leading 0. Example:  01, 03, 57
        assertEquals('47', dti.format('%S'));
        // s - Seconds, numeric. Example:    1, 3, 57
        assertEquals('47', dti.format('%s'));
        // f - Total number of seconds. Example:   4, 18, 8123
        assertEquals('117203567', dti.format('%f'));
        // R - Sign "-" when negative, "+" when positive. Example:   -, +
        assertEquals('+', dti.format('%R'));
        // r - Sign "-" when negative, empty when positive. Example: -,
        assertEquals('', dti.format('%r'));
        // %%  A literal percentage character ("%")
        assertEquals('%', dti.format('%%'));

        //test DateTimeInterval.formatPartial()
        end   = '2014-10-10';
        begin = '2014-07-21';
        dti   = end - begin;
        var formatted : String = dti.formatPartial(['%y years', '%m months', '%d days']).join(', ');
        assertEquals('2 months, 20 days', formatted);
    }//function testFormat()

}//class DateTimeIntervalTest
