#!/bin/bash

set -e

echo "=================================="
echo " KU9 APK Decompile Start"
echo "=================================="

APK_FILE="input/ku9.apk"
OUTPUT="output"

APKTOOL_JAR="tools/apktool.jar"
JADX_BIN="tools/jadx/bin/jadx"


# =========================
# Check APK
# =========================

if [ ! -f "$APK_FILE" ]; then
    echo "ERROR: APK not found:"
    echo "$APK_FILE"
    exit 1
fi


# =========================
# Clean
# =========================

rm -rf "$OUTPUT"

mkdir -p "$OUTPUT"


# =========================
# Apktool
# =========================

echo ""
echo "[1/5] Apktool decode..."

java -jar "$APKTOOL_JAR" \
    d "$APK_FILE" \
    -o "$OUTPUT/apktool" \
    --force \
    --no-debug-info


# =========================
# JADX
# =========================

echo ""
echo "[2/5] JADX decompile..."

"$JADX_BIN" \
    --deobf \
    --show-bad-code \
    -d "$OUTPUT/java" \
    "$APK_FILE"


# =========================
# Extract dex
# =========================

echo ""
echo "[3/5] Extract dex..."

mkdir -p "$OUTPUT/dex"

unzip -o "$APK_FILE" \
    "classes*.dex" \
    -d "$OUTPUT/dex" || true


# =========================
# Copy APK
# =========================

echo ""
echo "[4/5] Copy original APK..."

cp "$APK_FILE" "$OUTPUT/original.apk"


# =========================
# Information
# =========================

echo ""
echo "[5/5] Generate info..."

echo "APK:"
echo "$APK_FILE"

echo "Date:"
date


echo ""
echo "=================================="
echo " DONE"
echo " Output:"
echo "$OUTPUT"
echo "=================================="
