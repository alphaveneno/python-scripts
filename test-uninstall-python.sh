#!/bin/env bash

# Author: alphaveneno
# Date: 2025/01/23
# tested on: MX Linux 23.1 (linux kernel 6.5.0),
# Debian 12.8 (linux kernel 6.12.4),
# Fedora 41 (linux kernel 6.11.0),
# ArchLinux (linux kernel 6.12.10-arch1-1)
# with python 3.10.15, 3.11.9, 3.12.7 & 3.13.0
# should work on all Linux distributions

# to give read/write/execution rights for this script _solely_ to the user:
# 1) open a terminal in the _same_ directory as this script
# 2) run: sudo chmod 700 test-uninstall-python.sh

# Example usage
# ./test-uninstall-python.sh 3.12.7 (regular command)
# or
# sudo ./test-uninstall-python.sh 3.12.7 (regular command for root privileges)
# or
# /usr/bin/sudo ./test-uninstall-python.sh 3.12.7 (fully-qualified command)
# or
# $(which sudo) ./test-uninstall-python.sh 3.12.7 (secure fully-qualified command)

# Function to check if a file or directory exists
check_removed() {
    path=$1
    if [ -e $path ]; then
        $(which echo) "Assertion failed: $path still exists"
        exit 1
    else
        $(which echo) "Assertion passed: $path is removed"
    fi
}

# Check if the user provided a version argument
if [ $# -ne 1 ]; then
    $(which echo) "Usage: $0 <expected-python-version>"
    exit 1
fi

# Use the provided argument as the expected version
expected_version=$1
PYTHON_MAJOR=$($(which echo) $expected_version | cut -d. -f1)
PYTHON_MINOR=$($(which echo) $expected_version | cut -d. -f2)
VER="${PYTHON_MAJOR}.${PYTHON_MINOR}"

# Define the paths to check for removal
BIN_PATH="/usr/local/bin"
LIB_PATH="/usr/local/lib"
USER_LIB_PATH="$HOME/.local/lib"
USER_BIN_PATH="$HOME/.local/bin"
USER_WHEEL_PATH="$HOME/.local/lib/python${VER}/site-packages"

paths_to_check=(
    "${BIN_PATH}/2to3-${VER}"
    "${BIN_PATH}/idle${VER}"
    "${BIN_PATH}/pip${VER}"
    "${BIN_PATH}/pydoc${VER}"
    "${BIN_PATH}/python${VER}"
    "${BIN_PATH}/python${VER}-config"
    "${LIB_PATH}/libpython${VER}.so"
    "${LIB_PATH}/libpython${VER}.so.1.0"
    "${LIB_PATH}/python${VER}"
    "${LIB_PATH}/pkgconfig/python${VER}-embed.pc"
    "${LIB_PATH}/pkgconfig/python${VER}.pc"
    "${LIB_PATH}/python${VER}-embed.pc"
    "${LIB_PATH}/libpython${VER}.a"
    "${LIB_PATH}/python${VER}.pc"
    "${USER_LIB_PATH}/python${VER}"
    "${USER_BIN_PATH}/pip${VER}"
    "${USER_WHEEL_PATH}/${VER}"
)

# Check if the python command still exists
if command -v python${PYTHON_MAJOR}.${PYTHON_MINOR} &>/dev/null; then
    $(which echo) "Assertion failed: python${VER} command still exists"
    exit 1
else
    $(which echo) "Assertion passed: python${VER} command is removed"
fi

# Check if pip removed
if command -v "python${PYTHON_MAJOR}.${PYTHON_MINOR} -m pip -V" &>/dev/null; then
    $(which echo) "Assertion failed: pip for version ${PYTHON_MAJOR}.${PYTHON_MINOR} still exists"
    exit 1
else
    $(which echo) "Assertion passed: pip for version ${PYTHON_MAJOR}.${PYTHON_MINOR} is removed"
fi

# Check each path for removal
for path in "${paths_to_check[@]}"; do
    check_removed "$path" > /dev/null 2>&1
done

$(which echo) "All checks passed: Python ${expected_version} and its files are removed."



