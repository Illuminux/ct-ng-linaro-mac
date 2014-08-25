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

# maximum number of open file descriptors to 1024
ulimit -n 1024

# Set Enviroment
export TARGET=${glb_target}
export PREFIX=${glb_prefix}
export PATH=/usr/local/bin:$PREFIX/bin:$PATH

# Clear screen
clear 

if [ "$(uname -s)" != "Darwin" ]; then
	echo "This script is designed for Mac OS X only!"
	exit 0
fi

echo "This script will build ARM Linux Cross-Toolchain on and for Mac" \
	 "OS X, based on Linaro Toolchain Sources."
echo "During the execution several files and programs will be downloaded" \
	 "from the Internet and installed on your Computer."
echo "For the execution 10 GB of free hard drives memory will be needed!"

while true; do
	read -p "Continue the script? [Y/n] " Yn
	Yn=${Yn:-Y}
	case $Yn in
		[Yy]* ) break;;
		[Nn]* ) clear; exit 0;;
			* ) echo "Please answer C (Continue) or a (abort).";;
	esac
done

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

# Build Linux Kernel Source and Headers
build_kernel

# Build Binutils
build_binutils

# Build GCC Part 1
build_gcc1

# Build Embedded GLIBC
build_eglibc

# Build gcc part 2
build_gcc2

# remove temporrery links
package_manager_dellinks

finish_build

echo ""
echo "ARM Linux Cross-Toolchain for Mac OS X was build successfully."
echo "You can find them in '/usr/local/arm-linux-hf'."
echo ""
