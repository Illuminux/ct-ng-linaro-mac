#!/bin/bash
#
# This is a part of ARM Linux Cross-Toolchain for Mac OS X build script
#
# Copyright (C) 2014  Knut Welzel
#

##
## Rapbian build for binutils
##


package_binutils=(
	"binutils-linaro-2.24-2013.12"
	".tar.xz"
	"https://releases.linaro.org/13.12/components/toolchain/binutils-linaro/binutils-linaro-2.24-2013.12.tar.xz"
	"4f0fe947895a260b8386de63b09feb18"
)


##
## Build Binutils
##
build_binutils(){
	
	name=${package_binutils[0]}
	
	# configure flags
	export CC=$glb_cc
	export CXX=$glb_cxx
	export CFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE -I${glb_build_path}/static/include -I${glb_build_path}/static/zlib/include"
	export CXXFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE -I${glb_build_path}/static/include -I${glb_build_path}/static/zlib/include"
	export LDFLAGS="-lstdc++ -L${glb_build_path}/static/lib -L${glb_build_path}/static/zlib/lib"
	
	# configure args
	build_args=(
		"--build=${glb_build}"
		"--host=${glb_build}"
		"--target=${glb_target}"
		"--prefix=${glb_prefix}"
		"--disable-multilib"
		"--disable-werror"
		"--enable-ld=default"
		"--enable-gold=yes"
		"--enable-threads"
		"--enable-plugins"
		"--with-float=hard"
		"--with-sysroot=${glb_sysroot_path}/libc"
		"--with-pkgversion=${glb_build_version}"
		"--with-bugurl=${glb_bug_url}"
	)
	
	# build in dir
	build_dir=${glb_source_path}/${name}/build
	
	# build package 
	build_package $name
	
	cd "${glb_source_path}/${name}/build"
	
	print_log -n "Install ${name} manuals... "
	make html >/dev/null 2>&1 || error_make
	make install-html-gas install-html-binutils install-html-ld install-html-gprof >/dev/null 2>&1 || error_install
	print_log "done"
	
	cd $BASEPATH
	
	unset CC
	unset CXX
	unset CFLAGS
	unset CXXFLAGS
	unset LDFLAGS
	unset build_args
}