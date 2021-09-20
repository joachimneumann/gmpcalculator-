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

	mkdir mpfrlib-${ARCH}

	EXTRAS=""
	if [ "${ARCH}" != "x64_86" ]; then
		# EXTRAS="-miphoneos-version-min=${MIN_IOS} -no-integrated-as -arch ${ARCH} -target ${ARCH}-apple-darwin"
		EXTRAS="-miphoneos-version-min=${MIN_IOS} -no-integrated-as -arch ${ARCH} -target x86_64-apple-ios13.0-macabi"
	fi

	CFLAGS="${BITCODE} -isysroot ${SDK} -Wno-error -Wno-implicit-function-declaration ${EXTRAS}"

	./configure --prefix="${CURRENT}/mpfrlib-${ARCH}" CC="${CLANG} ${CFLAGS}"  CPP="${CLANG} -E"  CPPFLAGS="${CFLAGS}" \
	--host=aarch64-apple-darwin --disable-assembly --enable-static --disable-shared ${ARGS} --with-gmp-lib=../dist/${ARCH} --with-gmp-include=../dist/include

	echo "make in progress for ${ARCH}"
	make -j `sysctl -n hw.logicalcpu_max` &> "${CURRENT}/mpfrlib-${ARCH}-build.log"
	echo "install in progress for ${ARCH}"
	make install &> "${CURRENT}/mpfrlib-${ARCH}-install.log"
}


cd mpfr
CURRENT=`pwd`

build "arm64" "${IPHONEOS_SDK}" "${IPHONEOS_PLATFORM}"
build "x64_86" "${OSX_SDK}" "${OSX_PLATFORM}"

cp ${CURRENT}/mpfrlib-arm64/lib/libmpfr.a      ${CURRENT}/../dist/arm64/libmpfr.a
cp ${CURRENT}/mpfrlib-x64_86/lib/libmpfr.a     ${CURRENT}/../dist/x64_86/libmpfr.a
cp ${CURRENT}/mpfrlib-arm64/include/mpfr.h     ${CURRENT}/../dist/include
cp ${CURRENT}/mpfrlib-arm64/include/mpf2mpfr.h ${CURRENT}/../dist/include

# echo "################"
# echo "####  DONE  ####"
# echo "################"
# echo ${CURRENT}/dist/libgmp.arm64.a
# echo ${CURRENT}/dist/libgmp.x64_86.a
# echo ${CURRENT}/dist/include/gmp.h
