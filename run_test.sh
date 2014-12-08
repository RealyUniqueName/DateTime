#!/bin/bash

if (haxe test_full.hxml); then

    chmod +x build/java/Test.jar

    echo
    echo
    echo "===> CPP"
    time ./build/cpp/Test

    echo
    echo
    echo "===> PHP"
    time php build/php/index.php

    echo
    echo
    echo "===> NEKO"
    time neko build/test.n

    echo
    echo
    echo "===> JS"
    time nodejs build/test.js

    echo
    echo
    echo "===> JAVA"
    time ./build/java/Test.jar

fi