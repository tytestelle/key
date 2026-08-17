#!/bin/bash

set -e


echo "=================================="
echo " KU9 Decompile (No JADX)"
echo "=================================="


APK="input/ku9.apk"

OUT="output"


if [ ! -f "$APK" ]; then

    echo "APK not found:"
    echo "$APK"

    exit 1

fi


rm -rf "$OUT"

mkdir -p "$OUT"



echo "[1/6] apktool decode"


java -jar tools/apktool.jar \
d "$APK" \
-o "$OUT/apktool" \
--force



echo "[2/6] Extract dex"


mkdir -p "$OUT/dex"


unzip -o "$APK" \
"classes*.dex" \
-d "$OUT/dex"



echo "[3/6] baksmali"


mkdir -p "$OUT/smali"


for dex in "$OUT"/dex/*.dex

do

    name=$(basename "$dex" .dex)

    echo "smali $name"


    java -jar tools/baksmali.jar \
    d "$dex" \
    -o "$OUT/smali/$name"

done



echo "[4/6] dex2jar"


mkdir -p "$OUT/jar"


for dex in "$OUT"/dex/*.dex

do

    name=$(basename "$dex" .dex)


    sh tools/dex-tools/d2j-dex2jar.sh \
    "$dex" \
    -o "$OUT/jar/$name.jar" \
    --force

done



echo "[5/6] CFR decompile"


mkdir -p "$OUT/java"


for jar in "$OUT"/jar/*.jar

do

    name=$(basename "$jar" .jar)


    mkdir -p "$OUT/java/$name"


    java -jar tools/cfr.jar \
    "$jar" \
    --outputdir "$OUT/java/$name" \
    --silent true

done



echo "[6/6] Copy resources"


cp -r "$OUT/apktool/res" "$OUT/" || true

cp -r "$OUT/apktool/assets" "$OUT/" || true

cp "$OUT/apktool/AndroidManifest.xml" "$OUT/" || true



echo "=================================="
echo " DONE"
echo "Output:"
echo "$OUT"
echo "=================================="
