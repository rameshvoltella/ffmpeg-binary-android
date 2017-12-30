#!/bin/bash

set -e
set -x

export TARGET=$1
export PREFIX=$2

ARM_PLATFORM=$NDK/platforms/android-16/arch-arm/
ARM_PREBUILT=$NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64

ARM64_PLATFORM=$NDK/platforms/android-21/arch-arm64/
ARM64_PREBUILT=$NDK/toolchains/aarch64-linux-android-4.9/prebuilt/darwin-x86_64

X86_PLATFORM=$NDK/platforms/android-16/arch-x86/
X86_PREBUILT=$NDK/toolchains/x86-4.9/prebuilt/darwin-x86_64

X86_64_PLATFORM=$NDK/platforms/android-21/arch-x86_64/
X86_64_PREBUILT=$NDK/toolchains/x86_64-4.9/prebuilt/darwin-x86_64

MIPS_PLATFORM=$NDK/platforms/android-16/arch-mips/
MIPS_PREBUILT=$NDK/toolchains/mipsel-linux-android-4.9/prebuilt/darwin-x86_64

MIPS64_PLATFORM=$NDK/platforms/android-21/arch-mips64/
MIPS64_PREBUILT=$NDK/toolchains/mips64el-linux-android-4.9/prebuilt/darwin-x86_64


FFMPEG_VERSION="3.3.2"
if [ ! -d "ffmpeg-${FFMPEG_VERSION}" ]; then
    echo "Downloading ffmpeg-${FFMPEG_VERSION}.tar.bz2"
    curl -LO http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.bz2
    echo "extracting ffmpeg-${FFMPEG_VERSION}.tar.bz2"
    tar -xvf ffmpeg-${FFMPEG_VERSION}.tar.bz2
else
    echo "Using existing `pwd`/ffmpeg-${FFMPEG_VERSION}"
fi

YASM_VERSION="1.3.0"
if [ ! -d "yasm-${YASM_VERSION}" ]; then
    echo "Downloading yasm-${YASM_VERSION}"
    curl -O "http://www.tortall.net/projects/yasm/releases/yasm-${YASM_VERSION}.tar.gz"
    tar -xvzf "yasm-${YASM_VERSION}.tar.gz"
else
    echo "Using existing `pwd`/yasm-${YASM_VERSION}"
fi

# if [ ! -d "x264" ]; then
#     echo "Cloning x264"
#     git clone --depth=1 git://git.videolan.org/x264.git x264
# else
#     echo "Using existing `pwd`/x264"
# fi

OPUS_VERSION="1.1.5"
if [ ! -d "opus-${OPUS_VERSION}" ]; then
    echo "Downloading opus-${OPUS_VERSION}"
    curl -LO https://archive.mozilla.org/pub/opus/opus-${OPUS_VERSION}.tar.gz
    tar -xvzf opus-${OPUS_VERSION}.tar.gz
else
    echo "Using existing `pwd`/opus-${OPUS_VERSION}"
fi

# FDK_AAC_VERSION="0.1.5"
# if [ ! -d "fdk-aac-${FDK_AAC_VERSION}" ]; then
#     echo "Downloading fdk-aac-${FDK_AAC_VERSION}"
#     curl -LO http://downloads.sourceforge.net/opencore-amr/fdk-aac-${FDK_AAC_VERSION}.tar.gz
#     tar -xvzf fdk-aac-${FDK_AAC_VERSION}.tar.gz
# else
#     echo "Using existing `pwd`/fdk-aac-${FDK_AAC_VERSION}"
# fi

LAME_MAJOR="3.99"
LAME_VERSION="3.99.5"
if [ ! -d "lame-${LAME_VERSION}" ]; then
    echo "Downloading lame-${LAME_VERSION}"
    curl -LO http://downloads.sourceforge.net/project/lame/lame/${LAME_MAJOR}/lame-${LAME_VERSION}.tar.gz
    tar -xvzf lame-${LAME_VERSION}.tar.gz
    curl -L -o lame-${LAME_VERSION}/config.guess "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD"
    curl -L -o lame-${LAME_VERSION}/config.sub "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD"
else
    echo "Using existing `pwd`/lame-${LAME_VERSION}"
fi

if [ ! -d "shine" ]; then
    echo "Cloning https://github.com/toots/shine"
    git clone --depth=1 https://github.com/toots/shine.git
else
    echo "Using existing `pwd`/shine"
fi

