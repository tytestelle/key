#!/bin/bash


set -e



echo "============================"

echo " KU9 DECOMPILE "

echo "============================"



APK="input/ku9.apk"

OUT="output"



if [ ! -f "$APK" ]; then

    echo "APK NOT FOUND"

    exit 1

fi



rm -rf "$OUT"

mkdir -p "$OUT"



echo "[1/5] Apktool"



java -jar tools/apktool.jar \
d "$APK" \
-o "$OUT/apktool" \
--force




echo "[2/5] Extract dex"



mkdir -p "$OUT/dex"



unzip -o \
"$APK" \
"classes*.dex" \
-d "$OUT/dex"




echo "[3/5] D8 convert"



mkdir -p "$OUT/jar"



for dex in "$OUT"/dex/classes*.dex

do


    NAME=$(basename "$dex" .dex)


    echo "convert $NAME"



    d8 \
    --min-api 21 \
    --output "$OUT/jar" \
    "$dex"



done




echo "[4/5] CFR"



mkdir -p "$OUT/java"



for jar in "$OUT"/jar/*.jar

do


    NAME=$(basename "$jar" .jar)



    mkdir -p "$OUT/java/$NAME"



    echo "java $NAME"



    java -jar tools/cfr.jar \
    "$jar" \
    --outputdir "$OUT/java/$NAME" \
    --silent true



done




echo "[5/5] Copy resources"



cp -r "$OUT/apktool/res" "$OUT/" || true


cp -r "$OUT/apktool/assets" "$OUT/" || true


cp "$OUT/apktool/AndroidManifest.xml" "$OUT/" || true



echo "============================"

echo " FINISHED "

echo "============================"
