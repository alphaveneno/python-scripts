#!/bin/env bash

# Original author: carberra
# https://github.com/parafoxia/python-scripts
# https://www.youtube.com/watch?v=S4HfueSI-ow
# modified by: alphaveneno
# Date: 2025/01/23
# tested on: MX Linux 23.1 (linux kernel 6.5.0), Debian 12.8 (linux kernel 6.12.4)
# tested with python 3.10.15, 3.12.7 & 3.13.0
# script is for Debian-derived versions of Linux OS (e.g, Debian, Ubuntu, MX Linux, Linux Mint and so on)

# Arch-derived versions of Linux (e.g; Arch, Manjaro, ArcoLinux), Slack,
# OpenSuse-derived versions, RedHat-derived versions (e.g; Fedora, Rocky, Centos) 
# and other major Linux distributions
# have some different commands and extension suffixes from Debian

# to give read/write/execution rights for this script _solely_ to the user:
# 1) open a terminal in the _same_ directory as this script
# 2) run: sudo chmod 700 install-python-deb.sh

# example usage (assumes terminal is opened in same directory as script):
# ./install-python-deb.sh 3.12.7 (regular command)
# or 
# sudo ./install-python-deb.sh 3.12.7 (regular command using root privileges)
# or
# usr/bin/sudo ./install-python-deb.sh 3.12.7 (fully-qualified command)
# or
# $(which sudo) ./install-python-deb.sh 3.12.7 (secure fully-qualified command)

$(which sudo) $(which echo) "If your password needs to be entered you will be prompted to do so here"

if [ $# -eq 0 ]; then
    $(which echo) "You must provide at least one Python version."
    $(which echo) "specifying the major, minor and patch versions"
    $(which echo) "For example, to install Python3.12.7, type in:"
    $(which echo) "./install-python-deb.sh 3.12.7, not './install-python-deb.sh 3.12'"
    exit 2
fi

# comment-out this line if you want non-English installation
# some distros will add all languages, slowing the installation
# this line of code should prevent that
$(which sudo) $(which apt-mark) hold locales

$(which echo) "Configuring packages..."
$(which sudo) $(which apt-get) update -f > /dev/null 2>&1 && $(which sudo) $(which apt-get) upgrade -fy > /dev/null 2>&1

# setup the compiler environment before further installations
$(which sudo) $(which apt-get) install build-essential libpython3-dev -fqy

$(which echo) "Installing Debian-specific dependencies..."
$(which sudo) $(which apt-get) install \
    libbz2-dev \
    libffi-dev \
    libgdbm-dev \
    liblzma-dev \
    libncurses5-dev \
    libnss3-dev \
    libreadline-dev \
    libssl-dev \
    libsqlite3-dev \
    pkg-config \
    tk-dev \
    zlib1g-dev \
    libgdbm-compat-dev -fy  > /dev/null 2>&1
    
$(which echo) "**********************************************************************"
$(which echo) "_dbm module installation has been blocked, useful for legacy code only"
$(which echo) "**********************************************************************"

# remove unnecessary packages
$(which sudo) $(which apt-get) autoremove -y > /dev/null 2>&1

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
	# Get the major and minor versions of this Python

	PYTHON_MAJOR=$($(which echo) $VER | cut -d. -f1)
	PYTHON_MINOR=$($(which echo) $VER | cut -d. -f2)
	
	# Checks the version and runs the appropriate configure command
	# Note: pip is also installed
	# and more recent than the version in the APT (a.k.a SYNAPTIC) repository
	$(which echo) "Configuring Python $VER..."
	if [ "$PYTHON_MAJOR" -lt 3 ] || { [ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -le 11 ]; }; then
    	# For Python 3.11 or earlier
    	./configure -q --enable-optimizations --with-ensurepip=install --with-system-ffi  > /dev/null 2>&1
	else
    	# For Python 3.12 and later
    	./configure -q --enable-optimizations --with-ensurepip=install  > /dev/null 2>&1
	fi

    # for faster installation, $(nproc) will run 'make' on all possible CPU cores on your system
    $(which echo) "Building Python $VER..."
    $(which make) -s -j $(nproc) > /dev/null 2>&1

    $(which echo) "Installing Python $VER..."
    $(which sudo) $(which make) -s altinstall  > /dev/null 2>&1

    # update pip
    $(which echo) "Upgrading pip ..."
    python${PYTHON_MAJOR}.${PYTHON_MINOR} -m pip install --upgrade pip --disable-pip-version-check > /dev/null 2>&1
    
done

$(which echo) "All done!"
