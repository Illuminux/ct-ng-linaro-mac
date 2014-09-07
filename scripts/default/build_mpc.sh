#!/bin/bash
#
# This is a part of ARM Linux Cross-Toolchain for Mac OS X build script
#
# Copyright (C) 2014  Knut Welzel
#


package_mpc=(
	"mpc-0.9"
	".tar.gz"
	"http://www.multiprecision.org/mpc/download/mpc-0.9.tar.gz"
	"0d6acab8d214bd7d1fbbc593e83dd00d"
)


##
## Build mpc
##
build_mpc(){
	
	name=${package_mpc[0]}
	
	# configure flags 
	export CFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE -I${glb_build_path}/static/include"
	export CXXFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE -I${glb_build_path}/static/include"
	export LDFLAGS="-L${glb_build_path}/static/lib"

	
	# configure args
	build_args=(
		"--build=${glb_build}"
		"--host=${glb_build}"
		"--prefix=${glb_build_path}/static"
		"--with-gmp-prefix=${glb_build_path}/static"
		"--with-mpfr-prefix=${glb_build_path}/static"
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