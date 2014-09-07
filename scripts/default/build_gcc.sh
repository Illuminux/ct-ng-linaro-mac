#!/bin/bash
#
# This is a part of ARM Linux Cross-Toolchain for Mac OS X build script
#
# Copyright (C) 2014  Knut Welzel
#


package_gcc=(
	"gcc-linaro-4.8-2013.12"
	".tar.xz"
	"https://releases.linaro.org/13.12/components/toolchain/gcc-linaro/4.8/gcc-linaro-4.8-2013.12.tar.xz"
	"bd7a22ff4d1b6bb4824ef908e07bde66"
)


##
## Build gcc part 1 - static core C compiler
##
build_gcc(){
	
	name=${package_gcc[0]}
	
	# configure flags
	export CC_FOR_BUILD=$glb_cc
	export CFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE"
	export LDFLAGS="-lstdc++ -lm"
	export CXXFLAGS_FOR_TARGET="-mlittle-endian -march=armv7-a -mtune=cortex-a9 -mfpu=vfpv3-d16 -mhard-float -g -O2"
	export LDFLAGS_FOR_TARGET="-Wl,-EL"
	
	# configure args
	build_args=(
		"--build=${glb_build}"
		"--host=${glb_build}"
		"--target=${glb_target}"
		"--prefix=${glb_prefix}"
		"--with-sysroot=${glb_sysroot_path}/libc"
		"--enable-languages=c,c++,fortran"
		"--enable-multilib"
		"--with-arch=armv7-a"
		"--with-tune=cortex-a9"
		"--with-fpu=vfpv3-d16"
		"--with-float=hard"
		"--enable-__cxa_atexit"
		"--enable-libmudflap"
		"--enable-libgomp"
		"--enable-libssp"
		"--with-gmp=${glb_build_path}/static"
		"--with-mpfr=${glb_build_path}/static"
		"--with-mpc=${glb_build_path}/static"
		"--with-isl=${glb_build_path}/static"
		"--with-cloog=${glb_build_path}/static"
		"--with-libelf=${glb_build_path}/static"
		"--enable-threads=posix"
		"--disable-libstdcxx-pch"
		"--enable-linker-build-id"
		"--enable-gold"
		"--with-local-prefix=${glb_prefix}/arm-linux-gnueabihf/libc"
		"--enable-c99"
		"--enable-long-long"
		"--with-mode=thumb"
		"--with-float=hard"
		"--with-pkgversion=${glb_build_version}"
		"--with-bugurl=${glb_bug_url}"
	)
	
	# build in dir
	build_dir=${glb_source_path}/${name}/build
	
	# build package 
	build_package $name
	
	cd "${glb_source_path}/${name}/build" || error_mkdir
	
	print_log -n "Install ${name} manuals... "
	make html >/dev/null 2>&1 || error_make
	make install-html-gcc >/dev/null 2>&1 || error_install
	print_log "done"
	
	cd $BASEPATH
	
	ln -sf "${glb_prefix}/bin/arm-linux-gnueabihf-gcc" "${glb_prefix}/bin/arm-linux-gnueabihf-cc" || warning_ln
	
	unset CC_FOR_BUILD
	unset CFLAGS
	unset LDFLAGS
	unset CXXFLAGS_FOR_TARGET
	unset LDFLAGS_FOR_TARGET
	unset build_args
}