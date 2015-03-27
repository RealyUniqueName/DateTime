package datetime.utils;

import datetime.data.TimezoneData;
import datetime.DateTime;

using StringTools;


/**
* Various utilities for timezones
*
*/
@:access(datetime)
@:allow(datetime)
class TimezoneUtils {


    /**
    * Format date/time with timezone shift
    *
    */
    static private function format (tz:Timezone, utc:DateTime, format:String) : String {
        var prevPos : Int = 0;
        var pos     : Int    = format.indexOf('%');
        var str     : String = '';
        var period  : TimezonePeriod = (tz:TimezoneData).getPeriodForUtc(utc);
        var dt      : DateTime = utc.getTime() + period.offset;

        //find HHMM offset {
            var hh  : Int = Std.int(period.offset / DateTime.SECONDS_IN_HOUR);
            var mm  : Int = Std.int((period.offset - hh * DateTime.SECONDS_IN_HOUR) / DateTime.SECONDS_IN_MINUTE);
            var neg : Bool = (hh < 0);
            if (neg) {
                hh = -hh;
                mm = -mm;
            }
        //}

        while (pos >= 0) {
            str += format.substring(prevPos, pos);
            pos ++;

            switch (format.fastCodeAt(pos)) {
                // `%z`  The time zone offset. Example: -0500 for US Eastern Time
                case 'z'.code:
                    var hhmm : String = '' + (hh * 100 + mm);
                    str += (neg ? '-' : '+') + hhmm.lpad('0', 4);
                // `%Z`  The time zone abbreviation. Example: EST for Eastern Standart Time
                case 'Z'.code:
                    str += period.abr;
                // `%q`  ISO8691 date/time format. Example: 2014-10-04T19:42:56+00:00
                case 'q'.code:
                    var hhmm : String = (hh < 10 ? '0$hh' : '$hh') + ':' + (mm < 10 ? '0$mm' : '$mm');
                    str += '%FT%T' + (neg ? '-' : '+') + hhmm;
                //other placeholders will be passed to dt.format()
                case _:
                    str += '%' + format.charAt(pos);
            }//switch()

            prevPos = pos + 1;
            pos = format.indexOf('%', pos + 1);
        }
        str += format.substring(prevPos);

        return dt.format(str);
    }//function format()


}//class TimezoneUtils