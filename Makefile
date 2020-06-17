

export AL_MK_ROOT=$(shell pwd)
export DEPS_DIR=$(AL_MK_ROOT)/deps/



zebra-android: 
	rm -rf out/android
	rm -rf build/android

	make -f Makefile.android -e TARGET=android STL=clang ARCH=x86_64 zebra
	make -f Makefile.android -e TARGET=android STL=clang ARCH=armv7a zebra
	make -f Makefile.android -e TARGET=android STL=clang ARCH=arm64 zebra
	@echo 
	@echo "Building Library for Android done. Output can be found in ./out/android"

zebra-ios: 
	rm -rf out/ios
	rm -rf build/ios

	make -f Makefile.ios -e TARGET=ios STL=clang ARCH=x86_64 zebra
	make -f Makefile.ios -e TARGET=ios STL=clang ARCH=armv7 zebra
	make -f Makefile.ios -e TARGET=ios STL=clang ARCH=arm64 zebra
	@echo 
	@echo "Building Library for iOS done. Output can be found in ./out/ios"
