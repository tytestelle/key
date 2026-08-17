#!/bin/bash

set -e

APK_FILE="input/ku9.apk"

OUT_DIR="output"

APKTOOL="tools/apktool.jar"
JADX="tools/jadx/bin/jadx"

echo "=============================="
echo " KU9 APK Decompile Start"
echo "=============================="

# 检查 APK
if [ ! -f "$APK_FILE" ]; then
    echo "ERROR: APK not found:"
    echo "$APK_FILE"
    exit 1
fi


# 清理旧目录
rm -rf "$OUT_DIR"

mkdir -p "$OUT_DIR"


echo "[1/4] apktool decode..."

java -jar "$APKTOOL" \
    d "$APK_FILE" \
    -o "$OUT_DIR/apktool" \
    --force


echo "[2/4] jadx decompile..."

"$JADX" \
    -d "$OUT_DIR/java" \
    "$APK_FILE"


echo "[3/4] extract dex..."

mkdir -p "$OUT_DIR/dex"

unzip -j "$APK_FILE" \
    "classes*.dex" \
    -d "$OUT_DIR/dex" || true


echo "[4/4] copy metadata..."

cp "$APK_FILE" "$OUT_DIR/original.apk"


echo ""
echo "=============================="
echo " KU9 Decompile Finished"
echo "=============================="

echo ""
echo "Output:"
echo "$OUT_DIR"
