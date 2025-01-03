#!/bin/env bash

# Credit: carberra
# https://github.com/parafoxia/python-scripts
# https://www.youtube.com/watch?v=S4HfueSI-ow
# modifed by: alphaveneno
# Date: 2024/12/26
# tested on MX Linux 23.1 (linux kernel 6.5.0), Debian 12.8 (linux kernel 6.12.4), Fedora 41 (live USB, linux kernel 6.11.4)
# with python 3.10.15, 3.11.2, 3.12.7 & 3.13.0
# script is for all versions of Linux

# to give read/write/execution rights for this script _solely_ to the user:
# 1) open a terminal in the _same_ directory as this script
# 2) run: sudo chmod 700 uninstall-python.sh

# example usage (assumes terminal is opened in same directory as script):
# ./uninstall-python.sh 3.12 (regular command)
# or
# sudo ./uninstall-python.sh 3.12 (regular command using root privileges)
# or
# /usr/bin/sudo ./uninstall-python.sh 3.12 (fully-qualified command)
# or
# $(which sudo) ./uninstall-python.sh 3.12 (secure fully-qualified command)


BIN_PATH=/usr/local/bin
LIB_PATH=/usr/local/lib
USER_BIN_PATH=/home/${USER}/.local/bin
USER_LIB_PATH=/home/${USER}/.local/lib
USER_WHEEL_PATH=/home/${USER}/.local/share/virtualenv/wheel

# if you forgot to give at least one command-line argument ...
if [ $# -eq 0 ]; then
    $(which echo) "You must provide at least one Python version."
    $(which echo) "For example, to uninstall Python3.12, type in:"
    $(which echo) "./uninstall-python.sh 3.12"
    $(which echo) "DO NOT add the 'patch' version"
    $(which echo) "For example, do not type in: ./uninstall-python.sh 3.12.7"
    exit 2
fi

$(which echo) "You are about to uninstall the following Python versions:
"
for VER do
    $(which echo) " * ${VER}"
done
read -p "
THIS ACTION IS IRREVERSIBLE. Are you sure you want to continue? (y/N): " confirm && [[ $confirm == [yY] ]] || exit 1

for VER do
    $(which echo) "Uninstalling Python $VER..."

    # Check if Python version exists.
    if [ ! -f "${BIN_PATH}/python${VER}" ]; then
        $(which echo) "That Python version is not installed, or you have supplied a patch version."
        exit 2
    fi

    # Remove files. There may not be a 2to3-${VER} file with 3.13 and beyond
    # As of 3.12, python${VER}-embed.pc and python${VER}.pc files
    # are found in a directory called 'pkgconfig' (see below)
    $(which sudo) $(which rm) -rf "${BIN_PATH}/2to3-${VER}" \
        "${BIN_PATH}/idle${VER}" \
        "${BIN_PATH}/pip${VER}" \
        "${BIN_PATH}/pydoc${VER}" \
        "${BIN_PATH}/python${VER}" \
        "${BIN_PATH}/python${VER}-config" \
        "${LIB_PATH}/libpython${VER}.so" \
        "${LIB_PATH}/libpython${VER}.so.1.0" \
        "${LIB_PATH}/python${VER}" \
        "${LIB_PATH}/pkgconfig/python$-{VER}-embed.pc" \
        "${LIB_PATH}/pkgconfig/python$-{VER}.pc" \
        "${LIB_PATH}/python${VER}-embed.pc" \
        "${LIB_PATH}/libpython${VER}.a" \
        "${LIB_PATH}/python${VER}.pc" \
        "${USER_LIB_PATH}/python${VER}" \
        "${USER_BIN_PATH}/pip${VER}" \
        "${USER_WHEEL_PATH}/${VER}"
     
     # remove any scripts put in this directory created by
     # versions of python you have designated for removal.
     # does not touch scripts from versions of python you are retaining.
     for FILE in "${USER_BIN_PATH}"/*; do
     	# Check if the file is a regular file and not a directory
     	if [ -f "${FILE}" ]; then
     		# Read the first line of the file
     		FIRST_LINE=$(head -n 1 "${FILE}")
     		# Check if the first line contains the specified Python version
     		if [[ "${FIRST_LINE}" == *"/usr/local/bin/python${VER}"* ]]; then
     			$(which echo) "Deleting ${FILE}"
     			# Delete the file
     			$(which sudo) $(which rm) "${FILE}"
     		fi
     	fi
     done
done

$(which echo) "All done!"
