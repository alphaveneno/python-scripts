#!/bin/env bash

# Author: alphaveneno
# Date: 2025/01/23
# tested on: MX Linux 23.1 (linux kernel 6.5.0),
# Debian 12.8 (linux kernel 6.12.4),
# Fedora 41 (linux kernel 6.11.0),
# ArchLinux (linux kernel 6.12.10-arch1-1)11.0)
# with python 3.10.15, 3.11.9, 3.12.7 & 3.13.0
# should work on all Linux distributions

# to give read/write/execution rights for this script _solely_ to the user:
# 1) open a terminal in the _same_ directory as this script
# 2) run: sudo chmod 700 test-install-python.sh

# example usage (assumes terminal is opened in same directory as script):
# ./test-install-python.sh 3.12.7 (regular command)
# or
# sudo ./test-install-python.sh 3.12.7 (regular command for root privileges)
# or
# /usr/bin/sudo ./test-install-python.sh 3.12.7 (fully-qualified command)
# or
# $(which sudo) ./test-install-python.sh 3.12.7 (secure fully-qualified command)


# Function to assert that the expected version matches the installed version
assert_python_version() {
    expected_version=$1
    PYTHON_MAJOR=$($(which echo) $expected_version | cut -d. -f1)
    PYTHON_MINOR=$($(which echo) $expected_version | cut -d. -f2)
    
    actual_version=$(python${PYTHON_MAJOR}.${PYTHON_MINOR} --version 2>&1)
    if [[ $actual_version == "Python $expected_version" ]]; then
        $(which echo) "Assertion passed: Python version is $expected_version"
    else
        $(which echo) "Assertion failed: Expected Python version $expected_version, but got $actual_version"
        exit 1
    fi
}

# Function to test opening the python shell and performing some common Python procedures
test_python_shell() {
    version=$1
    PYTHON_MAJOR=$($(which echo) $version | cut -d. -f1)
    PYTHON_MINOR=$($(which echo) $version | cut -d. -f2)
    python_command="python${PYTHON_MAJOR}.${PYTHON_MINOR}"

    # Test if the specific python command opens the shell
    if command -v $python_command &>/dev/null; then
        $(which echo) "Assertion passed: $python_command opens the Python shell"
    else
        $(which echo) "Assertion failed: $python_command does not open the Python shell"
        exit 1
    fi
    
    pip_command="python${PYTHON_MAJOR}.${PYTHON_MINOR} -m pip -V"

    # Test if pip has been installed with this version of python
    if command -v $pip_command &>/dev/null; then
        $(which echo) "Assertion passed: $pip_command gives pip version"
    else
        $(which echo) "Assertion failed: $pip_command does not give pip version"
        exit 1
    fi

    # Runs python commands in python shell
    $python_command << EOF
import math
assert math.sqrt(16) == 4, "Math module test failed"

import os
assert os.getcwd() != "", "OS module test failed"

my_list = [1, 2, 3, 4, 5]
assert my_list == [1, 2, 3, 4, 5], "List creation test failed"
EOF

    # Check the exit status of the Python commands
    if [ $? -eq 0 ]; then
        $(which echo) "All tests passed in the Python shell"
    else
        $(which echo) "Some tests failed in the Python shell"
        exit 1
    fi
}

# Check if the user provided a version argument
if [ $# -ne 1 ]; then
    $(which echo) "Usage: $0 <expected-python-version>"
    exit 1
fi

# Use the provided argument as the expected version
expected_version=$1

# Call the functions with the user-provided version
assert_python_version "$expected_version"
test_python_shell "$expected_version"


