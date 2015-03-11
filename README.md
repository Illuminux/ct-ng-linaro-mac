ARM Linux Cross-Toolchain for Mac OS X
======================================

This script allows to build the Linaro ARM Linux Cross-Toolchain on Mac OS X. 

Base is the release 1.13.1 GCC 4.9 (2014.05)

Build ARM Linux Cross-Toolchain:
Just run the script in the top level directory of the repo

`$ ./build.sh [Sample]`

Supported Samples:

- linaro-arm-linux-gnueabi 
- linaro-arm-linux-gnueabihf (eg. BeagleBone Black)
- linaro-arm-linux-gnueabihf-raspbian (eg. Raspberry Pi A/B)

<b>Dependencies:</b>

- [Xcode Command Line Tools](https://developer.apple.com/xcode/)
- [Homebrew](https://github.com/Homebrew/homebrew) <br>*Dependency will be installed automatically*

<b>Toolchain Binaries</b>

The pre-built version of this tool chains can be downloaded [here](http://www.welzels.de/blog/downloads/?category=13).


<b>Features:</b>

- GNU Binutils
- GNU Compiler Collection C/C++ and Fortran
- GNU Project Debugger GDB
- pkg-config
