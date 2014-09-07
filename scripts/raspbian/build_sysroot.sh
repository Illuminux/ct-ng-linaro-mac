#!/bin/bash
#
# This is a part of ARM Linux Cross-Toolchain for Mac OS X build script
#
# Copyright (C) 2014  Knut Welzel
#

##
## Rapbian build for sysroot
##


package_sysroot=(
	"raspbian-sysroot-armhf-0+bzr2449"
	".tar.bz2"
	"http://launchpad.net/linaro-toolchain-binaries/support/01/+download/raspbian-sysroot-armhf-0+bzr2449.tar.bz2"
	"bb5674a44f5a11fb07d3d7c3f08e8d55"
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
		"${glb_source_path}/${name}/lib" \
		"${glb_source_path}/${name}/sbin" \
		"${glb_source_path}/${name}/usr" \
		"${glb_sysroot_path}/libc" || error_copy
	
	print_log "done"
}