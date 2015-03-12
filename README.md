crosstool-NG Linaro for Mac OS X
======================================

This script builds the Linaro ARM toolchain on Mac OS X and for Mac OS X. Base is the modified version of the crosstool-NG by Linaro. 

Release 1.13.1 GCC 4.9 (2014.08)

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
