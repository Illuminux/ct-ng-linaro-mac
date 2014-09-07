#!/bin/bash
#
# This is a part of ARM Linux Cross-Toolchain for Mac OS X build script
#
# Copyright (C) 2014  Knut Welzel
#


package_isl=(
	"isl-0.11.1"
	".tar.bz2"
	"http://isl.gforge.inria.fr/isl-0.11.1.tar.bz2"
	"bce1586384d8635a76d2f017fb067cd2"
)


##
## Build isl
##
build_isl(){
	
	name=${package_isl[0]}
	
	# configure flags
	export CFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE -I${glb_build_path}/static/include"
	export CXXFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE -I${glb_build_path}/static/include"
	export LDFLAGS="-L${glb_build_path}/static/lib"
	
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
	unset CXXFLAGS
	unset LDFLAGS
	unset build_args
}