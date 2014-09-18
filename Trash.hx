package;

import haxe.Timer;

using StringTools;

/**
* Description
*
*/
class Trash {


    /**
    * Description
    *
    */
    static public function main () : Void {
        // var d = Date.now();
        // Timer.measure(function(){
        //     for (i in 0...0xFFFF) {
        //         d.getDate();
        //     }
        // });

        // var dt = new DateTime(Date.now().getTime() / 1000);
        // Timer.measure(function(){
        //     for (i in 0...0xFFFF) {
        //         dt.getDay();
        //     }
        // });



        // var s : DateTime = DateTimeUtils.yearToStamp(1966);
        // var tt : Float = s;
        // trace(tt);
        // trace(s);

        // var dt : DateTime;

        // for (y in -999...9999) {
        //     dt = DateTimeUtils.yearToStamp(y);
        //     if (Std.parseInt(dt.toString().substr(0, 4)) != y) {
        //         trace(y);
        //         break;
        //     }
        // }

        var dt = DateTime.fromString('16777215-10-01 00:00:00');
        var s : Float = dt;
        trace(s);
        trace(dt);//getYear());
    }//function main()


}//class Trash