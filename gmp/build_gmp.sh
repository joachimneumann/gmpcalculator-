#!/bin/bash

set -x

CURRENT=`pwd`
__pr="--print-path"
__name="xcode-select"
DEVELOPER=`${__name} ${__pr}`

GMP_VERSION="6.2.1"

SDKVERSION=`xcrun -sdk iphoneos --show-sdk-version`

MIN_IOS="14.0"

BITCODE=""

OSX_PLATFORM=`xcrun --sdk macosx --show-sdk-platform-path`
OSX_SDK=`xcrun --sdk macosx --show-sdk-path`

IPHONEOS_PLATFORM=`xcrun --sdk iphoneos --show-sdk-platform-path`
IPHONEOS_SDK=`xcrun --sdk iphoneos --show-sdk-path`

IPHONESIMULATOR_PLATFORM=`xcrun --sdk iphonesimulator --show-sdk-platform-path`
IPHONESIMULATOR_SDK=`xcrun --sdk iphonesimulator --show-sdk-path`

CLANG=`xcrun --sdk iphoneos --find clang`
CLANGPP=`xcrun --sdk iphoneos --find clang++`


# downloadGMP()
# {
#     if [ ! -s ${CURRENT}/gmp-${GMP_VERSION}.tar.bz2 ]; then
#         echo "Downloading GMP"
#         curl -L -o ${CURRENT}/gmp-${GMP_VERSION}.tar.bz2 ftp://ftp.gmplib.org/pub/gmp/gmp-${GMP_VERSION}.tar.bz2
#     fi
# }

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
	# &> "${CURRENT}/gmplib-${ARCH}-configure.log"

	echo "make in progress for ${ARCH}"
	make -j `sysctl -n hw.logicalcpu_max` &> "${CURRENT}/gmplib-${ARCH}-build.log"
	# if [ "${ARCH}" == "i386" ]; then
		# echo "check in progress for ${ARCH}"
		# make check &> "${CURRENT}/gmplib-${ARCH}-check.log"
	# fi
	echo "install in progress for ${ARCH}"
	make install &> "${CURRENT}/gmplib-${ARCH}-install.log"
}

# downloadGMP

# rm -rf gmp
# tar xfj "gmp-${GMP_VERSION}.tar.bz2"
# mv gmp-${GMP_VERSION} gmp

cd gmp
CURRENT=`pwd`

build "arm64" "${IPHONEOS_SDK}" "${IPHONEOS_PLATFORM}" 
# build "i386" "${IPHONESIMULATOR_SDK}" "${IPHONESIMULATOR_PLATFORM}"
build "x64_86" "${OSX_SDK}" "${OSX_PLATFORM}"



rm -rf dist
mkdir dist

cp ${CURRENT}/gmplib-arm64/lib/libgmp.a  ${CURRENT}/dist/libgmp.arm64.a
cp ${CURRENT}/gmplib-x64_86/lib/libgmp.a ${CURRENT}/dist/libgmp.x64_86.a
cp ${CURRENT}/gmplib-arm64/include/gmp.h ${CURRENT}/dist/include

echo "################"
echo "####  DONE  ####"
echo "################"
echo ${CURRENT}/dist/libgmp.arm64.a
echo ${CURRENT}/dist/libgmp.x64_86.a
echo ${CURRENT}/dist/include/gmp.h

