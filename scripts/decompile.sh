#!/bin/bash

set -e


APK=input/ku9.apk

OUT=output


echo "=========================="
echo " KU9 Decompile "
echo "=========================="


rm -rf $OUT

mkdir -p $OUT



echo "[1] apktool"


java -jar tools/apktool.jar \
d $APK \
-o $OUT/apktool \
--force



echo "[2] extract dex"


mkdir -p $OUT/dex


unzip -o \
$APK \
"classes*.dex" \
-d $OUT/dex



echo "[3] dex2jar"


mkdir -p $OUT/jar


for dex in $OUT/dex/classes*.dex

do

NAME=$(basename $dex .dex)


echo "convert $NAME"


java -cp tools/dex-tools.jar \
com.googlecode.dex2jar.tools.Dex2jarCmd \
$dex \
-o $OUT/jar/$NAME.jar \
--force


done



echo "[4] CFR"


mkdir -p $OUT/java


for jar in $OUT/jar/*.jar

do

NAME=$(basename $jar .jar)


mkdir -p $OUT/java/$NAME


java -jar tools/cfr.jar \
$jar \
--outputdir $OUT/java/$NAME \
--silent true


done



echo "[5] resources"


cp -r $OUT/apktool/res $OUT/ || true

cp -r $OUT/apktool/assets $OUT/ || true

cp $OUT/apktool/AndroidManifest.xml $OUT/ || true



echo "DONE"
