package datetime.utils;

import datetime.DateTimeInterval;

using StringTools;


/**
* Utility functions for DateTimeInterval
*
*/
@:allow(datetime)
@:access(datetime)
class DateTimeIntervalUtils {


    /**
    * Limited strftime implementation
    *
    */
    static private function strftime (dti:DateTimeInterval, format:String) : String {
        var prevPos : Int = 0;
        var pos     : Int    = format.indexOf('%');
        var str     : String = '';

        while (pos >= 0) {
            str += format.substring(prevPos, pos);
            pos ++;

            switch (format.fastCodeAt(pos)) {
                // Y - Years, numeric, at least 2 digits with leading 0. Example:    01, 03
                case 'Y'.code:
                    str += (dti.getYears() + '').lpad('0', 2);
                // y - Years, numeric. Example:  1, 3
                case 'y'.code:
                    str += dti.getYears() + '';
                // M - Months, numeric, at least 2 digits with leading 0. Example:   01, 03, 12
                case 'M'.code:
                    str += (dti.getMonths() + '').lpad('0', 2);
                // m - Months, numeric. Example: 1, 3, 12
                case 'm'.code:
                    str += dti.getMonths() + '';
                // b - Total number of months. Example:   2, 15, 36
                case 'b'.code:
                    str += dti.getTotalMonths() + '';
                // D - Days, numeric, at least 2 digits with leading 0. Example: 01, 03, 31
                case 'D'.code:
                    str += (dti.getDays() + '').lpad('0', 2);
                // d - Days, numeric. Example:   1, 3, 31
                case 'd'.code:
                    str += dti.getDays() + '';
                // a - Total number of days. Example:   4, 18, 8123
                case 'a'.code:
                    str += dti.getTotalDays() + '';
                // H - Hours, numeric, at least 2 digits with leading 0. Example:    01, 03, 23
                case 'H'.code:
                    str += (dti.getHours() + '').lpad('0', 2);
                // h - Hours, numeric. Example:  1, 3, 23
                case 'h'.code:
                    str += dti.getHours() + '';
                // c - Total number of hours. Example:   4, 18, 8123
                case 'c'.code:
                    str += dti.getTotalHours() + '';
                // I - Minutes, numeric, at least 2 digits with leading 0. Example:  01, 03, 59
                case 'I'.code:
                    str += (dti.getMinutes() + '').lpad('0', 2);
                // i - Minutes, numeric. Example:    1, 3, 59
                case 'i'.code:
                    str += dti.getMinutes() + '';
                // e - Total number of minutes. Example:   4, 18, 8123
                case 'e'.code:
                    str += dti.getTotalMinutes() + '';
                // S - Seconds, numeric, at least 2 digits with leading 0. Example:  01, 03, 57
                case 'S'.code:
                    str += (dti.getSeconds() + '').lpad('0', 2);
                // s - Seconds, numeric. Example:    1, 3, 57
                case 's'.code:
                    str += dti.getSeconds() + '';
                // f - Total number of seconds. Example:   4, 18, 8123
                case 'f'.code:
                    str += dti.getTotalSeconds() + '';
                // R - Sign "-" when negative, "+" when positive. Example:   -, +
                case 'R'.code:
                    str += (dti.negative ? '-' : '+');
                // r - Sign "-" when negative, empty when positive. Example: -,
                case 'r'.code:
                    str += (dti.negative ? '-' : '');
                // %%  A literal percentage character ("%")
                case '%'.code:
                    str += '%';
            }//switch()

            prevPos = pos + 1;
            pos = format.indexOf('%', pos + 1);
        }
        str += format.substring(prevPos);

        return str;
    }//function strftime()


    /**
    * Instantiating is not allowed
    *
    */
    private function new () : Void {
    }//function new()



}//class DateTimeIntervalUtils