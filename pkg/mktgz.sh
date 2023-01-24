#!/bin/bash
PKG="endoh1"
PKG_NAME="endoh1"
DESTDIR="usr/local"
PLAT=`uname -s`
ARCH=`uname -m`
SUDO=sudo
HERE=`pwd`
USER=`id -u -n`

[ "${USER}" == "root" ] && {
  echo "mktgz.sh must be run as a non-root user with sudo privilege"
  echo "Exiting"
  exit 1
}

[ -f VERSION ] || {
  echo "mktgz.sh must be run in the root of the endoh1 source folder"
  echo "Exiting"
  exit 1
}

. ./VERSION
PKG_VER=${VERSION}
PKG_REL=${RELEASE}

umask 0022

# Subdirectory in which to create the distribution files
OUT_DIR="${HERE}/dist/${PKG_NAME}_${PKG_VER}"

group="root"
[ "${PLAT}" == "Darwin" ] && {
  group="wheel"
  have_brew=`type -p brew`
  [ "${have_brew}" ] && {
    brew install coreutils make gcc@12
  }
}

./build -p "/usr/local"

${SUDO} rm -rf dist
mkdir dist

[ -d ${OUT_DIR} ] && rm -rf ${OUT_DIR}
mkdir ${OUT_DIR}

for dir in "usr" "${DESTDIR}" "${DESTDIR}/share" \
           "${DESTDIR}/bin" "${DESTDIR}/share/${PKG}"
do
    [ -d ${OUT_DIR}/${dir} ] || ${SUDO} mkdir ${OUT_DIR}/${dir}
    ${SUDO} chown root:${group} ${OUT_DIR}/${dir}
done

${SUDO} cp endoh1 ${OUT_DIR}/${DESTDIR}/bin/endoh1
${SUDO} cp endoh1_color ${OUT_DIR}/${DESTDIR}/bin/endoh1_color
${SUDO} cp LICENSE ${OUT_DIR}/${DESTDIR}/share/${PKG}
${SUDO} cp README.md ${OUT_DIR}/${DESTDIR}/share/${PKG}
${SUDO} cp VERSION ${OUT_DIR}/${DESTDIR}/share/${PKG}

${SUDO} chmod 755 ${OUT_DIR}/${DESTDIR}/bin/* \
                  ${OUT_DIR}/${DESTDIR}/bin
find ${OUT_DIR}/${DESTDIR}/share/${PKG} -type d | while read dir
do
  ${SUDO} chmod 755 "${dir}"
done
find ${OUT_DIR}/${DESTDIR}/share/${PKG} -type f | while read f
do
  ${SUDO} chmod 644 "${f}"
done
${SUDO} chown -R root:${group} ${OUT_DIR}/${DESTDIR}

cd ${OUT_DIR}
echo "Creating compressed tar archive of ${PKG_NAME} ${PKG_VER} distribution"
${SUDO} tar cf - ${DESTDIR}/*/* | gzip -9 > ../${PKG_NAME}_${PKG_VER}-${PKG_REL}.${PLAT}.${ARCH}.tgz

echo "Creating zip archive of ${PKG_NAME} ${PKG_VER} distribution"
${SUDO} zip -q -r ../${PKG_NAME}_${PKG_VER}-${PKG_REL}.${PLAT}.${ARCH}.zip ${DESTDIR}/*/*

cd ..
[ -d ../releases ] || mkdir ../releases
[ -d ../releases/${PKG_VER} ] || mkdir ../releases/${PKG_VER}
${SUDO} cp *.tgz *.zip ../releases/${PKG_VER}
