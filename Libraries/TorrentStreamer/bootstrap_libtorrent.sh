#!/bin/bash

LIBTORRENT_TARBALL="libtorrent.tar.gz"

DIR=`pwd` 
SRC_DIR="${DIR}/unpack"

clean() {
	rm ${LIBTORRENT_TARBALL}
	rm -rf ${SRC_DIR}
}

download() {
	curl -L -o ${LIBTORRENT_TARBALL} \
		"https://github.com/arvidn/libtorrent/releases/download/libtorrent-1_2_5/libtorrent-rasterbar-1.2.5.tar.gz"
}

extract() {
	rm -rf ${SRC_DIR} && mkdir ${SRC_DIR}
	tar -xzf ${LIBTORRENT_TARBALL} --strip 1 -C ${SRC_DIR}
}

clean
download
extract

cp -R "${SRC_DIR}/src" "${DIR}/torrent/"
cp -R "${SRC_DIR}/ed25519/src" "${DIR}/torrent/ed25519/"

rm -rf "${DIR}/include/libtorrent"
cp -R "${SRC_DIR}/include/libtorrent" "${DIR}/include/"

rm ${LIBTORRENT_TARBALL}
rm -rf ${SRC_DIR}

echo "Done."