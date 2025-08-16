#!/bin/sh

RETURNDIR=$PWD
cd xlsxio
cmake -G"Unix Makefiles" -DCMAKE_INSTALL_PREFIX=$PWD/build -DBUILD_STATIC=ON -DWITH_LIBZIP=ON -DLIBZIP_PATH=../lib/linux/libzip.a
make install/strip

cd $RETURNDIR
cp xlsxio/build/lib/libxlsxio_read.a lib/linux
cp xlsxio/build/lib/libxlsxio_write.a lib/linux
rm -r xlsxio/build