LIBOGG_VERSION="1.3.2"
if [ ! -d "libogg-${LIBOGG_VERSION}" ]; then
    echo "Downloading libogg-${LIBOGG_VERSION}"
    curl -LO http://downloads.xiph.org/releases/ogg/libogg-${LIBOGG_VERSION}.tar.gz
    tar -xvzf libogg-${LIBOGG_VERSION}.tar.gz
else
    echo "Using existing `pwd`/libogg-${LIBOGG_VERSION}"
fi

LIBVORBIS_VERSION="1.3.4"
if [ ! -d "libvorbis-${LIBVORBIS_VERSION}" ]; then
    echo "Downloading libvorbis-${LIBVORBIS_VERSION}"
    curl -LO http://downloads.xiph.org/releases/vorbis/libvorbis-${LIBVORBIS_VERSION}.tar.gz
    tar -xvzf libvorbis-${LIBVORBIS_VERSION}.tar.gz
else
    echo "Using existing `pwd`/libvorbis-${LIBVORBIS_VERSION}"
fi

# LIBVPX_VERSION="1.6.1"
# if [ ! -d "libvpx-${LIBVPX_VERSION}" ]; then
#     echo "Downloading libvpx-${LIBVPX_VERSION}"
#     curl -LO http://storage.googleapis.com/downloads.webmproject.org/releases/webm/libvpx-${LIBVPX_VERSION}.tar.bz2
#     tar -xvf libvpx-${LIBVPX_VERSION}.tar.bz2
# else
#     echo "Using existing `pwd`/libvpx-${LIBVPX_VERSION}"
# fi


