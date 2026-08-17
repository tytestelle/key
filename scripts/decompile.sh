#!/bin/bash

set -e


echo "=================================="
echo " KU9 APK Decompile Start"
echo "=================================="


APK_FILE="input/ku9.apk"

OUTPUT="output"

APKTOOL="tools/apktool.jar"

JADX="tools/bin/jadx"



# =====================
# 检查 APK
# =====================

if [ ! -f "$APK_FILE" ]; then

    echo "APK not found:"
    echo "$APK_FILE"

    exit 1

fi



# =====================
# 清理输出
# =====================

rm -rf "$OUTPUT"

mkdir -p "$OUTPUT"



# =====================
# apktool
# =====================

echo ""
echo "[1/5] Apktool decode"


java -jar "$APKTOOL" \
    d "$APK_FILE" \
    -o "$OUTPUT/apktool" \
    --force



# =====================
# jadx
# =====================

echo ""
echo "[2/5] JADX decompile"


"$JADX" \
    --deobf \
    --show-bad-code \
    -d "$OUTPUT/java" \
    "$APK_FILE"



# =====================
# dex
# =====================

echo ""
echo "[3/5] Extract dex"


mkdir -p "$OUTPUT/dex"


unzip -o "$APK_FILE" \
    "classes*.dex" \
    -d "$OUTPUT/dex" || true



# =====================
# 原 APK
# =====================

echo ""
echo "[4/5] Copy APK"


cp "$APK_FILE" "$OUTPUT/original.apk"



# =====================
# 信息
# =====================

echo ""
echo "[5/5] Complete"


echo "Output:"
echo "$OUTPUT"


echo ""
echo "=================================="
echo " KU9 Decompile Finished"
echo "=================================="
