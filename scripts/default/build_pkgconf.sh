#!/bin/bash
#
# This is a part of ARM Linux Cross-Toolchain for Mac OS X build script
#
# Copyright (C) 2014  Knut Welzel
#

##
## Default build for pkgconf
##
## @note 
## This script ist placed in default directory.
## If you would like to edit this script for a specific target, 
## copy the script into the target directory and edit it there.
##


package_pkgconf=(
	"pkg-config-0.25"
	".tar.gz"
	"http://pkgconfig.freedesktop.org/releases/pkg-config-0.25.tar.gz"
	"a3270bab3f4b69b7dc6dbdacbcae9745"
)


##
## Build pkgconf
##
build_pkgconf(){
	
	name=${package_pkgconf[0]}
	
	
	export CC=$glb_cc
	
	# configure args
	build_args=(
		--prefix=$glb_prefix
		"--build=${glb_build}"
		"--host=${glb_build}"
		"--program-prefix=${glb_target}-"
		"--program-suffix=-real"
		"--with-pc-path=${glb_prefix}/${glb_target}/libc/usr/lib/${glb_target}/pkgconfig:${glb_prefix}/${glb_target}/libc/usr/lib/pkgconfig:${glb_prefix}/${glb_target}/libc/usr/share/pkgconfig" 
	)
	
	# build in dir
	build_dir=${glb_source_path}/${name}/build
	
	# build package 
	build_package $name
	
	cp -a \
		"${BASEPATH}/scripts/pkg-config-wrapper" \
		"${glb_prefix}/bin/${glb_target}-pkg-config"
	
	unset CC
	unset build_args
}