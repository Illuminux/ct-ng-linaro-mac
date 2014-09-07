#!/bin/bash
#
# This is a part of ARM Linux Cross-Toolchain for Mac OS X build script
#
# Copyright (C) 2014  Knut Welzel
#

##
## Default build for sysroot
##
## @note 
## This script ist placed in default directory.
## If you would like to edit this script for a specific target, 
## copy the script into the target directory and edit it there.
##


package_sysroot=(
	"linaro-prebuilt-sysroot-2013.10"
	".tar.bz2"
	"https://launchpad.net/linaro-toolchain-binaries/support/01/+download/linaro-prebuilt-sysroot-2013.10.tar.bz2"
	"aed7eb9e886f84fc84663d6e13e2b31d"
)


##
## Build sysroot
##
build_sysroot(){
	
	name=${package_sysroot[0]}
	
	# install sysroot
	print_log -n "Install sysroot... "
	
	# create new build dir
	if ! [ -d "${glb_prefix}/${glb_target}/libc" ]; then
		mkdir -p "${glb_prefix}/${glb_target}/libc" || error_mkdir
	fi

	cp -a \
		"${glb_source_path}/${name}/etc" \
		"${glb_source_path}/${name}/lib" \
		"${glb_source_path}/${name}/sbin" \
		"${glb_source_path}/${name}/usr" \
		"${glb_source_path}/${name}/var" \
		"${glb_sysroot_path}/libc" || error_copy
	
	print_log "done"
}