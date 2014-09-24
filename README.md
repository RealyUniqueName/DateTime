DateTime
========

Docs: http://doc.stablex.ru/

Custom date-time (and date-time arithmetics) implementation for Haxe. Does not store milliseconds information. Does nothing with timezones.

`DateTime` is an `abstract` type on top of `Float`, so it does not create any objects (unlike standart Haxe `Date` class) and saves you some memory :)

Also `DateTime` supports dates from 1 a.d. to 16 777 215 a.d. (maybe even more)

`DateTime` is up to 7 times faster than standart `Date` class depending on target platform (except Javascript where `DateTime` is up to 7 times slower than `Date` depending on browser)

Examples
---------------
```haxe
var dt = DateTime.fromString('2014-09-19 01:37:45');
//or
var dt : DateTime = '2014-09-19 01:37:45';
//or
var dt = DateTime.fromTime(1411090665);
//or
var dt : DateTime = 1411090665;
//or
var dt = DateTime.make(2014, 9, 19, 1, 37, 45);
//or
var dt = DateTime.fromDate( Date.make(2014, 9, 19, 1, 37, 45) );
//or
var dt : DateTime = Date.make(2014, 9, 19, 1, 37, 45);

trace( dt.format('%F %T') );    // 2014-09-19 01:37:45
trace( dt.getYear() );          // 2014
trace( dt.isLeapYear() );       // false
trace( dt.getTime() );          // 1411090665
trace( dt.getMonth() );         // 9
trace( dt.getDay() );           // 19
trace( dt.getHour() );          // 1
trace( dt.getMinute() );        // 37
trace( dt.getSecond() );        // 45
trace( dt.getWeekDay() );       // 5

trace( dt.add(Year(1)) );       // 2014-09-19 -> 2015-09-19
trace( dt + Year(1) );          // 2014-09-19 -> 2015-09-19

trace( dt.add(Day(4)) );        // 2014-09-19 -> 2014-09-23
trace( dt += Day(4) );          // 2014-09-19 -> 2014-09-23

trace( dt.add(Minute(10)) );    // 01:37:45 -> 01:47:45
trace( dt + Minute(10) );       // 01:37:45 -> 01:47:45

trace( dt.add(Second(-40)) );   // 01:37:45 -> 01:37:05
trace( dt - Second(40) );       // 01:37:45 -> 01:37:05

trace( dt.add(Week(3)) );       // 2014-09-19 -> 2014-10-10
trace( dt + Week(3) );          // 2014-09-19 -> 2014-10-10

trace( dt.snap(Year(Down)) );           // 2014-01-01 00:00:00
trace( dt.snap(Year(Up)) );             // 2015-01-01 00:00:00
trace( dt.snap(Year(Nearest)) );        // 2015-01-01 00:00:00
trace( dt.snap(Week(Up, Wednesday)) );  // 2014-09-24 00:00:00
```
