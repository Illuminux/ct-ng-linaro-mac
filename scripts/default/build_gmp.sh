#!/bin/bash
#
# This is a part of ARM Linux Cross-Toolchain for Mac OS X build script
#
# Copyright (C) 2014  Knut Welzel
#


package_gmp=(
	"gmp-5.0.2"
	".tar.bz2"
	"http://ftp.gnu.org/pub/gnu/gmp/gmp-5.0.2.tar.bz2"
	"0bbaedc82fb30315b06b1588b9077cd3"
)


##
## Build gmp
##
build_gmp(){
	
	name=${package_gmp[0]}
	
	# configure flags 
	export CFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE -fexceptions"
	
	# configure args
	build_args=(
		"--build=${glb_build}"
		"--host=${glb_build}"
		"--prefix=${glb_build_path}/static"
		"--enable-fft"
		"--enable-mpbsd"
		"--enable-cxx"
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