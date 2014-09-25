/**
* MIT License
*
* Original project:
*   Copyright (c) 2012 Jon Nylander, project maintained at
*   https://bitbucket.org/pellepim/jstimezonedetect
* Ported to Haxe:
*   Copyright (c) 2014 Alexander Kuzmenko, project maintained at
*   https://github.com/RealyUniqueName/DateTime/src/datetime/utils/TimezoneDetect.hx
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights to
* use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
* of the Software, and to permit persons to whom the Software is furnished to
* do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/
package datetime.utils;

import datetime.DateTime;


/**
* Local timezone detection.
* Notice from original author of `jstimezonedetect`:
*
* `Use Case
* The script is useful if you do not want to disturb your users with questions about what time zone they are in. You can rely on this script to give you a key that is usable for server side datetime normalisations across time zones.
*
* Limitations
* This script does not do geo-location, nor does it care very much about historical time zones.
* So if you are unhappy with the time zone "Europe/Berlin" when the user is in fact in "Europe/Stockholm" - this script is not for you. (They are both identical in modern time).
* Also, if it is important to you to know that in Europe/Simferopool (Ukraine) the UTC offset before 1924 was +2.67, sorry, this script will not help you.
* Time zones are a screwed up thing, generally speaking, and the scope of this script is to solve problems concerning modern time zones, in this case from 2010 and forward.
* `
*/
@:allow(datetime)
@:access(datetime)
class TimezoneDetect {

    static private inline var HEMISPHERE_SOUTH = 's';

    /*
    * The keys in this dictionary are comma separated as such:
    *
    * First the offset compared to UTC time in minutes.
    *
    * Then a flag which is 0 if the timezone does not take daylight savings into account and 1 if it
    * does.
    *
    * Thirdly an optional 's' signifies that the timezone is in the southern hemisphere,
    * only interesting for timezones with DST.
    *
    * The mapped arrays is used for constructing the jstz.TimeZone object from within
    * jstz.determine_timezone();
    */
    static private var timezones : Map<String,String> = [
        '-720,0'   => 'Pacific/Majuro',
        '-660,0'   => 'Pacific/Pago_Pago',
        '-600,1'   => 'America/Adak',
        '-600,0'   => 'Pacific/Honolulu',
        '-570,0'   => 'Pacific/Marquesas',
        '-540,0'   => 'Pacific/Gambier',
        '-540,1'   => 'America/Anchorage',
        '-480,1'   => 'America/Los_Angeles',
        '-480,0'   => 'Pacific/Pitcairn',
        '-420,0'   => 'America/Phoenix',
        '-420,1'   => 'America/Denver',
        '-360,0'   => 'America/Guatemala',
        '-360,1'   => 'America/Chicago',
        '-360,1,s' => 'Pacific/Easter',
        '-300,0'   => 'America/Bogota',
        '-300,1'   => 'America/New_York',
        '-270,0'   => 'America/Caracas',
        '-240,1'   => 'America/Halifax',
        '-240,0'   => 'America/Santo_Domingo',
        '-240,1,s' => 'America/Santiago',
        '-210,1'   => 'America/St_Johns',
        '-180,1'   => 'America/Godthab',
        '-180,0'   => 'America/Argentina/Buenos_Aires',
        '-180,1,s' => 'America/Montevideo',
        '-120,0'   => 'America/Noronha',
        '-120,1'   => 'America/Noronha',
        '-60,1'    => 'Atlantic/Azores',
        '-60,0'    => 'Atlantic/Cape_Verde',
        '0,0'      => 'UTC',
        '0,1'      => 'Europe/London',
        '60,1'     => 'Europe/Berlin',
        '60,0'     => 'Africa/Lagos',
        '60,1,s'   => 'Africa/Windhoek',
        '120,1'    => 'Asia/Beirut',
        '120,0'    => 'Africa/Johannesburg',
        '180,0'    => 'Asia/Baghdad',
        '180,1'    => 'Europe/Moscow',
        '210,1'    => 'Asia/Tehran',
        '240,0'    => 'Asia/Dubai',
        '240,1'    => 'Asia/Baku',
        '270,0'    => 'Asia/Kabul',
        '300,1'    => 'Asia/Yekaterinburg',
        '300,0'    => 'Asia/Karachi',
        '330,0'    => 'Asia/Kolkata',
        '345,0'    => 'Asia/Kathmandu',
        '360,0'    => 'Asia/Dhaka',
        '360,1'    => 'Asia/Omsk',
        '390,0'    => 'Asia/Rangoon',
        '420,1'    => 'Asia/Krasnoyarsk',
        '420,0'    => 'Asia/Jakarta',
        '480,0'    => 'Asia/Shanghai',
        '480,1'    => 'Asia/Irkutsk',
        '525,0'    => 'Australia/Eucla',
        '525,1,s'  => 'Australia/Eucla',
        '540,1'    => 'Asia/Yakutsk',
        '540,0'    => 'Asia/Tokyo',
        '570,0'    => 'Australia/Darwin',
        '570,1,s'  => 'Australia/Adelaide',
        '600,0'    => 'Australia/Brisbane',
        '600,1'    => 'Asia/Vladivostok',
        '600,1,s'  => 'Australia/Sydney',
        '630,1,s'  => 'Australia/Lord_Howe',
        '660,1'    => 'Asia/Kamchatka',
        '660,0'    => 'Pacific/Noumea',
        '690,0'    => 'Pacific/Norfolk',
        '720,1,s'  => 'Pacific/Auckland',
        '720,0'    => 'Pacific/Tarawa',
        '765,1,s'  => 'Pacific/Chatham',
        '780,0'    => 'Pacific/Tongatapu',
        '780,1,s'  => 'Pacific/Apia',
        '840,0'    => 'Pacific/Kiritimati'
    ];


