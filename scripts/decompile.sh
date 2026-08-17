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

    echo "ERROR: APK not found:"
    echo "$APK_FILE"

    exit 1

fi



# =====================
# 清理旧文件
# =====================

rm -rf "$OUTPUT"

mkdir -p "$OUTPUT"



# =====================
# apktool 解包
# =====================

echo ""
echo "[1/6] Apktool decode"


java -jar "$APKTOOL" \
    d "$APK_FILE" \
    -o "$OUTPUT/apktool" \
    --force



# =====================
# jadx 反编译
# =====================

echo ""
echo "[2/6] JADX decompile"


"$JADX" \
    --deobf \
    --show-bad-code \
    --no-imports \
    --threads-count 4 \
    -d "$OUTPUT/java" \
    "$APK_FILE" || true



# =====================
# dex备份
# =====================

echo ""
echo "[3/6] Extract dex"


mkdir -p "$OUTPUT/dex"


unzip -o "$APK_FILE" \
    "classes*.dex" \
    -d "$OUTPUT/dex" || true



# =====================
# 复制原APK
# =====================

echo ""
echo "[4/6] Copy original APK"


cp "$APK_FILE" "$OUTPUT/original.apk"



# =====================
# 生成结构信息
# =====================

echo ""
echo "[5/6] Generate file list"


find "$OUTPUT" > "$OUTPUT/filelist.txt"



# =====================
# 完成
# =====================

echo ""
echo "[6/6] Finished"


echo "Output:"
echo "$OUTPUT"


echo "=================================="
echo " KU9 Decompile Finished"
echo "=================================="
