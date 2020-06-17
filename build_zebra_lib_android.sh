#!/bin/bash

set +aux

echo
echo "Hello from the build script"
echo 
echo "ANDROID_NDK:     $ANDROID_NDK"
echo "ANDROID_API_LVL: $ANDROID_API_LVL"
echo "CURRENT_ARCH:    $CURRENT_BASE_ARCH"
echo "CC:              $CC"
echo "CXX:             $CXX"
echo "LD:              $LD"
echo "ANDROID_NDK_SYSROOT:      $ANDROID_NDK_SYSROOT"
echo "LIBCXXABI_INCLUDE:        $LIBCXXABI_INCLUDE"
echo "LIBCXX_INCLUDE:           $LIBCXX_INCLUDE"
echo "ANDROID_SUPPORT_INCLUDE:  $ANDROID_SUPPORT_INCLUDE"
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

 

if [ -z ${ANDROID_NDK+x} ]; then echo "\n\$ANDROID_NDK is not set. Exiting. \n" && exit 1; fi

# If vendor/zxing does not exist, clone it
[ ! -d "vendor/zxing" ] && cloneRepo

# Create the build dir and copy the source over 
# (so that we don't modify the original source for the next build)
rm -rf $BUILD_TMP_DIR/zxing
mkdir -p $BUILD_TMP_DIR/zxing
cp -rf vendor/zxing/* $BUILD_TMP_DIR/zxing/

cd $BUILD_TMP_DIR/zxing

mkdir -p build && cd build

cmake -DCMAKE_INSTALL_PREFIX=$BUILD_OUT/ \
	  -DANDROID_NDK=$ANDROID_NDK \
      -DCMAKE_C_FLAGS=-Wno-implicit-function-declaration \
      -DCMAKE_CXX_FLAGS="-DNO_ICONV  -DUSE_STD_NAMESPACE -DANDROID" \
      -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
	  -DANDROID_TOOLCHAIN=clang -DANDROID_STL=c++_shared \
      -DANDROID_ABI=$CURRENT_ARCH \
      -DANDROID_NATIVE_API_LEVEL=$ANDROID_API_LVL \
      ..

make

find "$BUILD_TMP_DIR/zxing" -name "*.a" -exec cp {} $BUILD_OUT/lib \;
cp -rf $BUILD_TMP_DIR/zxing//core/src/zxing $BUILD_OUT/include/zxing
find $BUILD_OUT/include/zxing -type f -not -name '*.h' -delete
