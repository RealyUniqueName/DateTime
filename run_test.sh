#!/bin/bash

haxe test_full.hxml

chmod +x build/java/Test.jar

echo "\n\n===> CPP"
time ./build/cpp/Test

echo "\n\n===> PHP"
time php build/php/index.php

echo "\n\n===> NEKO"
time neko /build/test.n

echo "\n\n===> JS"
time nodejs /build/test.js

echo "\n\n===> JAVA"
time ./build/java/Test.jar