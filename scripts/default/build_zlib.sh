#!/bin/bash
#
# This is a part of ARM Linux Cross-Toolchain for Mac OS X build script
#
# Copyright (C) 2014  Knut Welzel
#

##
## Default build for zlib
##
## @note 
## This script ist placed in default directory.
## If you would like to edit this script for a specific target, 
## copy the script into the target directory and edit it there.
##


package_zlib=(
	"zlib-1.2.5"
	".tar.gz"
	"http://sourceforge.net/projects/libpng/files/zlib-1.2.5.tar.gz"
	"c735eab2d659a96e5a594c9e8541ad63"
)


##
## Build zlib
##
build_zlib(){
	
	name=${package_zlib[0]}
	
	# build in dir
	cd "${glb_source_path}/${name}"
	
	
	print_log "Building ${name}:"
	
	# configure gmp
	print_log -n "Configure ${name}... "
	
	CFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE" \
	CXXFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE" \
	./configure \
		--prefix="${glb_build_path}/static/zlib" \
		--static >> "${glb_log_path}/${name}.log" 2>&1 || error_configure
	
	print_log "done"
	
	# build gmp
	print_log -n "Build ${name}... "
	make >> "${glb_log_path}/${name}.log" 2>&1 || error_make
	print_log "done"
	
	print_log -n "Install ${name}... "
	make install >> "${glb_log_path}/${name}.log" 2>&1 || error_install
	print_log "done"
}