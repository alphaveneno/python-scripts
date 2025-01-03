#!/bin/env bash

# Original author: carberra
# https://github.com/parafoxia/python-scripts
# https://www.youtube.com/watch?v=S4HfueSI-ow
# modified by: alphaveneno
# Date: 2024/12/26
# tested on: Fedora 41 (live USB, linux kernel 6.11.4)
# tested with python 3.10.15, 3.11.2, 3.12.7
# script is for Redhat-derived versions of Linux OS (e.g; Fedora, Rocky, Centos and so on)

# Arch-derived versions of Linux (e.g; Arch, Manjaro, ArcoLinux), Slack,
# OpenSuse-derived versions and other major Linux distributions
# have different commands and extension suffixes from RedHat and Debian

# to give read/write/execution rights for this script _solely_ to the user:
# 1) open a terminal in the _same_ directory as this script
# 2) run: sudo chmod 700 install-python-rh.sh

# example usage (assumes terminal is opened in same directory as script):
# ./install-python-rh.sh 3.12.7 (regular command)
# or
# sudo ./install-python-rh.sh 3.12.7 (regular command for root privileges)
# or
# /usr/bin/sudo ./install-python-rh.sh 3.12.7 (fully-qualified command)
# or
# $(which sudo) ./install-python-rh.sh 3.12.7 (secure fully-qualified command)

$(which sudo) $(which echo) "If your password needs to be entered you will be prompted to do so here"

if [ $# -eq 0 ]; then
    $(which echo) "You must provide at least one Python version."
    $(which echo) "specifying the major, minor and patch versions"
    $(which echo) "For example, to install Python3.12.7, type in:"
    $(which echo) "./install-python-rh.sh 3.12.7, not './install-python-rh.sh 3.12'"
    exit 2
fi

$(which echo) "Configuring packages..."
$(which sudo) $(which dnf) upgrade -y  > /dev/null 2>&1

# setup the compiler environment before further installations
# for fedora 41, using dnf5:
$(which sudo) $(which dnf) install dnf-plugins-core @development-tools -qy > /dev/null 2>&1

# for versions of fedora with dnf4, this may be a necessary substitute for the line of code above:
# $(which sudo) $(which dnf) group install "Development Tools"

# if you want a non-English installation use this command:
# $(which sudo) $(which dnf) install glibc-langpack-<insert the two (or three) letter country abbreviation here>
# e.g; $(which sudo) $(which dnf) install glibc-langpack-de, for German
# to prevent the slow installation of language packs:
$(which sudo) $(which dnf) versionlock add glibc-all-langpacks

$(which echo) "Installing Redhat-specific dependencies..."
$(which sudo) $(which dnf) install \
	libffi-devel \
	python3-devel \
	bzip2-devel \
	gdbm-devel \
	xz-devel \
	ncurses-devel \
	nss-devel \
	readline-devel \
	openssl-devel \
	sqlite-devel \
	python3-pkgconfig \
	tk-devel \
	libuuid-devel \
	python3-zlib-ng -y  > /dev/null 2>&1

$(which sudo) $(which dnf) autoremove -y > /dev/null 2>&1

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
    # Note: pip is also installed, this will be the most recent stable version,
    ./configure -q --enable-optimizations --with-ensurepip=install  > /dev/null 2>&1

    # for faster installation, $(nproc) will run 'make' on all possible CPU cores on your system
    $(which echo) "Building Python $VER..."
    $(which make) -s -j $(nproc)  > /dev/null 2>&1

    $(which echo) "Installing Python $VER..."
    $(which sudo) $(which make) -s altinstall > /dev/null 2>&1
    
    $(which echo) "***************************"
    $(which echo) "nis module is deprecated"
    $(which echo) "***************************"
    
done

$(which echo) "All done!"
