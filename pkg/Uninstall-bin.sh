#!/bin/bash

ENDO_DIRS="/usr/local/share/endoh1"

ENDO_FILES="/usr/local/bin/show_endo"

user=`id -u -n`

[ "${user}" == "root" ] || {
  echo "Uninstall-bin.sh must be run as the root user."
  echo "Use 'sudo ./Uninstall-bin.sh ...'"
  echo "Exiting"
  exit 1
}

rm -f ${ENDO_FILES}
rm -rf ${ENDO_DIRS}
