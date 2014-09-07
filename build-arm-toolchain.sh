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


# Catch selectet target from command line parameter
if [ "$#" -eq 0 ]; then
	build_target="default"
else
	# Select the build target
	case $1 in

		default) build_target="default";;
			
		raspbian) build_target="raspbian";;

		*) 
			echo "Usage:"
			echo "$0 [OPTION]"
			echo 
			echo "Options:"
			echo "  default   Default arm cross compiler cortex-a9 (eg. BeagleBone Black)."
			echo "            Can be left blank it is the default build."
			echo "  raspbian  Raspberry PI ARMv6 Raspbian build."
			echo
			exit 0
			;;
	esac
fi



# include global variables
source ./scripts/global.cfg
# include global functions
source ./scripts/global.sh
# include global functions
source ./scripts/general.sh
# include package manager functions
source ./scripts/package_manager.sh

# Include build functions
source ./scripts/build.sh

# Include download functions
source ./scripts/download.sh


# Set Enviroment
export PATH=/usr/local/bin:$glb_prefix/bin:$PATH


# Print default start screen
print_start_screen


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

# Build Linux Kernel Source and Headers
build_kernel

# Build gcc 
build_gcc

# Build ncurses
build_ncurses

# Build eXpat
build_expat

# Build gdb 
build_gdb

# Build pkgconf
build_pkgconf


# Cleanup build directory and install tool-chains
finish_build


# Print default end screen
print_end_screen
