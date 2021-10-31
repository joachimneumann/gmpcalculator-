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
	COMPILEARGS=$4
	CONFIGUREARGS=$5

	make clean
	make distclean

	export PATH="${PLATFORM}/Developer/usr/bin:${DEVELOPER}/usr/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

	CFLAGS="${BITCODE} -isysroot ${SDK} -Wno-error -Wno-implicit-function-declaration -arch ${ARCH} ${COMPILEARGS}"

	./configure CC="${CLANG} ${CFLAGS}"  CPP="${CLANG} -E"  CPPFLAGS="${CFLAGS}" \
	--host=aarch64-apple-darwin --disable-assembly --enable-static --disable-shared ${CONFIGUREARGS}

	echo "make in progress for ${ARCH}"
	make &> "${CURRENT}/build.log"
}


rm -rf iPhone simulator x86_64-catalyst arm64-catalyst
mkdir iPhone simulator x86_64-catalyst arm64-catalyst

cd gmp
build "arm64" "${IPHONEOS_SDK}" "${IPHONEOS_PLATFORM}"
cp .libs/libgmp.a ../iPhone/libgmp.a

build "x86_64" "${IPHONESIMULATOR_SDK}" "${IPHONESIMULATOR_PLATFORM}"
cp .libs/libgmp.a ../simulator/libgmp.a

build "x86_64" "${OSX_SDK}" "${OSX_PLATFORM}" "-target x86_64-apple-ios-macabi"
cp .libs/libgmp.a ../x86_64-catalyst/libgmp.a

build "arm64" "${OSX_SDK}" "${OSX_PLATFORM}" "-target x86_64-apple-ios-macabi"
cp .libs/libgmp.a ../arm64-catalyst/libgmp.a
cd ..

pwd=`pwd`

cd mpfr
build "arm64" "${IPHONEOS_SDK}" "${IPHONEOS_PLATFORM}" "" "--with-gmp-lib=${pwd}/iPhone --with-gmp-include=${pwd}/include"
cp src/.libs/libmpfr.a ../iPhone/libmpfr.a

build "x86_64" "${IPHONESIMULATOR_SDK}" "${IPHONESIMULATOR_PLATFORM}" "" "--with-gmp-lib=${pwd}/simulator --with-gmp-include=${pwd}/include"
cp src/.libs/libmpfr.a ../simulator/libmpfr.a

build "x86_64" "${OSX_SDK}" "${OSX_PLATFORM}" "-target x86_64-apple-ios-macabi" "--with-gmp-lib=${pwd}/x86_64-catalyst --with-gmp-include=${pwd}/include"
cp src/.libs/libmpfr.a ../x86_64-catalyst/libmpfr.a

build "arm64" "${OSX_SDK}" "${OSX_PLATFORM}" "-target x86_64-apple-ios-macabi" "--with-gmp-lib=${pwd}/arm64-catalyst --with-gmp-include=${pwd}/include"
cp src/.libs/libmpfr.a ../arm64-catalyst/libmpfr.a
cd ..

rm -rf signed
mkdir signed
cp -r iPhone simulator x86_64-catalyst arm64-catalyst signed

# code signing: get the correct expanded identity with the command $security find-identity
identity='A4E25604F83A7BDD478B07BC86807B554C447B97'
codesign -s ${identity} signed/iPhone/libgmp.a
codesign -s ${identity} signed/simulator/libgmp.a
codesign -s ${identity} signed/x86_64-catalyst/libgmp.a
codesign -s ${identity} signed/arm64-catalyst/libgmp.a
codesign -s ${identity} signed/iPhone/libmpfr.a
codesign -s ${identity} signed/simulator/libmpfr.a
codesign -s ${identity} signed/x86_64-catalyst/libmpfr.a
codesign -s ${identity} signed/arm64-catalyst/libmpfr.a

mkdir signed/catalyst;
lipo -create signed/x86_64-catalyst/libgmp.a  signed/arm64-catalyst/libgmp.a -output signed/catalyst/libgmp.a
lipo -create signed/x86_64-catalyst/libmpfr.a  signed/arm64-catalyst/libmpfr.a -output signed/catalyst/libmpfr.a


# Troubleshooting:
# remove frameworks from copy in build phases
# Exclusive Access to memory: compile time only
