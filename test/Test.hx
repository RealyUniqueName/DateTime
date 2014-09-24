package ;

import haxe.unit.TestCase;
import haxe.unit.TestRunner;
import datetime.DateTime;


/**
* Unit tests
*
*/
class Test {


    /**
    * Entry point
    *
    */
    static public inline function main () : Void {
        // Sys.command('php', ['-r', 'date_default_timezone_set("UTC");echo date("Y-m-d H:i:s", -2145225600);']);return;
        // Sys.command('php', ['-r', 'date_default_timezone_set("UTC");echo strftime("%d %e %j %u %w %m %C %y %Y %H %k %I %l %M %p %P %r %R %S %T %D %F %s %%" ,strtotime("2014-12-31 01:37:45"));']);return;

        var runner = new TestRunner();
        runner.add(new DateTimeTest());
        runner.add(new DateTimeIntervalTest());
        runner.run();
    }//function main()

}//class Test