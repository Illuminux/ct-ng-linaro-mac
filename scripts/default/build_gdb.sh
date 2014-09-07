#!/bin/bash
#
# This is a part of ARM Linux Cross-Toolchain for Mac OS X build script
#
# Copyright (C) 2014  Knut Welzel
#

##
## Default build for gdb
##
## @note 
## This script ist placed in default directory.
## If you would like to edit this script for a specific target, 
## copy the script into the target directory and edit it there.
##


package_gdb=(
	"gdb-linaro-7.6.1-2013.10"
	".tar.bz2"
	"http://releases.linaro.org/13.10/components/toolchain/gdb-linaro/gdb-linaro-7.6.1-2013.10.tar.bz2"
	"d735bed03e94d05fbefbb3b2eb897f99"
)


##
## Build gdb
##
build_gdb(){
	
	name=${package_gdb[0]}
	
	# configure flags
	export CFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE -I${glb_build_path}/static/include -I${glb_build_path}/static/zlib/include"
	export LDFLAGS="-L${glb_build_path}/static/lib -L${glb_build_path}/static/lib -L${glb_build_path}/static/zlib/lib"
	
	# configure args
	build_args=(
		"--build=${glb_build}"
		"--host=${glb_build}"
		"--target=${glb_target}"
		"--prefix=${glb_prefix}"
		"--with-build-sysroot=${glb_sysroot_path}/libc"
		"--with-sysroot=${glb_sysroot_path}/libc"
		"--with-expat=yes"
		"--disable-werror"
		"--enable-threads"
		"--with-python=no"
		"--with-libexpat-prefix=${glb_build_path}/static"
		"--disable-sim"
		"--with-pkgversion=$glb_build_version"
		"--with-bugurl=$glb_bug_url"
	)
	
	# build in dir
	build_dir=${glb_source_path}/${name}/build
	
	# build package 
	build_package $name
	
	cd "${glb_source_path}/${name}/build" || error_mkdir
	
	print_log -n "Install ${name} manuals... "
	make >/dev/null 2>&1 || error_make
	make install-html-gdb >/dev/null 2>&1 || error_install
	print_log "done"
	
	unset CFLAGS
	unset LDFLAGS
	unset build_args
}