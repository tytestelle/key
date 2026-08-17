#!/bin/bash

set -e


echo "=============================="
echo " Apply KU9 Patch"
echo "=============================="


KU9_APK="input/ku9.apk"

DECODE_DIR="ku9_decode"



if [ ! -f "$KU9_APK" ]; then

    echo "ERROR: KU9 APK missing"

    exit 1

fi



echo "[1/6] Decode KU9 resource"


rm -rf "$DECODE_DIR"


java -jar tools/apktool.jar \
d "$KU9_APK" \
-o "$DECODE_DIR" \
--force



echo "[2/6] Find Android resource path"



RES_DIR=$(find . -type d -path "*/src/main/res" | head -n 1)


if [ -z "$RES_DIR" ]; then

    echo "ERROR: Cannot find Android res directory"

    echo "Project tree:"

    find . -maxdepth 4 -type d | head -50

    exit 1

fi



echo "Found res:"
echo "$RES_DIR"



ASSET_DIR=$(dirname "$RES_DIR")/assets



echo "[3/6] Backup resources"


mkdir -p backup


cp -r "$RES_DIR" backup/res_backup



echo "[4/6] Merge KU9 resources"



cp -rf \
"$DECODE_DIR/res/"* \
"$RES_DIR/"



echo "[5/6] Merge assets"



mkdir -p "$ASSET_DIR"


if [ -d "$DECODE_DIR/assets" ]; then

    cp -rf \
    "$DECODE_DIR/assets/"* \
    "$ASSET_DIR/" || true

fi



echo "[6/6] Save KU9 manifest"



cp \
"$DECODE_DIR/AndroidManifest.xml" \
backup/KU9_AndroidManifest.xml



echo "=============================="
echo " KU9 Patch Finished"
echo "=============================="