function build_one
{
if [ $ARCH == "arm" ]
then
    PLATFORM=$ARM_PLATFORM
    PREBUILT=$ARM_PREBUILT
    HOST=arm-linux-androideabi
#added by alexvas
elif [ $ARCH == "arm64" ]
then
    PLATFORM=$ARM64_PLATFORM
    PREBUILT=$ARM64_PREBUILT
    HOST=aarch64-linux-android
elif [ $ARCH == "mips" ]
then
    PLATFORM=$MIPS_PLATFORM
    PREBUILT=$MIPS_PREBUILT
    HOST=mipsel-linux-android
elif [ $ARCH == "mips64" ]
then
    PLATFORM=$MIPS64_PLATFORM
    PREBUILT=$MIPS64_PREBUILT
    HOST=mips64el-linux-android
elif [ $ARCH == "x86_64" ]
then
    PLATFORM=$X86_64_PLATFORM
    PREBUILT=$X86_64_PREBUILT
    HOST=x86_64-linux-android
else
    PLATFORM=$X86_PLATFORM
    PREBUILT=$X86_PREBUILT
    HOST=i686-linux-android
fi

export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
export CROSS_PREFIX=$PREBUILT/bin/$HOST-

pushd yasm-${YASM_VERSION}
CPP="${CROSS_PREFIX}cpp" \
CXX="${CROSS_PREFIX}g++" \
CC="${CROSS_PREFIX}gcc" \
LD="${CROSS_PREFIX}ld" \
AR="${CROSS_PREFIX}ar" \
NM="${CROSS_PREFIX}nm" \
RANLIB="${CROSS_PREFIX}ranlib" \
LDFLAGS="-fPIE -pie " \
CFLAGS="$OPTIMIZE_CFLAGS --sysroot=$PLATFORM -fPIE " \
CXXFLAGS="--sysroot=$PLATFORM " \
CPPFLAGS="--sysroot=$PLATFORM " \
STRIP=${CROSS_PREFIX}strip \
./configure \
    --prefix=$PREFIX \
    --host=$HOST

make clean
make -j8
make install
popd

# pushd x264
# CPP="${CROSS_PREFIX}cpp" \
# CXX="${CROSS_PREFIX}g++" \
# CC="${CROSS_PREFIX}gcc" \
# LD="${CROSS_PREFIX}ld" \
# AR="${CROSS_PREFIX}ar" \
# NM="${CROSS_PREFIX}nm" \
# RANLIB="${CROSS_PREFIX}ranlib" \
# STRIP=${CROSS_PREFIX}strip \
# LDFLAGS="-fPIE -pie " \
# CFLAGS="-fPIE " \
# ./configure \
#     --cross-prefix=$PREBUILT/bin/$HOST- \
#     --sysroot=$PLATFORM \
#     --host=$HOST \
#     --enable-pic \
#     --enable-static \
#     --disable-shared \
#     --disable-cli \
#     --extra-cflags="$OPTIMIZE_CFLAGS " \
#     --prefix=$PREFIX
# make clean
# make -j8
# make install
# popd

pushd opus-${OPUS_VERSION}
CPP="${CROSS_PREFIX}cpp" \
CXX="${CROSS_PREFIX}g++" \
CC="${CROSS_PREFIX}gcc" \
LD="${CROSS_PREFIX}ld" \
AR="${CROSS_PREFIX}ar" \
NM="${CROSS_PREFIX}nm" \
RANLIB="${CROSS_PREFIX}ranlib" \
LDFLAGS="-fPIE -pie " \
CFLAGS="$OPTIMIZE_CFLAGS --sysroot=$PLATFORM -fPIE " \
CXXFLAGS="--sysroot=$PLATFORM " \
CPPFLAGS="--sysroot=$PLATFORM " \
STRIP=${CROSS_PREFIX}strip \
./configure \
    --prefix=$PREFIX \
    --host=$HOST \
    --enable-static \
    --disable-shared \
    --disable-doc \
    --disable-extra-programs

make clean
make -j8
make install V=1
popd


# Non-free
# pushd fdk-aac-${FDK_AAC_VERSION}
# CPP="${CROSS_PREFIX}cpp" \
# CXX="${CROSS_PREFIX}g++" \
# CC="${CROSS_PREFIX}gcc" \
# LD="${CROSS_PREFIX}ld" \
# AR="${CROSS_PREFIX}ar" \
# NM="${CROSS_PREFIX}nm" \
# RANLIB="${CROSS_PREFIX}ranlib" \
# LDFLAGS="-fPIE -pie " \
# CFLAGS="$OPTIMIZE_CFLAGS --sysroot=$PLATFORM -fPIE " \
# CXXFLAGS="--sysroot=$PLATFORM " \
# CPPFLAGS="--sysroot=$PLATFORM " \
# STRIP=${CROSS_PREFIX}strip \
# ./configure \
#     --prefix=$PREFIX \
#     --host=$HOST \
#     --enable-static \
#     --disable-shared \
#     --with-sysroot=$PLATFORM
# make clean
# make -j8
# make install
# popd

pushd lame-${LAME_VERSION}
CPP="${CROSS_PREFIX}cpp" \
CXX="${CROSS_PREFIX}g++" \
CC="${CROSS_PREFIX}gcc" \
LD="${CROSS_PREFIX}ld" \
AR="${CROSS_PREFIX}ar" \
NM="${CROSS_PREFIX}nm" \
RANLIB="${CROSS_PREFIX}ranlib" \
LDFLAGS="-fPIE -pie " \
CFLAGS="$OPTIMIZE_CFLAGS --sysroot=$PLATFORM -fPIE " \
CXXFLAGS="--sysroot=$PLATFORM " \
CPPFLAGS="--sysroot=$PLATFORM " \
STRIP=${CROSS_PREFIX}strip \
./configure \
    --prefix=$PREFIX \
    --host=$HOST \
    --enable-static \
    --disable-shared \
    --enable-nasm

make clean
make -j8
make install
popd

pushd shine
./bootstrap
CPP="${CROSS_PREFIX}cpp" \
CXX="${CROSS_PREFIX}g++" \
CC="${CROSS_PREFIX}gcc" \
LD="${CROSS_PREFIX}ld" \
AR="${CROSS_PREFIX}ar" \
NM="${CROSS_PREFIX}nm" \
RANLIB="${CROSS_PREFIX}ranlib" \
LDFLAGS="-fPIE -pie " \
CFLAGS="$OPTIMIZE_CFLAGS --sysroot=$PLATFORM -fPIE " \
CXXFLAGS="--sysroot=$PLATFORM " \
CPPFLAGS="--sysroot=$PLATFORM " \
STRIP=${CROSS_PREFIX}strip \
./configure \
    --prefix=$PREFIX \
    --host=$HOST \
    --enable-static \
    --disable-shared

make clean
make -j8
make install
popd

pushd libogg-${LIBOGG_VERSION}
CPP="${CROSS_PREFIX}cpp" \
CXX="${CROSS_PREFIX}g++" \
CC="${CROSS_PREFIX}gcc" \
LD="${CROSS_PREFIX}ld" \
AR="${CROSS_PREFIX}ar" \
NM="${CROSS_PREFIX}nm" \
RANLIB="${CROSS_PREFIX}ranlib" \
LDFLAGS="-fPIE -pie " \
CFLAGS="$OPTIMIZE_CFLAGS --sysroot=$PLATFORM -fPIE " \
CXXFLAGS="--sysroot=$PLATFORM " \
CPPFLAGS="--sysroot=$PLATFORM " \
STRIP=${CROSS_PREFIX}strip \
./configure \
    --prefix=$PREFIX \
    --host=$HOST \
    --enable-static \
    --disable-shared \
    --with-sysroot=$PLATFORM
make clean
make -j8
make install
popd

pushd libvorbis-${LIBVORBIS_VERSION}
CPP="${CROSS_PREFIX}cpp" \
CXX="${CROSS_PREFIX}g++" \
CC="${CROSS_PREFIX}gcc" \
LD="${CROSS_PREFIX}ld" \
AR="${CROSS_PREFIX}ar" \
NM="${CROSS_PREFIX}nm" \
RANLIB="${CROSS_PREFIX}ranlib" \
LDFLAGS="-fPIE -pie " \
CFLAGS="$OPTIMIZE_CFLAGS --sysroot=$PLATFORM -fPIE " \
CXXFLAGS="--sysroot=$PLATFORM " \
CPPFLAGS="--sysroot=$PLATFORM " \
STRIP=${CROSS_PREFIX}strip \
./configure \
    --prefix=$PREFIX \
    --host=$HOST \
    --enable-static \
    --disable-shared \
    --with-sysroot=$PLATFORM \
    --with-ogg=$PREFIX
make clean
make -j8
make install
popd

# (wget --no-check-certificate https://raw.githubusercontent.com/FFmpeg/gas-preprocessor/master/gas-preprocessor.pl && \
#     chmod +x gas-preprocessor.pl && \
#     sudo mv gas-preprocessor.pl /usr/bin) || exit 1

pushd ffmpeg-$FFMPEG_VERSION
PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" \
CPP="${CROSS_PREFIX}cpp" \
CXX="${CROSS_PREFIX}g++" \
CC="${CROSS_PREFIX}gcc" \
LD="${CROSS_PREFIX}ld" \
AR="${CROSS_PREFIX}ar" \
NM="${CROSS_PREFIX}nm" \
RANLIB="${CROSS_PREFIX}ranlib" \
STRIP=${CROSS_PREFIX}strip \
./configure --prefix=$PREFIX \
    --target-os=linux \
    --arch=$ARCH \
    --cross-prefix=$CROSS_PREFIX \
    --enable-cross-compile \
    --sysroot=$PLATFORM \
    --pkg-config=/usr/local/bin/pkg-config \
    --pkg-config-flags="--static" \
    --extra-ldflags="-L$PREFIX/lib -fPIE -pie " \
    --extra-cflags="$OPTIMIZE_CFLAGS -I$PREFIX/include -fPIE " \
    --enable-pic \
    --enable-small \
    --enable-gpl \
    \
    --disable-shared \
    --enable-static \
    \
    --enable-ffmpeg \
    --disable-ffplay \
    --disable-ffprobe \
    --disable-ffserver \
    \
    --disable-protocols \
    --enable-protocol='file,pipe' \
    \
    --enable-libshine \
    --enable-libmp3lame \
    --enable-libopus \
    --enable-libvorbis \
    --enable-bsf=aac_adtstoasc \
    \
    --disable-demuxers \
    --disable-muxers \
    --enable-demuxer='mp4,flv,matroska,webm,mov,3gp,mp3,libmp3lame,libshine,aac,aac_latm,m4a,vorbis,ogg,opus,mp4a,mpegts,image2,mjpeg,jpeg,ipod,dnxhd' \
    --enable-muxer='mp4,flv,matroska,webm,3gp,mp3,libmp3lame,libshine,aac,aac_latm,m4a,vorbis,ogg,opus,mp4a,mpegts,mjpeg,jpeg,image2,ipod,dnxhd' \
    \
    --disable-encoders \
    --disable-decoders \
    --enable-encoder='mp4,m4a,aac,aac_latm,mp3,libmp3lame,libshine,mp4a,mjpeg,jpeg,image2,ipod,dnxhd' \
    --enable-decoder='mp4,flv,matroska,webm,mov,3gp,mp3,libmp3lame,libshine,aac,aac_latm,m4a,vorbis,ogg,opus,mp4a,mjpeg,jpeg,image2,ipod,dnxhd' \
    \
    --disable-doc \
    $ADDITIONAL_CONFIGURE_FLAG

make clean
make -j8
make install V=1
popd
}

