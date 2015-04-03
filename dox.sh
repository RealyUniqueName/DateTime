#!/bin/dash

haxe -xml build/doc.xml -cp src -cp test -main Test
haxelib run dox -i build -o build/dox -ex '/cores\|cores\|TZAbr\|data\|Decoder\|IntervalUtils\|MonthUtils\|SnapUtils\|MacroUtils\|neDetect\|zoneUtils\|TimeUtils\|TimeUtils/i'