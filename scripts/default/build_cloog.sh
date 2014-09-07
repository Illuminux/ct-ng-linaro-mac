#!/bin/bash
#
# This is a part of ARM Linux Cross-Toolchain for Mac OS X build script
#
# Copyright (C) 2014  Knut Welzel
#

##
## Default build for cloog
##
## @note 
## This script ist placed in default directory.
## If you would like to edit this script for a specific target, 
## copy the script into the target directory and edit it there.
##


package_cloog=(
	"cloog-0.18.0"
	".tar.gz"
	"http://www.bastoul.net/cloog/pages/download/count.php3?url=./cloog-0.18.0.tar.gz"
	"be78a47bd82523250eb3e91646db5b3d"
)


##
## Build cloog
##
build_cloog(){
	
	name=${package_cloog[0]}
	
	# configure flags 
	export CFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE"
	
	# configure args
	build_args=(
		"--build=${glb_build}"
		"--host=${glb_build}"
		"--prefix=${glb_build_path}/static"
		"--with-gmp-prefix=${glb_build_path}/static"
		"--with-isl-prefix=${glb_build_path}/static"
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