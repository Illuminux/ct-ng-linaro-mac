#!/bin/bash
#
# This is a part of ARM Linux Cross-Toolchain for Mac OS X build script
#
# Copyright (C) 2014  Knut Welzel
#

build_args=()


# Load build script for gmp
source "${BASEPATH}/scripts/${build_target}/build_gmp.sh"

# Load build script for mpfr
source "${BASEPATH}/scripts/${build_target}/build_mpfr.sh"

# Load build script for isl
source "${BASEPATH}/scripts/${build_target}/build_isl.sh"

# Load build script for cloog
source "${BASEPATH}/scripts/${build_target}/build_cloog.sh"

# Load build script for mpc
source "${BASEPATH}/scripts/${build_target}/build_mpc.sh"

# Load build script for zlib
source "${BASEPATH}/scripts/${build_target}/build_zlib.sh"

# Load build script for binutils
source "${BASEPATH}/scripts/${build_target}/build_binutils.sh"

# Load build script for kernel
source "${BASEPATH}/scripts/${build_target}/build_kernel.sh"

# Load build script for sysroot
source "${BASEPATH}/scripts/${build_target}/build_sysroot.sh"

# Load build script for gcc
source "${BASEPATH}/scripts/${build_target}/build_gcc.sh"

# Load build script for ncurses
source "${BASEPATH}/scripts/${build_target}/build_ncurses.sh"

# Load build script for expat
source "${BASEPATH}/scripts/${build_target}/build_expat.sh"

# Load build script for gdb
source "${BASEPATH}/scripts/${build_target}/build_gdb.sh"

# Load build script for pkgconf
source "${BASEPATH}/scripts/${build_target}/build_pkgconf.sh"



##
## Build package 
##
build_package(){
	
	name=$1

	print_log "Building ${name}:"

	# create new build dir
	if ! [ -d "${build_dir}" ]; then
		mkdir -p $build_dir || error_mkdir
	fi
	cd $build_dir
	
	# configure gmp
	print_log -n "Configure ${name}... "
	
	${glb_source_path}/${name}/configure ${build_args[@]} > "${glb_log_path}/${name}.log" 2>&1 || error_configure
	
	print_log "done"
	
	# build gmp
	print_log -n "Build ${name}... "
	make >> "${glb_log_path}/${name}.log" 2>&1 || error_make
	print_log "done"
	
	print_log -n "Install ${name}... "
	make install >> "${glb_log_path}/${name}.log" 2>&1 || error_install
	print_log "done"
	
	cd $BASEPATH
}