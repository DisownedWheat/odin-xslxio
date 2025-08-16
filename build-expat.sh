#!/bin/sh

wget https://github.com/libexpat/libexpat/releases/download/R_2_7_1/expat-2.7.1.tar.gz
tar xf expat-2.7.1.tar.gz
rm expat-2.7.1.tar.gz
pushd expat-2.7.1

./configure --prefix=$PWD/build/
make install

popd
mv expat-2.7.1/build/lib/libexpat.a lib

rm -r expat-2.7.1
