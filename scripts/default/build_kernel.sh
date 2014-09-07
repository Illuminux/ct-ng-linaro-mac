#!/bin/bash
#
# This is a part of ARM Linux Cross-Toolchain for Mac OS X build script
#
# Copyright (C) 2014  Knut Welzel
#


package_kernel=(
	"linux-3.1.1"
	".tar.xz"
	"http://ftp.kernel.org/pub/linux/kernel/v3.x/linux-3.1.1.tar.xz"
	"6540f9b81b630c91c81f277bcad6fd54"
)

##
## Default build for kernel
##
## @note 
## This script ist placed in default directory.
## If you would like to edit this script for a specific target, 
## copy the script into the target directory and edit it there.
##


##
## Build Linux Kernel Source and Headers
##
build_kernel(){
	
	name=${package_kernel[0]}
	
	print_log "Building Linux Kernel Headers:"
	
	# Go into kernel source directory
	cd "${glb_disk_image_path}/${name}"
	
	# create new build dir
	if ! [ -d "${glb_disk_image_path}/${name}/build" ]; then
		mkdir -p "${glb_disk_image_path}/${name}/build" || error_mkdir
	fi
	
	# Install kernel sources
	print_log -n "Install Kernel... "
		
	make \
		-C "${glb_disk_image_path}/${name}" \
		O="${glb_disk_image_path}/${name}/build" \
		ARCH=arm \
		INSTALL_HDR_PATH="${glb_prefix}/${glb_target}/libc/usr" \
		V=1 \
		headers_install > "${glb_log_path}/${name}.log" 2>&1 || error_make

	print_log "done"

	# Checking kernel sources
	print_log -n "Checking Kernel headers... "
	
	make \
		-C "${glb_disk_image_path}/${name}" \
		O="${glb_disk_image_path}/${name}/build" \
		ARCH=arm \
		INSTALL_HDR_PATH="${glb_prefix}/${glb_target}/libc/usr" \
		V=1 \
		headers_check >> "${glb_log_path}/${name}.log" 2>&1 || error_make
	
	print_log "done"
	
	build_sysroot
}