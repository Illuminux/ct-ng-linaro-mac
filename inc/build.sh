#!/bin/bash
#
# This is a part of ARM Linux Cross-Toolchain for Mac OS X build script
#
# Copyright (C) 2014  Knut Welzel
#

build_args=()

##
## Build package 
##
build_package(){
	
	name=$1

	print_log "Building ${name}:"

	# create new build dir
	if ! [ -d "${build_dir}" ]; then
		mkdir -p $build_dir || error_mkdir
	fi
	cd $build_dir
	
	# configure gmp
	print_log -n "Configure ${name}... "
	
	${glb_source_path}/${name}/configure ${build_args[@]} > "${glb_log_path}/${name}.log" 2>&1 || error_configure
	
	print_log "done"
	
	# build gmp
	print_log -n "Build ${name}... "
	make >> "${glb_log_path}/${name}.log" 2>&1 || error_make
	print_log "done"
	
	print_log -n "Install ${name}... "
	make install >> "${glb_log_path}/${name}.log" 2>&1 || error_install
	print_log "done"
	
	cd $BASEPATH
}


##
## Build gmp
##
build_gmp(){
	
	name=${package_gmp[0]}
	
	# configure flags 
	export CFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE -fexceptions"
	
	# configure args
	build_args=(
		--build=$glb_build
		--host=$glb_build
		--prefix=${glb_build_path}/static
		--enable-fft
		--enable-mpbsd
		--enable-cxx
		--disable-shared
		--enable-static
	)
	
	# build in dir
	build_dir=${glb_source_path}/${name}/build
	
	# build package 
	build_package $name
	
	unset CFLAGS
	unset build_args
}


##
## Build mpfr
##
build_mpfr(){
	
	name=${package_mpfr[0]}
	
	# configure flags 
	export CFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE"
	
	# configure args
	build_args=(
		--build=$glb_build
		--host=$glb_build
		--prefix=${glb_build_path}/static
		--with-gmp=${glb_build_path}/static
		--disable-shared
		--enable-static
	)
	
	# build in dir
	build_dir=${glb_source_path}/${name}/build
	
	# build package 
	build_package $name
	
	unset CFLAGS
	unset build_args
}


##
## Build isl
##
build_isl(){
	
	name=${package_isl[0]}
	
	# configure flags
	export CFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE -I${glb_build_path}/static/include"
	export CXXFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE -I${glb_build_path}/static/include"
	export LDFLAGS="-L${glb_build_path}/static/lib"
	
	# configure args
	build_args=(
		--build=$glb_build
		--host=$glb_build
		--prefix=${glb_build_path}/static
		--with-gmp=${glb_build_path}/static
		--disable-shared
		--enable-static
	)
	
	# build in dir
	build_dir=${glb_source_path}/${name}/build
	
	# build package 
	build_package $name
	
	unset CFLAGS
	unset CXXFLAGS
	unset LDFLAGS
	unset build_args
}


##
## Build cloog
##
build_cloog(){
	
	name=${package_cloog[0]}
	
	# configure flags 
	export CFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE"
	
	# configure args
	build_args=(
		--build=$glb_build
		--host=$glb_build
		--prefix=${glb_build_path}/static
		--with-gmp-prefix=${glb_build_path}/static
		--with-isl-prefix=${glb_build_path}/static
		--disable-shared
		--enable-static
	)
	
	# build in dir
	build_dir=${glb_source_path}/${name}/build
	
	# build package 
	build_package $name
	
	unset CFLAGS
	unset build_args
}


##
## Build mpc
##
build_mpc(){
	
	name=${package_mpc[0]}
	
	# configure flags 
	export CFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE -I${glb_build_path}/static/include"
	export CXXFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE -I${glb_build_path}/static/include"
	export LDFLAGS="-L${glb_build_path}/static/lib"

	
	# configure args
	build_args=(
		--build=$glb_build
		--host=$glb_build
		--prefix=${glb_build_path}/static
		--with-gmp-prefix=${glb_build_path}/static
		--with-mpfr-prefix=${glb_build_path}/static
		--disable-shared
		--enable-static
	)
	
	# build in dir
	build_dir=${glb_source_path}/${name}/build
	
	# build package 
	build_package $name
	
	unset CFLAGS
	unset CXXFLAGS
	unset LDFLAGS
	unset build_args
}


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
		--prefix=${glb_build_path}/static/zlib \
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
		--build=$glb_build
		--host=$glb_build
		--target=$glb_target
		--prefix=$glb_prefix
		--disable-multilib
		--disable-werror
		--enable-ld=default
		--enable-gold=yes
		--enable-threads
		--with-float=hard
		--with-sysroot="${glb_sysroot_path}/libc"
		--with-pkgversion=$glb_build_version
		--with-bugurl=$glb_bug_url
	)
	
	# build in dir
	build_dir=${glb_source_path}/${name}/build
	
	# build package 
	build_package $name
	
	cd "${glb_source_path}/${name}/build"
	
	print_log -n "Install ${name} documentation... "
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
		INSTALL_HDR_PATH="${glb_prefix}/arm-linux-gnueabihf/libc/usr" \
		V=1 \
		headers_install > "${glb_log_path}/${name}.log" 2>&1 || error_make

	print_log "done"

	# Checking kernel sources
	print_log -n "Checking Kernel headers... "
	
	make \
		-C "${glb_disk_image_path}/${name}" \
		O="${glb_disk_image_path}/${name}/build" \
		ARCH=arm \
		INSTALL_HDR_PATH="${glb_prefix}/arm-linux-gnueabihf/libc/usr" \
		V=1 \
		headers_check >> "${glb_log_path}/${name}.log" 2>&1 || error_make
	
	print_log "done"
	
	build_sysroot
}


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
		--build=$glb_build
		--host=$glb_build
		--target=$glb_target
		--prefix=$glb_prefix
		--with-sysroot="${glb_sysroot_path}/libc"
		--enable-multilib
		--with-arch=armv7-a
		--with-tune=cortex-a9
		--with-fpu=vfpv3-d16
		--with-float=hard
		--enable-__cxa_atexit
		--enable-libmudflap
		--enable-libgomp
		--enable-libssp
		--with-gmp=${glb_build_path}/static
		--with-mpfr=${glb_build_path}/static
		--with-mpc=${glb_build_path}/static
		--with-isl=${glb_build_path}/static
		--with-cloog=${glb_build_path}/static
		--with-libelf=${glb_build_path}/static
		--enable-threads=posix
		--disable-libstdcxx-pch
		--enable-linker-build-id
		--enable-gold
		--with-local-prefix=$glb_prefix/arm-linux-gnueabihf/libc
		--enable-c99
		--enable-long-long
		--with-mode=thumb
		--with-float=hard
		--with-pkgversion=$glb_build_version
		--with-bugurl=$glb_bug_url
	)
	
	# build in dir
	build_dir=${glb_source_path}/${name}/build
	
	# build package 
	build_package $name
	
	cd "${glb_source_path}/${name}/build" || error_mkdir
	
	print_log -n "Install ${name} documentation... "
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