    /**
    * The keys in this object are timezones that we know may be ambiguous after
    * a preliminary scan through the olson_tz object.
    *
    * The array of timezones to compare must be in the order that daylight savings
    * starts for the regions.
    */
    static private var ambiguities : Map<String,Array<String>> = [
        'America/Denver'      => ['America/Denver', 'America/Mazatlan'],
        'America/Chicago'     => ['America/Chicago', 'America/Mexico_City'],
        'America/Santiago'    => ['America/Santiago', 'America/Asuncion', 'America/Campo_Grande'],
        'America/Montevideo'  => ['America/Montevideo', 'America/Sao_Paulo'],
        'Asia/Beirut'         => ['Asia/Amman', 'Asia/Jerusalem', 'Asia/Beirut', 'Europe/Helsinki','Asia/Damascus'],
        'Pacific/Auckland'    => ['Pacific/Auckland', 'Pacific/Fiji'],
        'America/Los_Angeles' => ['America/Los_Angeles', 'America/Santa_Isabel'],
        'America/New_York'    => ['America/Havana', 'America/New_York'],
        'America/Halifax'     => ['America/Goose_Bay', 'America/Halifax'],
        'America/Godthab'     => ['America/Miquelon', 'America/Godthab'],
        'Asia/Dubai'          => ['Europe/Moscow'],
        'Asia/Dhaka'          => ['Asia/Yekaterinburg'],
        'Asia/Jakarta'        => ['Asia/Omsk'],
        'Asia/Shanghai'       => ['Asia/Krasnoyarsk', 'Australia/Perth'],
        'Asia/Tokyo'          => ['Asia/Irkutsk'],
        'Australia/Brisbane'  => ['Asia/Yakutsk'],
        'Pacific/Noumea'      => ['Asia/Vladivostok'],
        'Pacific/Tarawa'      => ['Asia/Kamchatka', 'Pacific/Fiji'],
        'Pacific/Tongatapu'   => ['Pacific/Apia'],
        'Asia/Baghdad'        => ['Europe/Minsk'],
        'Asia/Baku'           => ['Asia/Yerevan','Asia/Baku'],
        'Africa/Johannesburg' => ['Asia/Gaza', 'Africa/Cairo']
    ];

