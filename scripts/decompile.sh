name: KU9 Decompile CFR


on:

  workflow_dispatch:



permissions:

  contents: read



jobs:


  decompile:


    name: KU9 Source Extract


    runs-on: ubuntu-latest



    steps:



    - name: Checkout

      uses: actions/checkout@v4



    - name: Install environment

      run: |

        sudo apt update

        sudo apt install -y \
          wget \
          unzip \
          openjdk-17-jdk



    - name: Create tools

      run: |

        mkdir -p tools



    - name: Download apktool

      run: |

        wget \
        https://github.com/iBotPeaches/Apktool/releases/download/v3.0.3/apktool_3.0.3.jar \
        -O tools/apktool.jar



    - name: Download baksmali

      run: |

        wget \
        https://github.com/JesusFreke/smali/releases/download/v3.0.8/baksmali-3.0.8.jar \
        -O tools/baksmali.jar



    - name: Download smali

      run: |

        wget \
        https://github.com/JesusFreke/smali/releases/download/v3.0.8/smali-3.0.8.jar \
        -O tools/smali.jar



    - name: Download dex2jar

      run: |

        wget \
        https://github.com/pxb1988/dex2jar/releases/download/v2.4/dex-tools-2.4.zip \
        -O dex-tools.zip


        unzip -o dex-tools.zip


        DIR=$(find . -maxdepth 1 -type d -name "dex-tools*" | head -1)


        mv "$DIR" tools/dex-tools



    - name: Download CFR

      run: |

        wget \
        https://www.benf.org/other/cfr/cfr-0.152.jar \
        -O tools/cfr.jar



    - name: Check input

      run: |

        echo "APK files"

        ls -lh input



    - name: Decode APK resources

      run: |

        rm -rf output

        mkdir output


        java -jar tools/apktool.jar \
        d input/ku9.apk \
        -o output/apktool \
        --force



    - name: Extract dex files

      run: |

        mkdir -p output/dex


        unzip -o \
        input/ku9.apk \
        "classes*.dex" \
        -d output/dex



    - name: Decode smali

      run: |

        mkdir -p output/smali


        for dex in output/dex/classes*.dex

        do

          NAME=$(basename "$dex" .dex)


          echo "Baksmali $NAME"


          java -jar tools/baksmali.jar \
          d "$dex" \
          -o output/smali/$NAME


        done



    - name: Convert dex to jar

      run: |

        mkdir -p output/jar


        for dex in output/dex/classes*.dex

        do

          NAME=$(basename "$dex" .dex)


          echo "dex2jar $NAME"


          sh tools/dex-tools/d2j-dex2jar.sh \
          "$dex" \
          -o output/jar/$NAME.jar \
          --force


        done



    - name: CFR decompile

      run: |

        mkdir -p output/java


        for jar in output/jar/*.jar

        do

          NAME=$(basename "$jar" .jar)


          mkdir -p output/java/$NAME


          echo "CFR $NAME"


          java -jar tools/cfr.jar \
          "$jar" \
          --outputdir output/java/$NAME \
          --silent true


        done



    - name: Copy resources

      run: |

        cp -r output/apktool/res output/ || true


        cp -r output/apktool/assets output/ || true


        cp output/apktool/AndroidManifest.xml output/ || true



    - name: Show result

      run: |

        echo "========== RESULT =========="

        find output -maxdepth 2 -type d | sort



    - name: Package

      run: |

        zip -r KU9-CFR-source.zip output



    - name: Upload

      uses: actions/upload-artifact@v4


      with:

        name: KU9-CFR-source

        path: KU9-CFR-source.zip
