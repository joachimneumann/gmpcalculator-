clang -arch arm64 -isysroot `xcrun --sdk iphoneos         --show-sdk-path` -miphoneos-version-min=13.0 -fembed-bitcode -c add.c
ar rc add.iPhone.a add.o
codesign -s 5D0F9B026D6B6975270955D7CA9A986F6D6B0DE1 add.iPhone.a

clang -arch x86_64 -isysroot `xcrun --sdk iphonesimulator --show-sdk-path` -miphoneos-version-min=13.0 -fembed-bitcode -c add.c
ar rc add.simulator.a add.o
codesign -s 5D0F9B026D6B6975270955D7CA9A986F6D6B0DE1 add.simulator.a

clang -arch x86_64 -isysroot `xcrun --sdk macosx          --show-sdk-path` -miphoneos-version-min=13.0 -fembed-bitcode -target x86_64-apple-ios-macabi -c add.c
ar rc add.catalyist.a add.o
codesign -s 5D0F9B026D6B6975270955D7CA9A986F6D6B0DE1 add.catalyist.a

rm -rf add.xcframework
xcodebuild -create-xcframework -library add.simulator.a -library add.iPhone.a -library add.catalyist.a -output add.xcframework
