#!/bin/sh

RETURNDIR=$PWD
cd libzip
mkdir build
cd build
cmake .. -DBUILD_SHARED_LIBS=OFF -DLIBZIP_DO_INSTALL=OFF -DENABLE_BZIP2=OFF -DENABLE_LZMA=OFF -DENABLE_ZSTD=OFF
make

cd $RETURNDIR
mv libzip/build/lib/libzip.a lib/linux
rm -r libzip/build/