    static private var dst_starts : Map<String,Date> = [
        'America/Denver'       => new Date(2011, 2, 13, 3, 0, 0),
        'America/Mazatlan'     => new Date(2011, 3, 3, 3, 0, 0),
        'America/Chicago'      => new Date(2011, 2, 13, 3, 0, 0),
        'America/Mexico_City'  => new Date(2011, 3, 3, 3, 0, 0),
        'America/Asuncion'     => new Date(2012, 9, 7, 3, 0, 0),
        'America/Santiago'     => new Date(2012, 9, 3, 3, 0, 0),
        'America/Campo_Grande' => new Date(2012, 9, 21, 5, 0, 0),
        'America/Montevideo'   => new Date(2011, 9, 2, 3, 0, 0),
        'America/Sao_Paulo'    => new Date(2011, 9, 16, 5, 0, 0),
        'America/Los_Angeles'  => new Date(2011, 2, 13, 8, 0, 0),
        'America/Santa_Isabel' => new Date(2011, 3, 5, 8, 0, 0),
        'America/Havana'       => new Date(2012, 2, 10, 2, 0, 0),
        'America/New_York'     => new Date(2012, 2, 10, 7, 0, 0),
        'Europe/Helsinki'      => new Date(2013, 2, 31, 5, 0, 0),
        'Pacific/Auckland'     => new Date(2011, 8, 26, 7, 0, 0),
        'America/Halifax'      => new Date(2011, 2, 13, 6, 0, 0),
        'America/Goose_Bay'    => new Date(2011, 2, 13, 2, 1, 0),
        'America/Miquelon'     => new Date(2011, 2, 13, 5, 0, 0),
        'America/Godthab'      => new Date(2011, 2, 27, 1, 0, 0),
        'Europe/Moscow'        => new Date(2010, 6, 15, 1, 0, 0),
        'Asia/Amman'           => new Date(2013, 2, 29, 1, 0, 0),
        'Asia/Beirut'          => new Date(2013, 2, 31, 2, 0, 0),
        'Asia/Damascus'        => new Date(2013, 3, 6, 2, 0, 0),
        'Asia/Jerusalem'       => new Date(2013, 2, 29, 5, 0, 0),
        'Asia/Yekaterinburg'   => new Date(2010, 6, 15, 1, 0, 0),
        'Asia/Omsk'            => new Date(2010, 6, 15, 1, 0, 0),
        'Asia/Krasnoyarsk'     => new Date(2010, 6, 15, 1, 0, 0),
        'Asia/Irkutsk'         => new Date(2010, 6, 15, 1, 0, 0),
        'Asia/Yakutsk'         => new Date(2010, 6, 15, 1, 0, 0),
        'Asia/Vladivostok'     => new Date(2010, 6, 15, 1, 0, 0),
        'Asia/Baku'            => new Date(2013, 2, 31, 4, 0, 0),
        'Asia/Yerevan'         => new Date(2013, 2, 31, 3, 0, 0),
        'Asia/Kamchatka'       => new Date(2010, 6, 15, 1, 0, 0),
        'Asia/Gaza'            => new Date(2010, 2, 27, 4, 0, 0),
        'Africa/Cairo'         => new Date(2010, 4, 1, 3, 0, 0),
        'Europe/Minsk'         => new Date(2010, 6, 15, 1, 0, 0),
        'Pacific/Apia'         => new Date(2010, 10, 1, 1, 0, 0),
        'Pacific/Fiji'         => new Date(2010, 11, 1, 0, 0, 0),
        'Australia/Perth'      => new Date(2008, 10, 1, 1, 0, 0)
    ];


    /**
    * Get timezone offset in minutes
    *
    */
    static private function getTimezoneOffset (date:Date) : Int {
        var localTime = DateTime.make(date.getFullYear(), date.getMonth() + 1, date.getDate(), date.getHours(), date.getMinutes(), date.getSeconds());

        return -Std.int((localTime.getTime() - DateTime.fromDate(date).getTime()) / DateTime.SECONDS_IN_MINUTE);
    }//function getTimezoneOffset()


