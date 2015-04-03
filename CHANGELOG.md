3.0.0
------------------------------
* `datetime.Timezone.get(zoneName)` now returns `null` if `zoneName` is not a correct IANA timezone name.
* `datetime.Timezone.getZonesList() : Array<String>` return a list of all timezones names.
* `datetime.DateTime.local()` is now a `static` method wich returns user's current local date&time.
* `datetime.DateTime.monthStart()` is a private method now. Use `getMonthStart(month:DTMonth) : DateTime` instead.
* `datetime.DateTime.monthStart()` is a private method now. Use `snap(Year(Down)) : DateTime` instead.
* Changed TZdata file format (reduced from 2.5Mb to 116Kb)
* Added script for 'semi-automatic' TZdata updates: `haxelib run datetime`