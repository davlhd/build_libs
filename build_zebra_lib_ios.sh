#!/bin/bash

set +aux

echo
echo "Hello from the build script"
echo 
echo "IOS_SDK_NAME:    $IOS_SDK_NAME"
echo "IOS_DEPLOY_TGT:  $IOS_DEPLOY_TGT"
echo "CURRENT_ARCH:    $CURRENT_BASE_ARCH"
echo "CC:              $CC"
echo "CXX:             $CXX"
echo "LD:              $LD"
echo "SDKROOT:         $SDKROOT"
echo "DEVROOT:         $DEVROOT"
echo "XCODETOOLCHAIN_PATH:      $XCODETOOLCHAIN_PATH"
echo "SHARED_CXXFLAGS:          $SHARED_CXXFLAGS"
echo "BUILD_OUT:                $BUILD_OUT"
echo
echo "Build your lib and put the"
echo " * static library into \$BUILD_OUT/lib"
echo " * header files into \$BUILD_OUT/include"
echo



function cloneRepo {
	git clone https://github.com/glassechidna/zxing-cpp.git vendor/zxing 
	git -C vendor/zxing checkout b80a24cc6e6dc6f119048ca85c5e76938a516cfb
}

 

if [ -z ${BUILD_OUT+x} ]; then echo "\n\$BUILD_OUT is not set. Exiting. \n" && exit 1; fi

# If vendor/zxing does not exist, clone it
[ ! -d "vendor/zxing" ] && cloneRepo

# Create the build dir and copy the source over 
# (so that we don't modify the original source for the next build)
rm -rf $BUILD_TMP_DIR/zxing
mkdir -p $BUILD_TMP_DIR/zxing
cp -rf vendor/zxing/* $BUILD_TMP_DIR/zxing/

cd $BUILD_TMP_DIR/zxing

mkdir -p build && cd build

cmake  -GXcode \
      -DCMAKE_INSTALL_PREFIX=$BUILD_OUT/ \
      -DCMAKE_IOS_SDK_ROOT=$SDKROOT \
      -DCMAKE_C_FLAGS=-Wno-implicit-function-declaration \
      -DCMAKE_TOOLCHAIN_FILE=$AL_MK_ROOT/ios_toolchain.cmake \
      -DCMAKE_CXX_FLAGS="$SHARED_CXXFLAGS -DNO_ICONV  -DUSE_STD_NAMESPACE" \
      ..


xcodebuild -quiet IPHONEOS_DEPLOYMENT_TARGET=$IOS_DEPLOY_TGT \
      -parallelizeTargets -jobs 8 -sdk $IOS_SDK_NAME ONLY_ACTIVE_ARCH=NO ARCHS=$CURRENT_ARCH \
      -project zxing.xcodeproj \
      -configuration Release \
      -target libzxing \
      CONFIGURATION_BUILD_DIR=$BUILD_TMP_DIR/build_dir/


find "$BUILD_TMP_DIR/build_dir" -name "*.a" -exec cp {} $BUILD_OUT/lib \;

cp -rf $BUILD_TMP_DIR/zxing//core/src/zxing $BUILD_OUT/include/zxing
find $BUILD_OUT/include/zxing -type f -not -name '*.h' -delete
