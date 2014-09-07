#!/bin/bash
#
# This is a part of ARM Linux Cross-Toolchain for Mac OS X build script
#
# Copyright (C) 2014  Knut Welzel
#


package_expat=(
	"expat-2.1.0"
	".tar.gz"
	"http://sourceforge.net/projects/expat/files/expat/2.1.0/expat-2.1.0.tar.gz/download?use_mirror=dfn"
	"dd7dab7a5fea97d2a6a43f511449b7cd"
)


##
## Build eXpat
##
build_expat(){
	
	name=${package_expat[0]}
	
	# configure flags
	
	# configure args
	build_args=(
		"--build=${glb_build}"
		"--host=${glb_build}"
		"--target=${glb_target}"
		"--prefix=${glb_build_path}/static"
		"--disable-shared"
		"--enable-static"
	)
	
	# build in dir
	build_dir=${glb_source_path}/${name}/build
	
	# build package 
	build_package $name
	
	unset build_args
}