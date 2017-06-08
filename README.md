DateTime
========

[API docs](http://doc.stablex.ru/datetime/index.html)

Custom date-time implementation for Haxe. Does not store milliseconds information. Contains classes and methods for manipulating intervals and date/time math.

`DateTime` is an `abstract` type on top of `Float`, so it does not create any objects (unlike standard Haxe `Date` class) and saves you some memory :)

Also `DateTime` supports dates from 1 a.d. to 16 777 215 a.d. (maybe even more)

`DateTime` is completely crossplatform, because it's written in plain Haxe.


Timezones
---------------
`DateTime` uses IANA timezone database to deal with timezones: http://www.iana.org/time-zones

Local timezone detection code is a straightforward port of `jstimezonedetect` library: https://bitbucket.org/pellepim/jstimezonedetect.
Notice: Read 'Limitations' of original library readme.


Performance
---------------
Depending on platfrom you target and methods of `DateTime` you use it can be up to 7 times faster than standard `Date` class or up to 10 times slower.


Timezone database
---------------
Unless you reference `Timezone` class somewhere in your code, it will not be compiled. But you will still be able to get local time by `DateTime.local()` method.

Full timezone database is ~116Kb. It becomes less then 50Kb when gziped by web server. Timezone database will be compiled into your binary only if you use `Timezone` class somewhere in your code.

Additionally you have an option to avoid embedding timezone database by providing a `-D EXTERNAL_TZ_DB` flag to Haxe compiler.

You can load timezone database at runtime from external sources (filesystem, web server, etc.) and pass it to `datetime.Timezone.loadData(data:String)` (where `data` is contents of `src/datetime/data/tz.dat` file)

Since timezones can change several times every year because of various laws in different countries, perhaps you need to update timezones database using `haxelib run datetime` command ([or do it manually](https://github.com/RealyUniqueName/DateTime/blob/master/update_timezones.md))

Timezone database is stored in `src/datetime/data/tz.dat` file of DateTime library.


Installation
-------------
`haxelib install datetime`


Examples
---------------
```haxe
var utcNow = DateTime.local().utc(); // Gets the current date and time in UTC

var utc = DateTime.fromString('2014-09-19 01:37:45');
//or
var utc : DateTime = '2014-09-19 01:37:45';
//or
var utc = DateTime.fromTime(1411090665);
//or
var utc : DateTime = 1411090665;
//or
var utc = DateTime.make(2014, 9, 19, 1, 37, 45);
//or
var utc = DateTime.fromDate( new Date(2014, 9, 19, 1, 37, 45) );
//or
var utc : DateTime = new Date(2014, 9, 19, 1, 37, 45);

trace( utc.format('%F %T') );    // 2014-09-19 01:37:45
trace( utc.getYear() );          // 2014
trace( utc.isLeapYear() );       // false
trace( utc.getTime() );          // 1411090665
trace( utc.getMonth() );         // 9
trace( utc.getDay() );           // 19
trace( utc.getHour() );          // 1
trace( utc.getMinute() );        // 37
trace( utc.getSecond() );        // 45
trace( utc.getWeekDay() );       // 5

//find last Sunday of current month
trace( utc.getWeekDayNum(Sunday, -1) ); // 2014-09-28 00:00:00

//find DateTime of May in current year
var may : DateTime = utc.getMonthStart(May);
trace( may ); // 2014-05-01 00:00:00

//snap to the beginning of current month
utc.snap( Month(Down) );            // 2014-10-01 00:00:00
//snap to next year
utc.snap( Year(Up) );               // 2015-01-01 00:00:00
//find next Monday
utc.snap( Week(Up, Monday) );
//find nearest Wednesday
utc.snap( Week(Nearest, Wednesday) );

trace( utc.add(Year(1)) );       // 2014-09-19 -> 2015-09-19
trace( utc + Year(1) );          // 2014-09-19 -> 2015-09-19

trace( utc.add(Day(4)) );        // 2014-09-19 -> 2014-09-23
trace( utc += Day(4) );          // 2014-09-19 -> 2014-09-23

trace( utc.add(Minute(10)) );    // 01:37:45 -> 01:47:45
trace( utc + Minute(10) );       // 01:37:45 -> 01:47:45

trace( utc.add(Second(-40)) );   // 01:37:45 -> 01:37:05
trace( utc - Second(40) );       // 01:37:45 -> 01:37:05

trace( utc.add(Week(3)) );       // 2014-09-19 -> 2014-10-10
trace( utc + Week(3) );          // 2014-09-19 -> 2014-10-10

trace( utc.snap(Year(Down)) );           // 2014-01-01 00:00:00
trace( utc.snap(Year(Up)) );             // 2015-01-01 00:00:00
trace( utc.snap(Year(Nearest)) );        // 2015-01-01 00:00:00
trace( utc.snap(Week(Up, Wednesday)) );  // 2014-09-24 00:00:00

var utc2 : DateTime = '2015-11-19 01:37:45';
var dti  : DateTimeInterval = utc2 - utc;   //this interval now contains 1 year and 2 months
trace( dti.toString() );                    // (1y, 2m)
trace( utc + dti );                         // 2015-11-19 01:37:45

//assuming your timezone has +4:00 offset
trace (utc.local());    // 2014-09-19 05:37:45

//If timezones database is not embedded or you need to load an updated database
var data:String = ... //load from external source
Timezone.loadData(data);

var tz = Timezone.local();
trace( tz.getName() );                  // Europe/Moscow
trace( tz.at(utc) );                    // 2014-09-19 05:37:45
trace( tz.format(utc, '%F %T %z %Z') ); // 2014-09-19 05:37:45 +0400 MSK

```
And much more: [API docs](http://doc.stablex.ru/datetime/index.html)
