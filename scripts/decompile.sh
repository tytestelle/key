#!/bin/bash

set -e


echo "================================"
echo " KU9 Decompile Start"
echo "================================"


APK="input/ku9.apk"

OUT="output"


if [ ! -f "$APK" ]; then

    echo "APK not found"

    exit 1

fi


rm -rf "$OUT"

mkdir -p "$OUT"



echo "[1/6] apktool"


java -jar tools/apktool.jar \
d "$APK" \
-o "$OUT/apktool" \
--force



echo "[2/6] extract dex"


mkdir -p "$OUT/dex"


unzip -o \
"$APK" \
"classes*.dex" \
-d "$OUT/dex"



echo "[3/6] baksmali"


mkdir -p "$OUT/smali"


for dex in "$OUT"/dex/classes*.dex

do

    NAME=$(basename "$dex" .dex)


    echo "Decode $NAME"


    java -jar tools/baksmali.jar \
    d "$dex" \
    -o "$OUT/smali/$NAME"

done



echo "[4/6] dex2jar"


mkdir -p "$OUT/jar"


for dex in "$OUT"/dex/classes*.dex

do

    NAME=$(basename "$dex" .dex)


    echo "Convert $NAME"


    sh tools/dex-tools/d2j-dex2jar.sh \
    "$dex" \
    -o "$OUT/jar/$NAME.jar" \
    --force

done



echo "[5/6] CFR"


mkdir -p "$OUT/java"


for jar in "$OUT"/jar/*.jar

do

    NAME=$(basename "$jar" .jar)


    mkdir -p "$OUT/java/$NAME"


    echo "CFR $NAME"


    java -jar tools/cfr.jar \
    "$jar" \
    --outputdir "$OUT/java/$NAME" \
    --silent true

done



echo "[6/6] copy resources"


cp -r "$OUT/apktool/res" "$OUT/" || true


cp -r "$OUT/apktool/assets" "$OUT/" || true


cp "$OUT/apktool/AndroidManifest.xml" "$OUT/" || true



echo "================================"
echo " Finished"
echo "================================"