if [ $TARGET == 'arm-v5te' ]; then
    #arm v5te
    CPU=armv5te
    ARCH=arm
    OPTIMIZE_CFLAGS="-marm -march=$CPU -Os -O3"
    ADDITIONAL_CONFIGURE_FLAG=
    build_one
elif [ $TARGET == 'arm-v6' ]; then
    #arm v6
    CPU=armv6
    ARCH=arm
    OPTIMIZE_CFLAGS="-marm -march=$CPU -Os -O3"
    ADDITIONAL_CONFIGURE_FLAG=
    build_one
elif [ $TARGET == 'arm-v7vfpv3' ]; then
    #arm v7vfpv3
    CPU=armv7-a
    ARCH=arm
    OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=vfpv3-d16 -marm -march=$CPU -Os -O3 "
    ADDITIONAL_CONFIGURE_FLAG=
    build_one
elif [ $TARGET == 'arm-v7vfp' ]; then
    #arm v7vfp
    CPU=armv7-a
    ARCH=arm
    OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=vfp -marm -march=$CPU -Os -O3 "
    ADDITIONAL_CONFIGURE_FLAG=
    build_one
elif [ $TARGET == 'arm-v7n' ]; then
    #arm v7n
    CPU=armv7-a
    ARCH=arm
    OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=neon -marm -mtune=cortex-a8 -march=$CPU -Os -O3"
    ADDITIONAL_CONFIGURE_FLAG=--enable-neon
    build_one