    /**
    * Checks if a timezone has possible ambiguities. I.e timezones that are similar.
    *
    * For example, if the preliminary scan determines that we're in America/Denver.
    * We double check here that we're really there and not in America/Mazatlan.
    *
    * This is done by checking known dates for when daylight savings start for different
    * timezones during 2010 and 2011.
    */
    static private function ambiguity_check (tzName:String) : String {
        var ambiguity_list = ambiguities[tzName];
        var length = ambiguity_list.length;
        var i = 0;
        var tz = ambiguity_list[0];

        for (i in 0...length) {
            tz = ambiguity_list[i];

            if (date_is_dst(dst_start_for(tz))) {
                return tz;
            }
        }

        return tzName;
    }

    /**
    * Checks if it is possible that the timezone is ambiguous.
    */
    static private function is_ambiguous (tzName:String) : Bool {
        return ambiguities.exists(tzName);
    }


    /**
    * Gets the offset in minutes from UTC for a certain date.
    * @param {Date} date
    * @returns {Number}
    */
    static private function get_date_offset (date:Date) : Int {
        return -getTimezoneOffset(date);
    }

    /**
    * Get specified date with hours/minuts/seconds set to current moment
    * `day` - day of the month
    */
    static private function get_date (year:Int, month:Int, day:Int) {
        var now : Date = Date.now();
        var d   : Date = new Date((year < 0 ? now.getFullYear() : year), month, day, now.getHours(), now.getMinutes(), now.getSeconds());
        return d;
    }


    static private function get_january_offset (year:Int = -1) : Int {
        return get_date_offset(get_date(year, 0 ,2));
    }


    static private function get_june_offset (year : Int = -1) : Int {
        return get_date_offset(get_date(year, 5, 2));
    }


    /**
    * Private method.
    * Checks whether a given date is in daylight saving time.
    * If the date supplied is after august, we assume that we're checking
    * for southern hemisphere DST.
    * @param {Date} date
    * @returns {Boolean}
    */
    static private function date_is_dst (date:Date) : Bool {
        var is_southern : Bool = date.getMonth() > 7;
        var base_offset : Int = (
            is_southern
                ? get_june_offset(date.getFullYear())
                : get_january_offset(date.getFullYear())
        );
        var date_offset : Int  = get_date_offset(date);
        var is_west     : Bool = base_offset < 0;
        var dst_offset  : Int  = base_offset - date_offset;

        if (!is_west && !is_southern) {
            return dst_offset < 0;
        }

        return dst_offset != 0;
    }


    /**
    * This function does some basic calculations to create information about
    * the user's timezone. It uses REFERENCE_YEAR as a solid year for which
    * the script has been tested rather than depend on the year set by the
    * client device.
    *
    * Returns a key that can be used to do lookups in jstz.olson.timezones.
    * eg: "720,1,2".
    *
    * @returns {String}
    */
    static private function lookup_key () : String {
        var january_offset : Int = get_january_offset();
        var june_offset    : Int = get_june_offset();
        var diff           : Int = january_offset - june_offset;

        if (diff < 0) {
            return january_offset + ",1";
        } else if (diff > 0) {
            return june_offset + ",1," + HEMISPHERE_SOUTH;
        }

        return january_offset + ",0";
    }


    /**
    * Uses get_timezone_info() to formulate a key to use in the olson.timezones dictionary.
    *
    * Returns a primitive object on the format:
    * {'timezone': TimeZone, 'key' : 'the key used to find the TimeZone object'}
    *
    * @returns timezone name
    */
    static private function detect () : String {
        var key    : String = lookup_key();
        var tzName : String = timezones.get(key);

        if (is_ambiguous(tzName)) {
            tzName = ambiguity_check(tzName);
        }

        return tzName;
    }


    /**
    * This object contains information on when daylight savings starts for
    * different timezones.
    *
    * The list is short for a reason. Often we do not have to be very specific
    * to single out the correct timezone. But when we do, this list comes in
    * handy.
    *
    * Each value is a date denoting when daylight savings starts for that timezone.
    */
    static private function dst_start_for (tz_name) {
        return dst_starts.get(tz_name);
    }


}//class TimezoneDetect