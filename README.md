ARM Linux Cross-Toolchain for Mac OS X
======================================

This is just a set of scripts tot o build ARM Linux Cross-Toolchain on and for Mac OS X, based on Linaro arm-linux-gnueabihf source.

This git repo contains just scripts and patches to build the arm-linux-gnueabihf tool chain. 
The kernel source, GCC, Binutils and all other needed stuff will be downloaded when you run the build script.

Build ARM Linux Cross-Toolchain:
Just run the script in the top level directory of the repo

`$ ./build-arm-toolchain.sh`


Dependencies:
- [Xcode Command Line Tools](https://developer.apple.com/xcode/)
- [Homebrew](https://github.com/Homebrew/homebrew)
*Dependency will be installed automatically*

