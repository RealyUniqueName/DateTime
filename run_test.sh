#!/bin/bash

if (haxe test_full.hxml); then

    chmod +x ./build/debug/java/Test-Debug.jar
    chmod +x ./build/java/Test.jar

    echo
    echo
    echo "===> CPP"
    echo "[Debug]"
    time ./build/debug/cpp/Test-debug
    echo "[Release]"
    time ./build/cpp/Test

    echo
    echo
    echo "===> JS"
    echo "[Debug]"
    time nodejs build/debug/test.js
    echo "[Release]"
    time nodejs build/test.js

    echo
    echo
    echo "===> JAVA"
    echo "[Debug]"
    time ./build/debug/java/Test-Debug.jar
    echo "[Release]"
    time ./build/java/Test.jar

    echo
    echo
    echo "===> C#"
    echo "[Debug]"
    time mono ./build/debug/cs/bin/Test-Debug.exe
    echo "[Release]"
    time mono ./build/cs/bin/Test.exe

    echo
    echo
    echo "===> PYTHON"
    echo "[Debug]"
    time python3 build/debug/test.py
    echo "[Release]"
    time python3 build/test.py

    echo
    echo
    echo "===> PHP"
    echo "[Debug]"
    time php build/debug/php/index.php
    echo "[Release]"
    time php build/php/index.php

    echo
    echo
    echo "===> PHP7"
    echo "[Debug]"
    time php build/debug/php7/index.php
    echo "[Release]"
    time php build/php7/index.php

    echo
    echo
    echo "===> NEKO"
    echo "[Debug]"
    time neko build/debug/test.n
    echo "[Release]"
    time neko build/test.n
fi