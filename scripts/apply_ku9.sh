#!/bin/bash

set -e


echo "=============================="
echo " Apply KU9 Patch"
echo "=============================="


KU9_APK="input/ku9.apk"

DECODE_DIR="ku9_decode"


if [ ! -f "$KU9_APK" ]; then

    echo "KU9 APK missing"

    exit 1

fi



echo "[1/5] Decode KU9 resource"


rm -rf "$DECODE_DIR"


java -jar tools/apktool.jar \
d "$KU9_APK" \
-o "$DECODE_DIR" \
--force



echo "[2/5] Backup current resources"


mkdir -p backup


cp -r app/src/main/res backup/res_old || true



echo "[3/5] Merge KU9 resources"


cp -rf \
"$DECODE_DIR/res/"* \
app/src/main/res/



echo "[4/5] Merge assets"


mkdir -p app/src/main/assets


if [ -d "$DECODE_DIR/assets" ]; then

cp -rf \
"$DECODE_DIR/assets/"* \
app/src/main/assets/

fi



echo "[5/5] Save manifest"


cp \
"$DECODE_DIR/AndroidManifest.xml" \
backup/KU9_AndroidManifest.xml



echo "=============================="
echo " KU9 Patch Finished"
echo "=============================="
