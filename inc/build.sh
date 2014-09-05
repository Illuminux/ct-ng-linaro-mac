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

	echo "Building ${name}:"

	# create new build dir
	if ! [ -d "${build_dir}" ]; then
		mkdir -p $build_dir
	fi
	cd $build_dir
	
	# configure gmp
	echo -n "Configure ${name}... "
	
	${glb_source_path}/${name}/configure ${build_args[@]} > "${glb_log_path}/${name}.log" 2>&1 || exit 1
	
	echo "done"
	
	# build gmp
	echo -n "Build ${name}... "
	make >> "${glb_log_path}/${name}.log" 2>&1 || exit 1
	echo "done"
	
	echo -n "Install ${name}... "
	make install >> "${glb_log_path}/${name}.log" 2>&1 || exit 1
	echo "done"
	
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
		--build=$BUILD
		--host=$BUILD
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
		--build=$BUILD
		--host=$BUILD
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
	export CFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE"
	export CXXFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE"
	
	# configure args
	build_args=(
		--build=$BUILD
		--host=$BUILD
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
		--build=$BUILD
		--host=$BUILD
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
	export CFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE"
	export CXXFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE"

	
	# configure args
	build_args=(
		--build=$BUILD
		--host=$BUILD
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
	unset build_args
}


##
## Build zlib
##
build_zlib(){
	
	name=${package_zlib[0]}
	
	# build in dir
	cd "${glb_source_path}/${name}"
	
	
	echo "Building ${name}:"
	
	# configure gmp
	echo -n "Configure ${name}... "
	
	CFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE" \
	CXXFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE" \
	./configure \
		--prefix=${glb_build_path}/static/zlib \
		--static >> "${glb_log_path}/${name}.log" 2>&1 || exit 1
	
	echo "done"
	
	# build gmp
	echo -n "Build ${name}... "
	make >> "${glb_log_path}/${name}.log" 2>&1 || exit 1
	echo "done"
	
	echo -n "Install ${name}... "
	make install >> "${glb_log_path}/${name}.log" 2>&1 || exit 1
	echo "done"
}


##
## Build Binutils
##
build_binutils(){
	
	name=${package_binutils[0]}
	
	# configure flags
	export CFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE -I${glb_build_path}/static/zlib/include"
	export CXXFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE -I${glb_build_path}/static/zlib/include"
	export LDFLAGS="-L${glb_build_path}/static/zlib/lib"
	
	# configure args
	build_args=(
		--build=$BUILD
		--host=$BUILD
		--target=$TARGET
		--prefix=${glb_prefix}
		--disable-multilib
		--disable-werror
		--enable-ld=default
		--enable-gold=yes
		--enable-threads
		--with-float=hard
		--with-sysroot="${glb_sysroot_path}/libc"
		--with-pkgversion=$BUILDVERSION
		--with-bugurl=$BUGURL
	)
#		--with-pkgversion="\"${BUILDVERSION}\""
#	)
	
	# build in dir
	build_dir=${glb_source_path}/${name}/build
	
	# build package 
	build_package $name
	
	cd "${glb_source_path}/${name}/build"
	
	echo -n "Install ${name} Documentation... "
	make html >> "${glb_log_path}/${name}.log" 
	make install-html-gas install-html-binutils install-html-ld install-html-gprof >> "${glb_log_path}/${name}.log" 
	echo "done"
	
	cd $BASEPATH
	
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
	
	echo "Building Linux Kernel Headers:"
	
	# Go into kernel source directory
	cd "${glb_disk_image_path}/${name}"
	
	# create new build dir
	if ! [ -d "${glb_disk_image_path}/${name}/build" ]; then
		mkdir -p "${glb_disk_image_path}/${name}/build"
	fi
	
	# Install kernel sources
	echo -n "Install Kernel... "
		
	make \
		-C "${glb_disk_image_path}/${name}" \
		O="${glb_disk_image_path}/${name}/build" \
		ARCH=arm \
		INSTALL_HDR_PATH="${glb_prefix}/arm-linux-gnueabihf/libc/usr" \
		V=1 \
		headers_install > "${glb_log_path}/${name}.log" 2>&1 || exit 1

	echo "done"

	# Checking kernel sources
	echo -n "Checking Kernel headers... "
	
	make \
		-C "${glb_disk_image_path}/${name}" \
		O="${glb_disk_image_path}/${name}/build" \
		ARCH=arm \
		INSTALL_HDR_PATH="${glb_prefix}/arm-linux-gnueabihf/libc/usr" \
		V=1 \
		headers_check >> "${glb_log_path}/${name}.log" 2>&1 || exit 1
	
	echo "done"
	
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
	export CXXFLAGS_FOR_TARGET="-mlittle-endian -march=armv7-a   -mtune=cortex-a9 -mfpu=vfpv3-d16 -mhard-float -g -O2"
	export LDFLAGS_FOR_TARGET="-Wl,-EL"
	
	# configure args
	build_args=(
		--build=$BUILD
		--host=$BUILD
		--target=$TARGET
		--prefix=${glb_prefix}
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
		--with-local-prefix=${glb_prefix}/arm-linux-gnueabihf/libc
		--enable-c99
		--enable-long-long
		--with-mode=thumb
		--with-float=hard
		--with-pkgversion=$BUILDVERSION
		--with-bugurl=$BUGURL
	)
	
	# build in dir
	build_dir=${glb_source_path}/${name}/build
	
	# build package 
	build_package $name
	
	cd "${glb_source_path}/${name}/build"
	
	echo -n "Install ${name} Documentation... "
	make html >> "${glb_log_path}/${name}.log" 
	make install-html-gcc >> "${glb_log_path}/${name}.log" 
	echo "done"
	
	cd $BASEPATH
	
	ln -sf "${glb_prefix}/bin/arm-linux-gnueabihf-gcc" "${glb_prefix}/bin/arm-linux-gnueabihf-cc"
	
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
		--build=$BUILD
		--host=$BUILD
		--target=$TARGET
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
	
	# configure flags
	
	# configure args
	build_args=(
		--build=$BUILD
		--host=$BUILD
		--target=$TARGET
		--prefix=${glb_build_path}/static
		--disable-shared
		--enable-static
		--without-ada
	)
	
	# build in dir
	build_dir=${glb_source_path}/${name}/build
	
	# build package 
	build_package $name
	
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
		--build=$BUILD
		--host=$BUILD
		--target=$TARGET
		--prefix=${glb_prefix}
		--with-build-sysroot="${glb_sysroot_path}/libc"
		--with-sysroot="${glb_sysroot_path}/libc"
		--with-expat=yes
		--disable-werror
		--enable-threads
		--with-python=no
		--with-libexpat-prefix="${glb_build_path}/static"
		--disable-sim
		--with-pkgversion=$BUILDVERSION
		--with-bugurl=$BUGURL
	)
	
	# build in dir
	build_dir=${glb_source_path}/${name}/build
	
	# build package 
	build_package $name
	
	cd "${glb_source_path}/${name}/build"
	
	echo -n "Install ${name} Documentation... "
	make -j2 html  >> ${glb_log_path}/gdb.log
	make install-html-gdb >> ${glb_log_path}/gdb.log
	echo "done - skipped pdf MacTeX is not installed" 2>&1 | tee -a $glb_build_log
	
	unset CFLAGS
	unset LDFLAGS
	unset build_args
}


##
## Build pkgconf
##
build_pkgconf(){
	
	name=${package_pkgconf[0]}
	
	# configure flags
	
	# configure args
	build_args=(
		--prefix=${glb_prefix}
		--build=$BUILD
		--host=$BUILD
		--program-prefix="$TARGET-"
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
	
	unset build_args
}


##
## Build sysroot
##
build_sysroot(){
	
	name=${package_sysroot[0]}
	
	# install sysroot
	echo -n "Install sysroot... "
	
	# create new build dir
	if ! [ -d "${glb_prefix}/arm-linux-gnueabihf/libc" ]; then
		mkdir -p "${glb_prefix}/arm-linux-gnueabihf/libc"
	fi

	cp -a \
		"${glb_source_path}/${name}/etc" \
		"${glb_source_path}/${name}/lib" \
		"${glb_source_path}/${name}/sbin" \
		"${glb_source_path}/${name}/usr" \
		"${glb_source_path}/${name}/var" \
		"${glb_sysroot_path}/libc" || exit 1
	
	echo "done"
}

