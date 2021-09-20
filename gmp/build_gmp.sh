#!/bin/bash

set -x

CURRENT=`pwd`
__pr="--print-path"
__name="xcode-select"
DEVELOPER=`${__name} ${__pr}`

SDKVERSION=`xcrun -sdk iphoneos --show-sdk-version`

MIN_IOS="14.0"

BITCODE="-fembed-bitcode"

OSX_PLATFORM=`xcrun --sdk macosx --show-sdk-platform-path`
OSX_SDK=`xcrun --sdk macosx --show-sdk-path`

IPHONEOS_PLATFORM=`xcrun --sdk iphoneos --show-sdk-platform-path`
IPHONEOS_SDK=`xcrun --sdk iphoneos --show-sdk-path`

IPHONESIMULATOR_PLATFORM=`xcrun --sdk iphonesimulator --show-sdk-platform-path`
IPHONESIMULATOR_SDK=`xcrun --sdk iphonesimulator --show-sdk-path`

CLANG=`xcrun --sdk iphoneos --find clang`
CLANGPP=`xcrun --sdk iphoneos --find clang++`


build()
{
	ARCH=$1
	SDK=$2
	PLATFORM=$3
	ARGS=$4

	make clean
	make distclean

	export PATH="${PLATFORM}/Developer/usr/bin:${DEVELOPER}/usr/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

	mkdir gmplib-${ARCH}

	EXTRAS=""
	if [ "${ARCH}" != "x64_86" ]; then
		EXTRAS="-miphoneos-version-min=${MIN_IOS} -no-integrated-as -arch ${ARCH} -target ${ARCH}-apple-darwin"
	fi

	CFLAGS="${BITCODE} -isysroot ${SDK} -Wno-error -Wno-implicit-function-declaration ${EXTRAS}"

	./configure --prefix="${CURRENT}/gmplib-${ARCH}" CC="${CLANG} ${CFLAGS}"  CPP="${CLANG} -E"  CPPFLAGS="${CFLAGS}" \
	--host=aarch64-apple-darwin --disable-assembly --enable-static --disable-shared ${ARGS}

	echo "make in progress for ${ARCH}"
	make -j `sysctl -n hw.logicalcpu_max` &> "${CURRENT}/gmplib-${ARCH}-build.log"
	echo "install in progress for ${ARCH}"
	make install &> "${CURRENT}/gmplib-${ARCH}-install.log"
}


rm -rf dist
mkdir dist
mkdir dist/arm64
mkdir dist/x64_86
mkdir dist/include

cd gmp
CURRENT=`pwd`

build "arm64" "${IPHONEOS_SDK}" "${IPHONEOS_PLATFORM}"
# build "i386" "${IPHONESIMULATOR_SDK}" "${IPHONESIMULATOR_PLATFORM}"
build "x64_86" "${OSX_SDK}" "${OSX_PLATFORM}"


cp ${CURRENT}/gmplib-arm64/lib/libgmp.a  ${CURRENT}/../dist/arm64/libgmp.a
cp ${CURRENT}/gmplib-x64_86/lib/libgmp.a ${CURRENT}/../dist/x64_86/libgmp.a
cp ${CURRENT}/gmplib-arm64/include/gmp.h ${CURRENT}/../dist/include/gmp.h

echo "################"
echo "####  DONE  ####"
echo "################"
echo ${CURRENT}/dist/arm64/libgmp.a
echo ${CURRENT}/dist/x64_86/libgmp.a
echo ${CURRENT}/dist/include/gmp.h
