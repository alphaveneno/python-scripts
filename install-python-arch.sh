#!/bin/env bash

# Original author: carberra
# https://github.com/parafoxia/python-scripts
# https://www.youtube.com/watch?v=S4HfueSI-ow
# modified by: alphaveneno
# Date: 2025_01_19
# tested on: ArchLinux, 6.12.9-arch1-1
# tested with python 3.10.15, 3.11.9, 3.12.7
# script is for Arch-derived versions of Linux OS (e.g, Arch, Manjaro, ArcoLinux and so on)

# RedHat-derived and Debian-derived versions of Linux (e.g; Debian, Ubuntu, Fedora), Slack,
# OpenSuse-derived versions and other major Linux distributions
# have some different commands and extension suffixes from Arch

# to give read/write/execution rights for this script _solely_ to the user:
# 1) open a terminal in the _same_ directory as this script
# 2) run: sudo chmod 700 install-python-arch.sh

# example usage (assumes terminal is opened in same directory as script):
# ./install-python-arch.sh 3.12.7 (regular command)
# or 
# sudo ./install-python-arch.sh 3.12.7 (regular command using root privileges)
# or
# usr/bin/sudo ./install-python-arch.sh 3.12.7 (fully-qualified command)
# or
# $(which sudo) ./install-python-arch.sh 3.12.7 (secure fully-qualified command)

$(which sudo) $(which echo) "If your password needs to be entered you will be prompted to do so here"

if [ $# -eq 0 ]; then
    $(which echo) "You must provide at least one Python version."
    $(which echo) "specifying the major, minor and patch versions"
    $(which echo) "For example, to install Python3.12.7, type in:"
    $(which echo) "./install-python-arch.sh 3.12.7, not './install-python-arch.sh 3.12'"
    exit 2
fi

# adjust this file to set your language preference if you need to,
# be prepared, it is very verbose
# $(which sudo) $(which nano) /etc/locale.gen

$(which echo) "Configuring packages..."
yes | $(which sudo) $(which pacman) -Syu > /dev/null 2>&1

# setup the compiler environment before further installations
$(which sudo) $(which pacman) -S --needed base-devel python > /dev/null 2>&1

$(which echo) "Installing Arch-specific dependencies..."
$(which sudo) $(which pacman) -S --needed --no-confirm \
        libffi \
	openssl \
	sqlite \
	xz \
	bzip2 \
	gdbm \
	ncurses \
	nss \
	readline \
	tk \
	zlib \
	libuuid > /dev/null 2>&1

# remove unnecessary packages	
$(which sudo) $(which pacman) -Rns > /dev/null 2>&1

cd /tmp

for VER in "$@"; do

    # if alpha version:
    if [[ $VER == *"a"* ]]; then
        PARTIAL="$(cut -d 'a' -f 1 <<< $VER)"
    # if beta version:
    elif [[ $VER == *"b"* ]]; then
        PARTIAL="$(cut -d 'b' -f 1 <<< $VER)"
    # if release candidate version:
    elif [[ $VER == *"rc"* ]]; then
        PARTIAL="$(cut -d 'r' -f 1 <<< $VER)"
    else
        PARTIAL=$VER
    fi

    $(which echo) "Downloading Python $VER..."
    $(which wget) -q https://www.python.org/ftp/python/$PARTIAL/Python-$VER.tgz

    if [ ! -f Python-$VER.tgz ]; then
        $(which echo) "Either this Python version does not exist or the download failed, the relevant .tgz file is not found in the directory."
        exit 2
    fi

    # extract the files
    $(which tar) -xf Python-$VER.tgz

    cd Python-$VER

    $(which echo) "Configuring Python $VER..."
    # Note: pip is also installed
    ./configure -q --enable-optimizations --with-ensurepip=install  > /dev/null 2>&1

    # for faster installation, $(nproc) will run 'make' on all possible CPU cores on your system
    $(which echo) "Building Python $VER..."
    $(which make) -s -j $(nproc)  > /dev/null 2>&1

    $(which echo) "Installing Python $VER..."
    $(which sudo) $(which make) -s altinstall > /dev/null 2>&1

    # Get the major and minor versions of this Python
    PYTHON_MAJOR=$($(which echo) $VER | cut -d. -f1)
    PYTHON_MINOR=$($(which echo) $VER | cut -d. -f2)

    # update pip
    $(which echo) "Upgrading pip ..."
    python${PYTHON_MAJOR}.${PYTHON_MINOR} -m pip install --upgrade pip --disable-pip-version-check > /dev/null 2>&1
    
done

$(which echo) "All done!"
