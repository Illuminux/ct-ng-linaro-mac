#!/bin/bash
#
# This is a part of ARM Linux Cross-Toolchain for Mac OS X build script
#
# Copyright (C) 2014  Knut Welzel
#


package_ncurses=(
	"ncurses-5.9"
	".tar.gz"
	"http://ftp.gnu.org/gnu/ncurses/ncurses-5.9.tar.gz"
	"8cb9c412e5f2d96bc6f459aa8c6282a1"
)


##
## Build ncurses
##
build_ncurses(){
	
	name=${package_ncurses[0]}
	
	# configure args
	build_args=(
		"--build=${glb_build}"
		"--host=${glb_build}"
		"--target=${glb_target}"
		"--prefix=${glb_build_path}/static"
		"--disable-shared"
		"--enable-static"
		"--without-ada"
	)
	
	# build in dir
	build_dir=${glb_source_path}/${name}/build
	
	# build package 
	build_package $name

#	unset CC
	unset build_args
}