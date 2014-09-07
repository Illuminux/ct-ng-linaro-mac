#!/bin/bash
#
# This is a part of ARM Linux Cross-Toolchain for Mac OS X build script
#
# Copyright (C) 2014  Knut Welzel
#


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
		"--with-pc-path=${glb_prefix}/arm-linux-gnueabihf/libc/usr/lib/arm-linux-gnueabihf/pkgconfig:${glb_prefix}/arm-linux-gnueabihf/libc/usr/lib//pkgconfig:${glb_prefix}/arm-linux-gnueabihf/libc/usr/share/pkgconfig" 
	)
	
	# build in dir
	build_dir=${glb_source_path}/${name}/build
	
	# build package 
	build_package $name
	
	cp -a \
		"${BASEPATH}/scripts/pkg-config-wrapper" \
		"${glb_prefix}/bin/arm-linux-gnueabihf-pkg-config"
	
	unset CC
	unset build_args
}