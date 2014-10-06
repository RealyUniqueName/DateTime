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
    * Common test
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