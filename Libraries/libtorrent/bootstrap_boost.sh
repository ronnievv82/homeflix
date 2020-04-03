#!/bin/bash

BOOST_TARBALL="boost.tar.gz"

DIR=`pwd` 
SRC_DIR="${DIR}/boost/src"
BUILD_DIR="${DIR}/build"

clean() {
	rm ${BOOST_TARBALL}
	rm -rf ${SRC_DIR}
	rm -rf ${BUILD_DIR}
}

download() {
	curl -L -o ${BOOST_TARBALL} \
		"https://dl.bintray.com/boostorg/release/1.72.0/source/boost_1_72_0.tar.gz"
}

extract() {
	rm -rf ${SRC_DIR} && mkdir -p ${SRC_DIR}
	tar -xzf ${BOOST_TARBALL} --strip 1 -C ${SRC_DIR}
}

clean
download
extract

rm ${BOOST_TARBALL}

echo "Done."
