ARM Linux Cross-Toolchain for Mac OS X
======================================

This is just a set of scripts to build ARM Linux Cross-Toolchain on and for Mac OS X, based on Linaro arm-linux-gnueabihf source.

This git repo contains just scripts and patches to build the arm-linux-gnueabihf toolchain. 
The kernel source, GCC, Binutils and all other needed stuff will be downloaded when you run the build script.

Build ARM Linux Cross-Toolchain:
Just run the script in the top level directory of the repo

`$ ./build-arm-toolchain.sh`

For Raspbian run:

`$ ./build-arm-toolchain.sh raspbian`


After the script has been executed successfully, ARM Linux Cross-Toolchain are placed in:

- `/usr/local/gcc-arm-linux-gnueabihf` (default).
- `/usr/local/gcc-arm-linux-gnueabihf-raspbian` (raspbian).


<b>Dependencies:</b>
- [Xcode Command Line Tools](https://developer.apple.com/xcode/)
- [Homebrew](https://github.com/Homebrew/homebrew)

*Dependency will be installed automatically*


<b>Toolchain Binaries</b>

The pre-built version of this tool chains can be downloaded [here](http://www.welzels.de/blog/downloads/?category=13).


<b>Features:</b>
- GNU Binutils
- GNU Compiler Collection C/C++ and Fortran
- GNU Project Debugger GDB
- pkg-config