##
## Build eXpat
##
build_expat(){
	
	name=${package_expat[0]}
	
	# configure flags
	
	# configure args
	build_args=(
		--build=$glb_build
		--host=$glb_build
		--target=$glb_target
		--prefix=${glb_build_path}/static
		--disable-shared
		--enable-static
	)
	
	# build in dir
	build_dir=${glb_source_path}/${name}/build
	
	# build package 
	build_package $name
	
	unset build_args
}


##
## Build ncurses
##
build_ncurses(){
	
	name=${package_ncurses[0]}
	
	# configure args
	build_args=(
		--build=$glb_build
		--host=$glb_build
		--target=$glb_target
		--prefix=${glb_build_path}/static
		--disable-shared
		--enable-static
		--without-ada
	)
	
	# build in dir
	build_dir=${glb_source_path}/${name}/build
	
	# build package 
	build_package $name

#	unset CC
	unset build_args
}


##
## Build gdb
##
build_gdb(){
	
	name=${package_gdb[0]}
	
	# configure flags
	export CFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE -I${glb_build_path}/static/zlib/include"
	export LDFLAGS="-L${glb_build_path}/static/lib -L${glb_build_path}/static/zlib/lib"
	
	# configure args
	build_args=(
		--build=$glb_build
		--host=$glb_build
		--target=$glb_target
		--prefix=$glb_prefix
		--with-build-sysroot="${glb_sysroot_path}/libc"
		--with-sysroot="${glb_sysroot_path}/libc"
		--with-expat=yes
		--disable-werror
		--enable-threads
		--with-python=no
		--with-libexpat-prefix="${glb_build_path}/static"
		--disable-sim
		--with-pkgversion=$glb_build_version
		--with-bugurl=$glb_bug_url
	)
	
	# build in dir
	build_dir=${glb_source_path}/${name}/build
	
	# build package 
	build_package $name
	
	cd "${glb_source_path}/${name}/build" || error_mkdir
	
	print_log -n "Install ${name} documentation... "
	make >/dev/null 2>&1 || error_make
	make install-html-gdb >/dev/null 2>&1 || error_install
	print_log "done - skipped pdf MacTeX is not installed" 2>&1 | tee -a $glb_build_log
	
	unset CFLAGS
	unset LDFLAGS
	unset build_args
}


##
## Build pkgconf
##
build_pkgconf(){
	
	name=${package_pkgconf[0]}
	
	
	export CC=$glb_cc
	
	# configure args
	build_args=(
		--prefix=$glb_prefix
		--build=$glb_build
		--host=$glb_build
		--program-prefix="$glb_target-"
		--program-suffix="-real"
		--with-pc-path="${glb_prefix}/arm-linux-gnueabihf/libc/usr/lib/arm-linux-gnueabihf/pkgconfig:${glb_prefix}/arm-linux-gnueabihf/libc/usr/lib//pkgconfig:${glb_prefix}/arm-linux-gnueabihf/libc/usr/share/pkgconfig" 
	)
	
	# build in dir
	build_dir=${glb_source_path}/${name}/build
	
	# build package 
	build_package $name
	
#	cp -a \
#		/home/knut/Develop/crosstool-ng-2013.12/lib/ct-ng-linaro-1.13.1-4.8-2013.12/scripts/build/cross_extras/pkg-config-wrapper
#		/home/knut/Develop//crosstool-ng-2013.12/lib/ct-ng-linaro-1.13.1-4.8-2013.12/install/bin/arm-linux-gnueabihf-pkg-config
	
	unset CC
	unset build_args
}


##
## Build sysroot
##
build_sysroot(){
	
	name=${package_sysroot[0]}
	
	# install sysroot
	print_log -n "Install sysroot... "
	
	# create new build dir
	if ! [ -d "${glb_prefix}/arm-linux-gnueabihf/libc" ]; then
		mkdir -p "${glb_prefix}/arm-linux-gnueabihf/libc" || error_mkdir
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

