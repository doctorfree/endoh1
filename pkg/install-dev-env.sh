#!/bin/bash
#
# install-dev-env.sh - install or remove the build dependencies

arch=
centos=
debian=
fedora=
[ -f /etc/os-release ] && . /etc/os-release
[ "${ID_LIKE}" == "debian" ] && debian=1
[ "${ID}" == "arch" ] || [ "${ID_LIKE}" == "arch" ] && arch=1
[ "${ID}" == "centos" ] && centos=1
[ "${ID}" == "fedora" ] && fedora=1
[ "${debian}" ] || [ -f /etc/debian_version ] && debian=1
[ "${arch}" ] || [ "${debian}" ] || [ "${fedora}" ] || [ "${centos}" ] || {
  echo "${ID_LIKE}" | grep debian > /dev/null && debian=1
}

if [ "${debian}" ]
then
  PKGS="build-essential coreutils make sed git tar gcc-10 cpp-10"
  if [ "$1" == "-r" ]
  then
    sudo apt remove ${PKGS}
  else
    sudo apt install ${PKGS} zip
    sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 100 \
        --slave /usr/bin/gcov gcov /usr/bin/gcov-10
  fi
else
  if [ "${arch}" ]
  then
    PKGS="base-devel"
    if [ "$1" == "-r" ]
    then
      sudo pacman -Rs ${PKGS}
    else
      sudo pacman -S --needed ${PKGS} zip
    fi
  else
    have_dnf=`type -p dnf`
    if [ "${have_dnf}" ]
    then
      PINS=dnf
    else
      PINS=yum
    fi
    sudo ${PINS} makecache
    if [ "${fedora}" ]
    then
      PKGS="glibc-static"
      if [ "$1" == "-r" ]
      then
        sudo ${PINS} -y remove ${PKGS}
        sudo ${PINS} -y groupremove "Development Tools" "Development Libraries"
      else
        sudo ${PINS} -y groupinstall "Development Tools" "Development Libraries"
        sudo ${PINS} -y install ${PKGS} zip
      fi
    else
      if [ "${centos}" ]
      then
        sudo alternatives --set python /usr/bin/python3
        PKGS="libtool automake"
        if [ "$1" == "-r" ]
        then
          sudo ${PINS} -y remove ${PKGS}
          sudo ${PINS} -y groupremove "Development Tools"
        else
          sudo ${PINS} -y groupinstall "Development Tools"
          sudo ${PINS} -y install ${PKGS} zip
        fi
      else
        echo "Unrecognized operating system"
      fi
    fi
  fi
fi
