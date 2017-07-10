3.1.1
------------------------------
* `datetime.DateTime.getLocalOffset()` returns current local time offset relative to UTC time.

3.1.0
------------------------------
* `datetime.Timezone.loadData(data:String)` loads timezone database at runtime.
* fix DateTimeInterval comparison (now depends on interval sign) by @jonnydee.
* fix subtracting amount of months, which equals month number in DateTime instance (#17)

3.0.3
------------------------------
* fixed Haxe 3.4 compatibility for cpp target

3.0.2
------------------------------
* `datetime.DateTime.getDate()` - converts to standart `Date` class.
* fix `<=` operator.

3.0.1
------------------------------
workaround for a bug which prevented using timezones database on android.

3.0.0
------------------------------
* `datetime.Timezone.get(zoneName)` now returns `null` if `zoneName` is not a correct IANA timezone name.
* `datetime.Timezone.getZonesList() : Array<String>` return a list of all timezones names.
* `datetime.DateTime.local()` is now a `static` method wich returns user's current local date&time.
* new enum: `datetime.DTMonth` - contains list of months.
* `datetime.DateTime.monthStart()` is a private method now. Use `getMonthStart(month:DTMonth) : DateTime` instead.
* `datetime.DateTime.yearStart()` is a private method now. Use `snap(Year(Down)) : DateTime` instead.
* new classes which describe periods between time changes in timezone: `datetime.utils.pack.TZPeriod`, `datetime.utils.pack.DstRule`. Both implement `datetime.utils.pack.IPeriod`
* `datetime.Timezone.getAllPeriods() : Array<IPeriod>` - returns all periods between timechanges in this zone
* `datetime.Timezone.getPeriodForLocal(localDateTime) : TZPeriod` - returns period which contains `localDateTime`
* `datetime.Timezone.getPeriodForUtc(utc) : TZPeriod` - returns period wich contains `utc`
* Changed TZdata file format (reduced from 2.5Mb to 116Kb)
* Added script for 'semi-automatic' TZdata updates: `haxelib run datetime`