elif [ $TARGET == 'arm-v6+vfp' ]; then
    #arm v6+vfp
    CPU=armv6
    ARCH=arm
    OPTIMIZE_CFLAGS="-DCMP_HAVE_VFP -mfloat-abi=softfp -mfpu=vfp -marm -march=$CPU -Os -O3"
    ADDITIONAL_CONFIGURE_FLAG=
    build_one
elif [ $TARGET == 'arm64-v8a' ]; then
    #arm64-v8a
    CPU=armv8-a
    ARCH=arm64
    OPTIMIZE_CFLAGS="-march=$CPU -Os -O3"
    ADDITIONAL_CONFIGURE_FLAG=
    build_one
elif [ $TARGET == 'x86_64' ]; then
    #x86_64
    CPU=x86-64
    ARCH=x86_64
    OPTIMIZE_CFLAGS="-fomit-frame-pointer -march=$CPU -Os -O3"
    ADDITIONAL_CONFIGURE_FLAG=
    build_one
elif [ $TARGET == 'i686' ]; then
    #x86
    CPU=i686
    ARCH=i686
    OPTIMIZE_CFLAGS="-fomit-frame-pointer -march=$CPU -Os -O3"
    ADDITIONAL_CONFIGURE_FLAG=
    build_one
elif [ $TARGET == 'mips' ]; then
    #mips
    CPU=mips32
    ARCH=mips
    OPTIMIZE_CFLAGS="-march=$CPU -Os -O3"
    #"-std=c99 -O3 -Wall -pipe -fpic -fasm -ftree-vectorize -ffunction-sections -funwind-tables -fomit-frame-pointer -funswitch-loops -finline-limit=300 -finline-functions -fpredictive-commoning -fgcse-after-reload -fipa-cp-clone -Wno-psabi -Wa,--noexecstack"
    ADDITIONAL_CONFIGURE_FLAG=
    build_one
elif [ $TARGET == 'mips64' ]; then
    #mips
    CPU=mips64r6
    ARCH=mips64
    OPTIMIZE_CFLAGS="-march=$CPU -Os -O3"
    #"-std=c99 -O3 -Wall -pipe -fpic -fasm -ftree-vectorize -ffunction-sections -funwind-tables -fomit-frame-pointer -funswitch-loops -finline-limit=300 -finline-functions -fpredictive-commoning -fgcse-after-reload -fipa-cp-clone -Wno-psabi -Wa,--noexecstack"
    ADDITIONAL_CONFIGURE_FLAG=
    build_one
elif [ $TARGET == 'armv7-a' ]; then
    #arm armv7-a
    CPU=armv7-a
    ARCH=arm
    OPTIMIZE_CFLAGS="-mfloat-abi=softfp -marm -march=$CPU -Os -O3 "
    ADDITIONAL_CONFIGURE_FLAG=
    build_one
elif [ $TARGET == 'arm' ]; then
    #arm
    CPU=armv5te
    ARCH=arm
    OPTIMIZE_CFLAGS="-march=$CPU -Os -O3 "
    ADDITIONAL_CONFIGURE_FLAG=
    build_one
fi
