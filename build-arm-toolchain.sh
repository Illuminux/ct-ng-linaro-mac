#!/bin/bash
#
# This Script builds ARM Linux Cross-Toolchain on and for Mac OS X,
# based on Linaro Toolchain Sources.
#
# Copyright (C) 2014  Knut Welzel
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# 


# Base path, wher this script is located 
BASEPATH=$(pwd)


# maximum number of open file descriptors to 1024
ulimit -n 1024


# Exit script if not Max OS X
if [ "$(uname -s)" != "Darwin" ]; then
	echo "This script is designed for Mac OS X only!"
	exit 0
fi


# include global variables
source ./inc/global.cfg
# include global functions
source ./inc/global.sh
# include package manager functions
source ./inc/package_manager.sh
# Include download functions
source ./inc/download.sh
# Include build functions
source ./inc/build.sh


# Set Enviroment
export TARGET=${glb_target}
export PREFIX=${glb_prefix}
export PATH=/usr/local/bin:$PREFIX/bin:$PATH

BUILD=`gcc -v 2>&1 | grep "Target" | sed 's/Target:[ /t]*//'`
BUILDVERSION="Illuminux Mac OSX Intelx86 based on Linaro ${glb_linaro_version}"
BUGURL="https://github.com/Illuminux/arm-cross-toolchain-Mac_OS_X/issues"
JOBS="-j`sysctl hw.ncpu | awk '{print $2}'`"



# Clear screen
clear 

while true; do

	echo "This script will build ARM Linux Cross-Toolchain on and for Mac OS X,"
	echo "based on Linaro Toolchain Sources."
	echo "During the execution, several files and programs will be downloaded" 
	echo "from the Internet and installed on your Computer."
	echo "For the execution ${glb_disk_image_size}Bytes of free hard drives"
	echo "memory will be needed!"
	echo
	echo "This program comes with ABSOLUTELY NO WARRANTY; for details type [l]."
	echo "This is free software, and you are welcome to redistribute it"
	echo "under certain conditions; type [l] for details."
	echo
	
	read -p "Continue the script [Y/n]? Or for read the License [l]: " Yn
	Yn=${Yn:-Y}
	case $Yn in
		[Yy]* ) break;;
		[Ll]* ) less gpl-3.0.txt; clear;;
		[Nn]* ) clear; exit 0;;
			* ) clear; echo  "Please answer Y (Yes) or n (No)."; echo;;
	esac
done

clear
echo "Start build process. This may take several hours!"
echo

# Create directories
create_dir_structure

# Check if command line tools are installed. If not, installe them.
check_for_Command_Line_Tools

# serach for installed packagmanager
# - abort on fink/port
# - install brew if not found
package_manager

# create a case sensitiv disk image 
create_image

# get Linaro crosscompiler sources 
download_sources

# Build sysroot
build_sysroot

# Build Binutils
build_gmp

# Build mpfr
build_mpfr

# Build isl
build_isl

# Build cloog
build_cloog

# Build mpc
build_mpc

# Build zlib
build_zlib

# Build Binutils
build_binutils

# Build GCC Part 1 static core C compiler
build_gcc1

# Build Linux Kernel Source and Headers
build_kernel

# Rebuild sysroot
build_sysroot

# Build gcc part 2 shared core C compiler
build_gcc2

# Build Embedded GLIBC
#build_eglibc

# Build gcc part 3
build_gcc3

# Build ncurses
build_ncurses

# Build eXpat
build_expat

# Build gdb 
build_gdb

# Build pkgconf
build_pkgconf

# remove temporrery links
package_manager_dellinks

# Build Embedded GLIBC
#build_eglibc

finish_build

echo ""
echo "ARM Linux Cross-Toolchain for Mac OS X was build successfully."
echo "You can find them in '${glb_build_path}'."
echo ""
