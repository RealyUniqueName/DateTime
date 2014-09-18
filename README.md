DateTime
========

Custom date-time (and date-time arithmetics) implementation for Haxe.

DateTime is an abstract type on top of Float, so it does not create any objects (unlike standart Haxe Date class) and saves your memory :)

Also it supports dates from 16 777 215 b.c. to 16 777 215 a.d. (maybe even more)

DateTime is up to 7 times faster than standart Date class depending on target (except Javascript target where DateTime is up to 7 times slower than Date depending on browser)