package;

import haxe.Timer;

using StringTools;

/**
* Description
*
*/
class Test {


    /**
    * Description
    *
    */
    static public function main () : Void {

        // var dt = new DateTime(Date.now().getTime() / 1000);
        // Timer.measure(function(){
        //     for (i in 0...0xFFFFF) {
        //         dt.getMinute();
        //     }
        // });

        // var d = Date.now();
        // Timer.measure(function(){
        //     for (i in 0...0xFFFFF) {
        //         d.getMinutes();
        //     }
        // });

        // var s : DateTime = DateTimeUtils.yearToStamp(1966);
        // var tt : Float = s;
        // trace(tt);
        // trace(s);

        // for (y in 0...3000) {
        //     for (m in 1...13) {
        //         var dt : DateTime = DateTimeUtils.yearToStamp(y);
        //         if (Std.parseInt(dt.toString().substr(0, 4)) != y) {
        //             trace(y);
        //         }
        //     }
        // }

        var dt = DateTime.fromString('1901-10-01 00:00:00');
        var s : Float = dt;
        trace(s);
        trace(dt);//getYear());
    }//function main()


}//class Test