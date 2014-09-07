#!/bin/bash
#
# This is a part of ARM Linux Cross-Toolchain for Mac OS X build script
#
# Copyright (C) 2014  Knut Welzel
#

##
## Default build for mpfr
##
## @note 
## This script ist placed in default directory.
## If you would like to edit this script for a specific target, 
## copy the script into the target directory and edit it there.
##


package_mpfr=(
	"mpfr-3.1.0"
	".tar.xz"
	"http://ftp.gnu.org/pub/gnu/mpfr/mpfr-3.1.0.tar.xz"
	"6e495841bb026481567006cec0f821c3"
)


##
## Build mpfr
##
build_mpfr(){
	
	name=${package_mpfr[0]}
	
	# configure flags 
	export CFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE"
	
	# configure args
	build_args=(
		"--build=${glb_build}"
		"--host=${glb_build}"
		"--prefix=${glb_build_path}/static"
		"--with-gmp=${glb_build_path}/static"
		"--disable-shared"
		"--enable-static"
	)
	
	# build in dir
	build_dir=${glb_source_path}/${name}/build
	
	# build package 
	build_package $name
	
	unset CFLAGS
	unset build_args
}