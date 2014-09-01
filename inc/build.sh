#!/bin/bash


##
## Build sysroot
##
build_sysroot(){

	echo "Building sysroot:" 2>&1 | tee -a $glb_build_log
	
	# Go into download dir
	cd $glb_download_path

	# Check if sysroot archive exists 
	if [ ! -f "${glb_sysroot_arch}" ]; then
		echo "*** Error *** ${glb_sysroot_arch} not found!" 2>&1 | tee -a $glb_build_log
		exit 1
	fi
	
	# Test if sysroot archive is not corrupted
	echo -n "md5 check of ${glb_sysroot_arch}... "
	if [ ! $(md5 -q ${glb_download_path}/${glb_sysroot_arch}) = ${glb_sysroot_md5} ]; then
		echo "faild!" 2>&1 | tee -a $glb_build_log
		exit 1
	fi
	echo "passed" 2>&1 | tee -a $glb_build_log

	# extract sysroot if not already done
	cd ${glb_source_path}
	if [ ! -d "${glb_source_path}/${glb_sysroot_name}" ]; then
		
		echo -n "Extracting sysroot... " 2>&1 | tee -a $glb_build_log
		tar xjf ${glb_download_path}/${glb_sysroot_arch} >> $glb_build_log 2>&1 || exit 1
		echo "done" 2>&1 | tee -a $glb_build_log
	fi

	# install sysroot
	echo -n "Install sysroot... " 2>&1 | tee -a $glb_build_log
	
	mkdir -p ${glb_prefix}/arm-linux-gnueabihf/libc >> $glb_build_log 2>&1 || exit 1

	cp -a \
		"${glb_source_path}/${glb_sysroot_name}/etc" \
		"${glb_source_path}/${glb_sysroot_name}/lib" \
		"${glb_source_path}/${glb_sysroot_name}/sbin" \
		"${glb_source_path}/${glb_sysroot_name}/usr" \
		"${glb_source_path}/${glb_sysroot_name}/var" \
		"${glb_prefix}/arm-linux-gnueabihf/libc" >> $glb_build_log 2>&1 || exit 1
	
	echo "done" 2>&1 | tee -a $glb_build_log
}


##
## Build gmp
##
build_gmp(){

	echo "Building gmp:" 2>&1 | tee -a $glb_build_log
	
	# Go into download dir
	cd ${glb_download_path}

	# Check if gmp archive exists 
	if [ ! -f "${glb_gmp_arch}" ]; then
		echo "*** Error *** ${glb_gmp_arch} not found!" 2>&1 | tee -a $glb_build_log
		exit 1
	fi
	
	# Test if gmp archive is not corrupted
	echo -n "md5 check of ${glb_gmp_arch}... " 2>&1 | tee -a $glb_build_log
	if [ ! $(md5 -q ${glb_download_path}/${glb_gmp_arch}) = ${glb_gmp_md5} ]; then
		echo "faild!" 2>&1 | tee -a $glb_build_log
		exit 1
	fi
	echo "passed" 2>&1 | tee -a $glb_build_log

	# extract gmp if not already done
	cd ${glb_source_path}
	if [ ! -d "${glb_source_path}/${glb_gmp_name}" ]; then
		
		echo -n "Extracting gmp... " 2>&1 | tee -a $glb_build_log
		tar xjf ${glb_download_path}/${glb_gmp_arch} >> $glb_build_log 2>&1 || exit 1
		echo "done" 2>&1 | tee -a $glb_build_log
		
		# Patching 
		if [ -f "${glb_patch_path}/${glb_gmp_name}.patch" ]; then
			
			echo -n "Patching ${glb_gmp_name}... " 2>&1 | tee -a $glb_build_log
			cd ${glb_source_path}/${glb_gmp_name}
			patch --no-backup-if-mismatch -g0 -F1 -p1 -f < ${glb_patch_path}/${glb_gmp_name}.patch >> $glb_build_log 2>&1 || exit 1
			echo "done" 2>&1 | tee -a $glb_build_log
		fi
	else
		# remove old build
		if [ -d "${glb_source_path}/${glb_gmp_name}/build" ]; then
			rm -rf ${glb_source_path}/${glb_gmp_name}/build
		fi
	fi

	# create new build dir
	mkdir -p ${glb_source_path}/${glb_gmp_name}/build >> ${glb_log_path}/gmp.log 2>&1 || exit 1
	cd ${glb_source_path}/${glb_gmp_name}/build

	# configure gmp
	echo -n "Configure gmp... " 2>&1 | tee -a $glb_build_log
	
	CFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE -fexceptions" \
	../configure \
		--build=$BUILD \
		--host=$BUILD \
		--prefix=${glb_build_path}/static \
		--enable-fft \
		--enable-mpbsd \
		--enable-cxx \
		--disable-shared \
		--enable-static >> ${glb_log_path}/gmp.log 2>&1 || exit 1

	echo "done" 2>&1 | tee -a $glb_build_log
	
	# build gmp
	echo -n "Build gmp... " 2>&1 | tee -a $glb_build_log
	make -j2  >> ${glb_log_path}/gmp.log 2>&1 || exit 1
	echo "done" 2>&1 | tee -a $glb_build_log

	echo -n "Install gmp... "
	make install >> ${glb_log_path}/gmp.log 2>&1 || exit 1
	echo "done" 2>&1 | tee -a $glb_build_log
}


##
## Build mpfr
##
build_mpfr(){

	echo "Building mpfr..." 2>&1 | tee -a $glb_build_log
	
	# Go into download dir
	cd ${glb_download_path}
	
	# Check if mpfr archive exists 
	if [ ! -f "${glb_mpfr_arch}" ]; then
		echo "*** Error *** ${glb_mpfr_arch} not found!" 2>&1 | tee -a $glb_build_log
		exit 1
	fi
	
	# Test if mpfr archive is not corrupted
	echo -n "md5 check of ${glb_mpfr_arch}... " 2>&1 | tee -a $glb_build_log
	if [ ! $(md5 -q ${glb_download_path}/${glb_mpfr_arch}) = ${glb_mpfr_md5} ]; then
		echo "faild!" 2>&1 | tee -a $glb_build_log
		exit 1
	fi
	echo "passed" 2>&1 | tee -a $glb_build_log

	# extract mpfr if not already done
	cd ${glb_source_path}
	if [ ! -d "${glb_source_path}/${glb_mpfr_name}" ]; then
		
		echo -n "Extracting mpfr... " 2>&1 | tee -a $glb_build_log
		tar xjf ${glb_download_path}/${glb_mpfr_arch} >> ${glb_log_path}/mpfr.log 2>&1 || exit 1
		echo "done" 2>&1 | tee -a $glb_build_log
		
		# Patching 
		if [ -f "${glb_patch_path}/${glb_mpfr_name}.patch" ]; then
			
			echo -n "Patching ${glb_mpfr_name}... " 2>&1 | tee -a $glb_build_log
			cd ${glb_source_path}/${glb_mpfr_name}
			patch --no-backup-if-mismatch -g0 -F1 -p1 -f < ${glb_patch_path}/${glb_mpfr_name}.patch >> $glb_build_log
			echo "done" 2>&1 | tee -a $glb_build_log
		fi
	else
		# remove old build
		if [ -d "${glb_source_path}/${glb_mpfr_name}/build" ]; then
			rm -rf ${glb_source_path}/${glb_mpfr_name}/build
		fi
	fi

	# create new build dir
	mkdir -p ${glb_source_path}/${glb_mpfr_name}/build >> ${glb_log_path}/mpfr.log 2>&1 || exit 1
	cd ${glb_source_path}/${glb_mpfr_name}/build

	# configure mpfr
	echo -n "Configure mpfr... " 2>&1 | tee -a $glb_build_log
	
	CC="${glb_cc}" \
	CFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE" \
	../configure \
		--build=$BUILD \
		--host=$BUILD \
		--prefix=${glb_build_path}/static \
		--with-gmp=${glb_build_path}/static \
		--disable-shared \
		--enable-static  >> ${glb_log_path}/mpfr.log 2>&1 || exit 1

	echo "done" 2>&1 | tee -a $glb_build_log
	
	# build mpfr
	echo -n "Build mpfr... " 2>&1 | tee -a $glb_build_log
	make -j2 >> ${glb_log_path}/mpfr.log 2>&1 || exit 1
	echo "done"  2>&1 | tee -a $glb_build_log
	
	# install mpfr
	echo -n "Install mpfr... " 2>&1 | tee -a $glb_build_log
	make install >> ${glb_log_path}/mpfr.log 2>&1 || exit 1
	echo "done" 2>&1 | tee -a $glb_build_log
}


##
## Build isl
##
build_isl(){

	echo "Building isl:" 2>&1 | tee -a $glb_build_log
	
	# Go into download dir
	cd ${glb_download_path}
	
	# Check if isl archive exists 
	if [ ! -f "${glb_isl_arch}" ]; then
		echo "*** Error *** ${glb_isl_arch} not found!" 2>&1 | tee -a $glb_build_log
		exit 1
	fi
	
	# Test if isl archive is not corrupted
	echo -n "md5 check of ${glb_isl_arch}... " 2>&1 | tee -a $glb_build_log
	if [ ! $(md5 -q ${glb_download_path}/${glb_isl_arch}) = ${glb_isl_md5} ]; then
		echo "faild!" 2>&1 | tee -a $glb_build_log
		exit 1
	fi
	echo "passed" 2>&1 | tee -a $glb_build_log

	# extract isl if not already done
	cd ${glb_source_path}
	if [ ! -d "${glb_source_path}/${glb_isl_name}" ]; then
		echo -n "Extracting isl... " 2>&1 | tee -a $glb_build_log
		tar xjf ${glb_download_path}/${glb_isl_arch} >> $glb_build_log 2>&1 || exit 1
		echo "done" 2>&1 | tee -a $glb_build_log
		
		# Patching 
		if [ -f "${glb_patch_path}/${glb_isl_name}.patch" ]; then
			
			echo -n "Patching ${glb_isl_name}... " 2>&1 | tee -a $glb_build_log
			cd ${glb_source_path}/${glb_isl_name}
			patch --no-backup-if-mismatch -g0 -F1 -p1 -f < ${glb_patch_path}/${glb_isl_name}.patch >> $glb_build_log
			echo "done" 2>&1 | tee -a $glb_build_log
		fi
	else
		# remove old build
		if [ -d "${glb_source_path}/${glb_isl_name}/build" ]; then
			rm -rf ${glb_source_path}/${glb_isl_name}/build
		fi
	fi

	# create new build dir
	mkdir -p ${glb_source_path}/${glb_isl_name}/build >> $glb_build_log 2>&1 || exit 1
	cd ${glb_source_path}/${glb_isl_name}/build

	# configure isl
	echo -n "Configure isl... " 2>&1 | tee -a $glb_build_log
		
	CFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE" \
	CXXFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE" \
	../configure \
		--build=$BUILD \
		--host=$BUILD \
		--prefix=${glb_build_path}/static \
		--with-gmp-prefix=${glb_build_path}/static \
		--disable-shared \
		--enable-static >> ${glb_log_path}/isl.log 2>&1 || exit 1
	
	echo "done" 2>&1 | tee -a $glb_build_log
	
	# build isl
	echo -n "Build isl... " 2>&1 | tee -a $glb_build_log
	make -j2 >> ${glb_log_path}/isl.log 2>&1 || exit 1
	echo "done"  2>&1 | tee -a $glb_build_log
	
	# install isl
	echo -n "Install isl... " 2>&1 | tee -a $glb_build_log
	make install >> ${glb_log_path}/isl.log 2>&1 || exit 1
	echo "done" 2>&1 | tee -a $glb_build_log
}


##
## Build cloog
##
build_cloog(){

	echo "Building cloog:" 2>&1 | tee -a $glb_build_log
	
	# Go into download dir
	cd ${glb_download_path}
	
	# Check if cloog archive exists 
	if [ ! -f "${glb_cloog_arch}" ]; then
		echo "*** Error *** ${glb_cloog_arch} not found!" 2>&1 | tee -a $glb_build_log
		exit 1
	fi
	
	# Test if cloog archive is not corrupted
	echo -n "md5 check of ${glb_cloog_arch}... " 2>&1 | tee -a $glb_build_log
	if [ ! $(md5 -q ${glb_download_path}/${glb_cloog_arch}) = ${glb_cloog_md5} ]; then
		echo "faild!" 2>&1 | tee -a $glb_build_log
		exit 1
	fi
	echo "passed" 2>&1 | tee -a $glb_build_log

	# extract cloog if not already done
	cd ${glb_source_path}
	if [ ! -d "${glb_source_path}/${glb_cloog_name}" ]; then

		echo -n "Extracting cloog... " 2>&1 | tee -a $glb_build_log
		tar xjf ${glb_download_path}/${glb_cloog_arch} >> $glb_build_log 2>&1 || exit 1
		echo "done" 2>&1 | tee -a $glb_build_log
		
		# Patching 
		if [ -f "${glb_patch_path}/${glb_cloog_name}.patch" ]; then
			
			echo -n "Patching ${glb_cloog_name}... " 2>&1 | tee -a $glb_build_log
			cd ${glb_source_path}/${glb_cloog_name}
			patch --no-backup-if-mismatch -g0 -F1 -p1 -f < ${glb_patch_path}/${glb_cloog_name}.patch >> $glb_build_log
			echo "done" 2>&1 | tee -a $glb_build_log
		fi
	else
		# remove old build
		if [ -d "${glb_source_path}/${glb_cloog_name}/build" ]; then
			rm -rf ${glb_source_path}/${glb_cloog_name}/build
		fi
	fi

	# create new build dir
	mkdir -p ${glb_source_path}/${glb_cloog_name}/build >> $glb_build_log 2>&1 || exit 1
	cd ${glb_source_path}/${glb_cloog_name}/build

	# configure cloog
	echo -n "Configure cloog... " 2>&1 | tee -a $glb_build_log
	
	CFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE" \
	../configure \
		--build=$BUILD \
		--host=$BUILD \
		--prefix=${glb_build_path}/static \
		--with-gmp-prefix=${glb_build_path}/static \
		--with-isl-prefix=${glb_build_path}/static \
		--disable-shared \
		--enable-static >> ${glb_log_path}/cloog.log 2>&1 || exit 1

	echo "done" 2>&1 | tee -a $glb_build_log
	
	# build cloog
	echo -n "Build cloog... " 2>&1 | tee -a $glb_build_log
	make -j2 >> ${glb_log_path}/cloog.log 2>&1 || exit 1
	echo "done" 2>&1 | tee -a $glb_build_log
	
	# install cloog
	echo -n "Install cloog... " 2>&1 | tee -a $glb_build_log
	make install >> ${glb_log_path}/cloog.log 2>&1 || exit 1
	echo "done" 2>&1 | tee -a $glb_build_log
}


##
## Build mpc
##
build_mpc(){

	echo "Building mpc:" 2>&1 | tee -a $glb_build_log
	
	# Go into download dir
	cd ${glb_download_path}
	
	# Check if mpc archive exists 
	if [ ! -f "${glb_mpc_arch}" ]; then
		echo "*** Error *** ${glb_mpc_arch} not found!" 2>&1 | tee -a $glb_build_log
		exit 1
	fi
	
	# Test if mpc archive is not corrupted
	echo -n "md5 check of ${glb_mpc_arch}... " 2>&1 | tee -a $glb_build_log
	if [ ! $(md5 -q ${glb_download_path}/${glb_mpc_arch}) = ${glb_mpc_md5} ]; then
		echo "faild!" 2>&1 | tee -a $glb_build_log
		exit 1
	fi
	echo "passed" 2>&1 | tee -a $glb_build_log

	# extract mpc if not already done
	cd ${glb_source_path}
	if [ ! -d "${glb_source_path}/${glb_mpc_name}" ]; then
		
		echo -n "Extracting mpc... " 2>&1 | tee -a $glb_build_log
		tar xjf ${glb_download_path}/${glb_mpc_arch} >> $glb_build_log 2>&1 || exit 1
		echo "done" 2>&1 | tee -a $glb_build_log
		
		# Patching 
		if [ -f "${glb_patch_path}/${glb_mpc_name}.patch" ]; then
			
			echo -n "Patching ${glb_mpc_name}... " 2>&1 | tee -a $glb_build_log
			cd ${glb_source_path}/${glb_mpc_name}
			patch --no-backup-if-mismatch -g0 -F1 -p1 -f < ${glb_patch_path}/${glb_mpc_name}.patch >> $glb_build_log
			echo "done" 2>&1 | tee -a $glb_build_log
		fi
	else
		# remove old build
		if [ -d "${glb_source_path}/${glb_mpc_name}/build" ]; then
			rm -rf ${glb_source_path}/${glb_mpc_name}/build
		fi
	fi

	# create new build dir
	mkdir -p ${glb_source_path}/${glb_mpc_name}/build >> $glb_build_log 2>&1 || exit 1
	cd ${glb_source_path}/${glb_mpc_name}/build

	# configure mpc
	echo -n "Configure mpc... " 2>&1 | tee -a $glb_build_log
	
	CFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE" \
	../configure \
		--build=$BUILD \
		--host=$BUILD \
		--prefix=${glb_build_path}/static \
		--with-gmp=${glb_build_path}/static \
		--with-mpfr=${glb_build_path}/static \
		--disable-shared \
		--enable-static >> ${glb_log_path}/mpc.log 2>&1 || exit 1

	echo "done" 2>&1 | tee -a $glb_build_log
	
	# build mpc
	echo -n "Build mpc... " 2>&1 | tee -a $glb_build_log
	make -j2 >> ${glb_log_path}/mpc.log 2>&1 || exit 1
	echo "done"  2>&1 | tee -a $glb_build_log
	
	# install mpc
	echo -n "Install mpc... " 2>&1 | tee -a $glb_build_log
	make install >> ${glb_log_path}/mpc.log 2>&1 || exit 1
	echo "done" 2>&1 | tee -a $glb_build_log
}


##
## Build zlib
##
build_zlib(){

	echo "Building zlib:" 2>&1 | tee -a $glb_build_log
	
	# Go into download dir
	cd ${glb_download_path}
	
	# Check if zlib archive exists 
	if [ ! -f "${glb_zlib_arch}" ]; then
		echo "*** Error *** ${glb_zlib_arch} not found!" 2>&1 | tee -a $glb_build_log
		exit 1
	fi
	
	# Test if zlib archive is not corrupted
	echo -n "md5 check of ${glb_zlib_arch}... " 2>&1 | tee -a $glb_build_log
	if [ ! $(md5 -q ${glb_download_path}/${glb_zlib_arch}) = ${glb_zlib_md5} ]; then
		echo "faild!" 2>&1 | tee -a $glb_build_log
		exit 1
	fi
	echo "passed" 2>&1 | tee -a $glb_build_log

	# remove old zlib
	cd ${glb_source_path}
	if [ -d "${glb_source_path}/${glb_zlib_name}" ]; then
	
		rm -rf ${glb_source_path}/${glb_zlib_name}
	fi
	
	echo -n "Extracting zlib... " 2>&1 | tee -a $glb_build_log
	tar xjf ${glb_download_path}/${glb_zlib_arch} >> $glb_build_log 2>&1 || exit 1
	echo "done" 2>&1 | tee -a $glb_build_log
	
	# Patching 
	if [ -f "${glb_patch_path}/${glb_zlib_name}.patch" ]; then
		
		echo -n "Patching ${glb_zlib_name}... " 2>&1 | tee -a $glb_build_log
		cd ${glb_source_path}/${glb_zlib_name}
		patch --no-backup-if-mismatch -g0 -F1 -p1 -f < ${glb_patch_path}/${glb_zlib_name}.patch >> $glb_build_log
		echo "done" 2>&1 | tee -a $glb_build_log
	fi

	cd ${glb_source_path}/${glb_zlib_name}

	# configure zlib
	echo -n "Configure zlib... " 2>&1 | tee -a $glb_build_log
	
	CFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE" \
	CXXFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE" \
	./configure \
		--prefix=${glb_build_path}/static/zlib \
		--static >> ${glb_log_path}/zlib.log 2>&1 || exit 1

	echo "done" 2>&1 | tee -a $glb_build_log
	
	# build zlib
	echo -n "Build zlib... " 2>&1 | tee -a $glb_build_log
	make -j2 >> ${glb_log_path}/zlib.log 2>&1 || exit 1
	echo "done"  2>&1 | tee -a $glb_build_log
	
	# install zlib
	echo -n "Install zlib... " 2>&1 | tee -a $glb_build_log
	make install >> ${glb_log_path}/zlib.log 2>&1 || exit 1
	echo "done" 2>&1 | tee -a $glb_build_log
}


##
## Build Linux Kernel Source and Headers
##
build_kernel(){

	echo "Building Linux Kernel Headers:" 2>&1 | tee -a $glb_build_log
	
	# Go into download dir
	cd ${glb_download_path}
	
	# check if kernel source tar exist
	if [ ! -f "${glb_kernel_arch}" ]; then
		echo "*** Error *** ${glb_kernel_arch} not found!" 2>&1 | tee -a $glb_build_log
		exit 1
	fi

	# Test if Linaro kernel sources archive is not corrupted
	echo -n "md5 check of ${glb_kernel_arch}... " 2>&1 | tee -a $glb_build_log
	if [ ! $(md5 -q ${glb_download_path}/${glb_kernel_arch}) = ${glb_kernel_md5} ]; then
		echo "faild!" 2>&1 | tee -a $glb_build_log
		exit 1
	fi
	echo "passed" 2>&1 | tee -a $glb_build_log
	
	# Remove old builded kernel sources
	cd ${glb_kernel_source_path}
	if [ -d "${glb_kernel_name}" ]; then
		rm -rf ${glb_kernel_source_path}/${glb_kernel_name} 
	fi

	# Extract kernel sources
	echo -n "Extracting Kernel... " 2>&1 | tee -a $glb_build_log
	tar xjf ${glb_download_path}/${glb_kernel_arch} >> $glb_build_log 2>&1 || exit 1
	echo "done" 2>&1 | tee -a $glb_build_log
	
	# Patching 
	if [ -f "${glb_patch_path}/${glb_kernel_name}.patch" ]; then
		
		echo -n "Patching ${glb_kernel_name}... " 2>&1 | tee -a $glb_build_log
		cd ${glb_source_path}/${glb_kernel_name}
		patch --no-backup-if-mismatch -g0 -F1 -p1 -f < ${glb_patch_path}/${glb_kernel_name}.patch >> $glb_build_log
		echo "done" 2>&1 | tee -a $glb_build_log
	fi

	# Go into kernel source directory
	cd ${glb_kernel_source_path}/${glb_kernel_name}

	# Install kernel sources
	echo -n "Install Kernel... " 2>&1 | tee -a $glb_build_log
		
	make \
		-C ${glb_kernel_source_path}/${glb_kernel_name} \
		O=${glb_build_path}/build-kernel-headers \
		ARCH=arm \
		INSTALL_HDR_PATH=${glb_prefix}/arm-linux-gnueabihf/libc/usr \
		V=1 \
		headers_install >> ${glb_log_path}/kernel.log 2>&1 || exit 1

	echo "done" 2>&1 | tee -a $glb_build_log

	# Checking kernel sources
	echo -n "Checking Kernel headers... " 2>&1 | tee -a $glb_build_log
	
	make \
		-C ${glb_kernel_source_path}/${glb_kernel_name} \
		O=${glb_build_path}/build-kernel-headers \
		ARCH=arm \
		INSTALL_HDR_PATH=${glb_prefix}/arm-linux-gnueabihf/libc/usr \
		V=1 \
		headers_check >> ${glb_log_path}/kernel.log 2>&1 || exit 1
	
	echo "done" 2>&1 | tee -a $glb_build_log
}


##
## Build Binutils
##
build_binutils(){

	echo "Building Binutils:" 2>&1 | tee -a $glb_build_log
	
	# Go into download dir
	cd ${glb_download_path}
	
	# Check if binutil archive exists 
	if [ ! -f "${glb_binutils_arch}" ]; then
		echo "*** Error *** ${glb_binutils_arch} not found!" 2>&1 | tee -a $glb_build_log
		exit 1
	fi
	
	# Test if binutils archive is not corrupted
	echo -n "md5 check of ${glb_binutils_arch}... " 2>&1 | tee -a $glb_build_log
	if [ ! $(md5 -q ${glb_download_path}/${glb_binutils_arch}) = ${glb_binutils_md5} ]; then
		echo "faild!" 2>&1 | tee -a $glb_build_log
		exit 1
	fi
	echo "passed" 2>&1 | tee -a $glb_build_log

	# extract binutils if not already done
	cd ${glb_source_path}
	if [ ! -d "${glb_source_path}/${glb_binutils_name}" ]; then
		
		echo -n "Extracting Binutils... " 2>&1 | tee -a $glb_build_log
		tar xjf ${glb_download_path}/${glb_binutils_arch} >> $glb_build_log 2>&1 || exit 1
		echo "done" 2>&1 | tee -a $glb_build_log
		
		# Patching 
		if [ -f "${glb_patch_path}/${glb_binutils_name}.patch" ]; then
		
			echo -n "Patching ${glb_binutils_name}... " 2>&1 | tee -a $glb_build_log
			cd ${glb_source_path}/${glb_binutils_name}
			patch --no-backup-if-mismatch -g0 -F1 -p1 -f < ${glb_patch_path}/${glb_binutils_name}.patch >> $glb_build_log
			echo "done" 2>&1 | tee -a $glb_build_log
		fi
	else
		# remove old build
		if [ -d "${glb_source_path}/${glb_binutils_name}/build" ]; then
			rm -rf ${glb_source_path}/${glb_binutils_name}/build
		fi
	fi

	# create new build dir
	mkdir -p ${glb_source_path}/${glb_binutils_name}/build >> $glb_build_log 2>&1 || exit 1
	cd ${glb_source_path}/${glb_binutils_name}/build

	# configure Binutils
	echo -n "Configure Binutils... " 2>&1 | tee -a $glb_build_log
		
	CFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE -I${glb_build_path}/static/zlib/include" \
	CXXFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE -I${glb_build_path}/static/zlib/include" \
	LDFLAGS="-L${glb_build_path}/static/zlib/lib" \
	../configure \
		--build=$BUILD \
		--host=$BUILD \
		--target=$TARGET \
		--prefix=${glb_prefix} \
		--disable-multilib \
		--disable-werror \
		--enable-ld=default \
		--enable-gold=yes \
		--enable-threads \
		--with-pkgversion="$BUILDVERSION" \
		--with-bugurl="$BUGURL" \
		--with-float=hard \
		--with-sysroot=${glb_prefix}/arm-linux-gnueabihf/libc >> ${glb_log_path}/binutils.log 2>&1 || exit 1
	
	echo "done" 2>&1 | tee -a $glb_build_log
	
	# build binutils
	echo -n "Build Binutils... " 2>&1 | tee -a $glb_build_log
	make -j2 >> ${glb_log_path}/binutils.log 2>&1 || exit 1
	echo "done" 2>&1 | tee -a $glb_build_log
	
	# install binutils
	echo -n "Install Binutils... " 2>&1 | tee -a $glb_build_log
	make install >> ${glb_log_path}/binutils.log 2>&1 || exit 1
	echo "done" 2>&1 | tee -a $glb_build_log
	
	# install binutils
	echo -n "Install Binutils Documentation... " 2>&1 | tee -a $glb_build_log
	
	if tex_loc="$(type -p tex)" || [ -z "tex_loc" ]; then	
		
		make -j2 pdf html >> ${glb_log_path}/binutils.log
		make install-pdf-gas install-pdf-binutils install-pdf-ld install-pdf-gprof install-html-gas install-html-binutils install-html-ld install-html-gprof >> ${glb_log_path}/binutils.log
		echo "done" 2>&1 | tee -a $glb_build_log
	else
		echo "skipped - MacTeX is not installed" 2>&1 | tee -a $glb_build_log
	fi
}


##
## Extract Embedded GLIBC
##
#extract_eglibc(){
#	
#	echo "Extracting Embedded GLIBC..."
#	
#	# Go into download dir
#	cd ${glb_download_path}
#	
#	# Check if eglibc archive exists
#	if [ ! -f "${glb_eglibc_arch}" ]; then
#		echo "Error: ${glb_eglibc_arch} not found!"
#		exit 1
#	fi
#	
#	# Test if eglibc archive is not corrupted
#	echo -n "md5 check of ${glb_eglibc_arch}... "
#	if [ ! $(md5 -q ${glb_download_path}/${glb_eglibc_arch}) = ${glb_eglibc_md5} ]; then
#		echo "faild!"
#		exit 1
#	fi
#	echo "passed"
#	
#	# extract eglibc if not already done
#	cd ${glb_source_path}
#	if [ ! -d "${glb_source_path}/${glb_eglibc_name}" ]; then
#		
#		echo -n "Extracting Embedded GLIBC... "
#		tar xjf ${glb_download_path}/${glb_eglibc_arch} || exit 1
#		echo "done"
#		
#		# Patching 
#		if [ -f "${glb_patch_path}/${glb_eglibc_name}.patch" ]; then
#		
#			echo -n "Patching ${glb_eglibc_name}... "
#			cd ${glb_source_path}/${glb_eglibc_name}
#			patch --no-backup-if-mismatch -g0 -F1 -p1 -f < ${glb_patch_path}/${glb_eglibc_name}.patch
#			echo "done"
#		fi
#	fi
#}


##
## Build Embedded GLIBC
##
#build_eglibc(){
#	
#	echo "Building Embedded GLIBC..."
#	
#	echo `$TARGET-gcc --version`
#	
#	exit 0
#	
#	# Go into download dir
#	cd ${glb_download_path}
#	
#	# Check if eglibc archive exists
#	if [ ! -f "${glb_eglibc_arch}" ]; then
#		echo "Error: ${glb_eglibc_arch} not found!"
#		exit 1
#	fi
#	
#	# Test if eglibc archive is not corrupted
#	echo -n "md5 check of ${glb_eglibc_arch}... "
#	if [ ! $(md5 -q ${glb_download_path}/${glb_eglibc_arch}) = ${glb_eglibc_md5} ]; then
#		echo "faild!"
#		exit 1
#	fi
#	echo "passed"
#	
#	# extract eglibc if not already done
#	cd ${glb_source_path}
#	if [ ! -d "${glb_source_path}/${glb_eglibc_name}" ]; then
#		
#		echo -n "Extracting Embedded GLIBC... "
#		tar xjf ${glb_download_path}/${glb_eglibc_arch} || exit 1
#		echo "done"
#		
#		# Patching 
#		if [ -f "${glb_patch_path}/${glb_eglibc_name}.patch" ]; then
#		
#			echo -n "Patching ${glb_eglibc_name}... "
#			cd ${glb_source_path}/${glb_eglibc_name}
#			patch --no-backup-if-mismatch -g0 -F1 -p1 -f < ${glb_patch_path}/${glb_eglibc_name}.patch
#			echo "done"
#		fi
#	else
#		# remove old build
#		if [ -d "${glb_source_path}/${glb_eglibc_name}/build" ]; then
#			rm -rf ${glb_source_path}/${glb_eglibc_name}/build
#		fi
#	fi
#	
#	# create new build dir
#	mkdir -p ${glb_source_path}/${glb_eglibc_name}/build
#	cd ${glb_source_path}/${glb_eglibc_name}/build
#	
#	# configure eglibc 
#	echo -n "Configure Embedded GLIBC... "
#	CC=$TARGET-gcc \
#	CXX=$TARGET-g++ \
#	AR=$TARGET-ar \
#	RANLIB=$TARGET-ranlib \
#	CFLAGS="-I$PREFIX/include" \
#	LDFLAGS="-L$PREFIX/lib -L/usr/local/lib -lintl" \
#	../configure \
#		--host=$TARGET \
#		--prefix=$PREFIX \
#		--with-headers=$PREFIX/include \
#		--enable-add-ons \
#		--without-gd \
#		--without-cvs \
#		--enable-obsolete-rpc \
#		--disable-nls \
#		--with-pkgversion="$BUILDVERSION" \
#		--with-bugurl="$BUGURL" \
#		libc_cv_forced_unwind=yes || exit 1
#	# >/dev/null 2>&1 || exit 1
#	echo "done"
#	
#	# build eglibc
#	echo -n "Build Embedded GLIBC... "
#	make || exit 1
#	# >/dev/null 2>&1 || exit 1
#	echo "done"
#	
#	# install eglibc
#	echo -n "Install Embedded GLIBC... "
#	make install || exit 1
#	# >/dev/null 2>&1 || exit 1
#	echo "done"
#}


##
## Build libiconv
##
build_libiconv(){

	echo "Building libiconv..."
	
	# Go into download dir
	cd ${glb_download_path}
	
	# Check if libiconv archive exists 
	if [ ! -f "${glb_libiconv_arch}" ]; then
		echo "*** Error *** ${glb_libiconv_arch} not found!"
		exit 1
	fi
	
	# Test if libiconv archive is not corrupted
	echo -n "md5 check of ${glb_libiconv_arch}... "
	if [ ! $(md5 -q ${glb_download_path}/${glb_libiconv_arch}) = ${glb_libiconv_md5} ]; then
		echo "faild!"
		exit 1
	fi
	echo "passed"

	# extract libiconv if not already done
	cd ${glb_source_path}
	if [ ! -d "${glb_source_path}/${glb_libiconv_name}" ]; then
		
		echo -n "Extracting libiconv... "
		tar xjf ${glb_download_path}/${glb_libiconv_arch} || exit 1
		echo "done"
		
		# Patching 
		if [ -f "${glb_patch_path}/${glb_libiconv_name}.patch" ]; then
		
			echo -n "Patching ${glb_libiconv_name}... "
			cd ${glb_source_path}/${glb_libiconv_name}
			patch --no-backup-if-mismatch -g0 -F1 -p1 -f < ${glb_patch_path}/${glb_libiconv_name}.patch
			echo "done"
		fi
	else
		# remove old build
		if [ -d "${glb_source_path}/${glb_libiconv_name}/build" ]; then
			rm -rf ${glb_source_path}/${glb_libiconv_name}/build
		fi
	fi

	# create new build dir
	mkdir -p ${glb_source_path}/${glb_libiconv_name}/build || exit 1
	cd ${glb_source_path}/${glb_libiconv_name}/build

	# configure libiconv
	echo -n "Configure libiconv... "
	../configure \
		--prefix=$PREFIX \
		--disable-shared  || exit 1
	# >/dev/null 2>&1 || exit 1
	echo "done"
	
	# build libiconv
	echo -n "Build libiconv... "
	make || exit 1
	# >/dev/null 2>&1 || exit 1
	echo "done"
	
	# install libiconv
	echo -n "Install libiconv... "
	make install || exit 1
	# >/dev/null 2>&1 || exit 1
	echo "done"
}


##
## Build gcc part 1 - static core C compiler
##
build_gcc1(){

	echo "Building static core C compiler:" 2>&1 | tee -a $glb_build_log

	# Go into download dir
	cd ${glb_download_path}
	
	# Check if gcc archive exists 
	if [ ! -f "${glb_gcc_arch}" ]; then
		echo "Error: ${glb_gcc_arch} not found!" 2>&1 | tee -a $glb_build_log
		exit 1
	fi
	
	# Test if gcc archive is not corrupted
	echo -n "md5 check of ${glb_gcc_arch}... " 2>&1 | tee -a $glb_build_log
	if [ ! $(md5 -q ${glb_download_path}/${glb_gcc_arch}) = ${glb_gcc_md5} ]; then
		echo "faild!" 2>&1 | tee -a $glb_build_log
		exit 1
	fi
	echo "passed" 2>&1 | tee -a $glb_build_log
	
	# extract gcc if not already done
	cd ${glb_source_path}
	if [ ! -d "${glb_source_path}/${glb_gcc_name}" ]; then
		
		echo -n "Extracting GCC... " 2>&1 | tee -a $glb_build_log
		tar xjf ${glb_download_path}/${glb_gcc_arch} >> $glb_build_log 2>&1 || exit 1
		echo "done" 2>&1 | tee -a $glb_build_log
		
		# Patching 
		if [ -f "${glb_patch_path}/${glb_gcc_name}.patch" ]; then
		
			echo -n "Patching ${glb_gcc_name}... " 2>&1 | tee -a $glb_build_log
			cd ${glb_source_path}/${glb_gcc_name}
			patch --no-backup-if-mismatch -g0 -F1 -p1 -f < ${glb_patch_path}/${glb_gcc_name}.patch >> $glb_build_log
			echo "done" 2>&1 | tee -a $glb_build_log
		fi
	else
		# remove old build
		if [ -d "${glb_source_path}/${glb_gcc_name}/build1" ]; then
			rm -rf ${glb_source_path}/${glb_gcc_name}/build1
		fi
	fi
	
	# get libc headers 
	mkdir -p ${glb_build_path}/gcc-core-static/arm-linux-gnueabihf/include >> $glb_build_log 2>&1 || exit 1
	cp -a \
		${glb_prefix}/arm-linux-gnueabihf/libc/usr/include \
		${glb_build_path}/gcc-core-static/arm-linux-gnueabihf >> $glb_build_log 2>&1 || exit 1

	# create new build dir
	mkdir -p ${glb_source_path}/${glb_gcc_name}/build1
	cd ${glb_source_path}/${glb_gcc_name}/build1
	
	# Configure gcc part 1
	echo -n "Configure static core C... " 2>&1 | tee -a $glb_build_log

	CC_FOR_BUILD="${glb_cc}" \
	CFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE" \
	LDFLAGS="-lstdc++ -lm" \
	../configure \
		--build=$BUILD \
		--host=$BUILD \
		--target=$TARGET \
		--prefix=${glb_build_path}/gcc-core-static \
		--with-local-prefix=${glb_prefix}/arm-linux-gnueabihf/libc \
		--disable-libmudflap \
		--with-sysroot=${glb_prefix}/arm-linux-gnueabihf/libc \
		--with-newlib \
		--enable-threads=no \
		--disable-shared \
		--with-pkgversion="$BUILDVERSION" \
		--with-bugurl="$BUGURL" \
		--with-arch=armv7-a \
		--with-tune=cortex-a9 \
		--with-fpu=vfpv3-d16 \
		--with-float=hard \
		--enable-__cxa_atexit \
		--with-gmp=${glb_build_path}/static \
		--with-mpfr=${glb_build_path}/static \
		--with-mpc=${glb_build_path}/static \
		--with-isl=${glb_build_path}/static \
		--with-cloog=${glb_build_path}/static \
		--with-libelf=${glb_build_path}/static \
		--enable-lto \
		--enable-linker-build-id \
		--disable-libgomp \
		--disable-libmudflap \
		--disable-libstdcxx-pch \
		--enable-multilib \
		--enable-languages=c \
		--with-mode=thumb >> ${glb_log_path}/gcc1.log 2>&1 || exit 1
	
	echo "done" 2>&1 | tee -a $glb_build_log
	
	# Build static gcc 
	echo -n "Build static GCC... " 2>&1 | tee -a $glb_build_log
	#make all-gcc all-target-libgcc >> ${glb_log_path}/gcc1.log 2>&1 || exit 1
	make all-gcc >> ${glb_log_path}/gcc1.log 2>&1 || exit 1
	echo "done" 2>&1 | tee -a $glb_build_log
	
	# Install static gcc
	echo -n "Install static GCC... " 2>&1 | tee -a $glb_build_log
	make install-gcc >> ${glb_log_path}/gcc1.log 2>&1 || exit 1
	ln -sf \
		${glb_build_path}/gcc-core-static/bin/arm-linux-gnueabihf-gcc  \
		${glb_build_path}/gcc-core-static/bin/arm-linux-gnueabihf-cc 
	echo "done" 2>&1 | tee -a $glb_build_log
}


##
## Build gcc part 2 - shared core C compiler
##
build_gcc2(){
	
	echo "Building shared core C compiler:" 2>&1 | tee -a $glb_build_log
	
	# Check if gcc part 1 has extracted gcc archive
	if [ -d "${glb_source_path}/${glb_gcc_name}" ]; then
		
		# remove old build
		if [ -d "${glb_source_path}/${glb_gcc_name}/build2" ]; then
			rm -rf ${glb_source_path}/${glb_gcc_name}/build2
		fi
		
		# create new build dir
		mkdir -p ${glb_source_path}/${glb_gcc_name}/build2
		cd ${glb_source_path}/${glb_gcc_name}/build2
		
		# configure gcc part 2
		echo -n "Configure GCC part 2... " 2>&1 | tee -a $glb_build_log
		
		# get libc 
		mkdir -p ${glb_build_path}/gcc-core-shared/arm-linux-gnueabihf/include >> $glb_build_log 2>&1 || exit 1
		cp -a \
			${glb_prefix}/arm-linux-gnueabihf/libc/usr/include \
			${glb_build_path}/gcc-core-shared/arm-linux-gnueabihf >> $glb_build_log 2>&1 || exit 1

		CC_FOR_BUILD="${glb_cc}" \
		CFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE" \
		LDFLAGS="-lstdc++ -lm" \
		../configure \
			--build=$BUILD \
			--host=$BUILD \
			--target=$TARGET \
			--prefix=${glb_build_path}/gcc-core-shared \
			--with-local-prefix=${glb_prefix}/arm-linux-gnueabihf/libc \
			--disable-libmudflap \
			--with-sysroot=${glb_prefix}/arm-linux-gnueabihf/libc \
			--enable-shared \
			--with-pkgversion="$BUILDVERSION" \
			--with-bugurl="$BUGURL" \
			--with-arch=armv7-a \
			--with-tune=cortex-a9 \
			--with-fpu=vfpv3-d16 \
			--with-float=hard \
			--enable-__cxa_atexit \
			--with-gmp=${glb_build_path}/static \
			--with-mpfr=${glb_build_path}/static \
			--with-mpc=${glb_build_path}/static \
			--with-isl=${glb_build_path}/static \
			--with-cloog=${glb_build_path}/static \
			--with-libelf=${glb_build_path}/static \
			--enable-lto \
			--enable-linker-build-id \
			--disable-libgomp \
			--disable-libmudflap \
			--disable-libstdcxx-pch \
			--enable-multilib \
			--enable-languages=c \
			--with-mode=thumb >> ${glb_log_path}/gcc2.log 2>&1 || exit 1

		echo "done" 2>&1 | tee -a $glb_build_log
		
		# build gcc part 2
		echo -n "Build GCC part 2... " 2>&1 | tee -a $glb_build_log
		
		make configure-gcc configure-libcpp configure-build-libiberty >> ${glb_log_path}/gcc2.log 2>&1 || exit 1
		make all-libcpp all-build-libiberty >> ${glb_log_path}/gcc2.log 2>&1 || exit 1
		make configure-libbacktrace >> ${glb_log_path}/gcc2.log 2>&1 || exit 1
		make -C libbacktrace all >> ${glb_log_path}/gcc2.log 2>&1 || exit 1
		make configure-libdecnumber >> ${glb_log_path}/gcc2.log 2>&1 || exit 1
		make -C libdecnumber libdecnumber.a >> ${glb_log_path}/gcc2.log 2>&1 || exit 1
		make -C gcc libgcc.mvars >> ${glb_log_path}/gcc2.log 2>&1 || exit 1
		make all-gcc all-target-libgcc >> ${glb_log_path}/gcc2.log 2>&1 || exit 1
		
		echo "done" 2>&1 | tee -a $glb_build_log
		
		# install gcc part 2
		echo -n "Install GCC part 2... " 2>&1 | tee -a $glb_build_log
		make install-gcc install-target-libgcc >> ${glb_log_path}/gcc2.log 2>&1 || exit 1
		ln -sf \
			${glb_build_path}/gcc-core-shared/bin/arm-linux-gnueabihf-gcc  \
			${glb_build_path}/gcc-core-shared/bin/arm-linux-gnueabihf-cc 2>&1 | tee -a $glb_build_log
		make all >> ${glb_log_path}/gcc2.log 2>&1 || exit 1
		echo "done"  2>&1 | tee -a $glb_build_log
				
	else
		echo "Error: ${glb_download_path}/${glb_gcc_arch} not found" 2>&1 | tee -a $glb_build_log
	fi
}


##
## Build gcc part 3
##
build_gcc3(){
	
	echo "Building final compiler:" 2>&1 | tee -a $glb_build_log
	
	# Check if gcc part 1 has extracted gcc archive
	if [ -d "${glb_source_path}/${glb_gcc_name}" ]; then
		
		# remove old build
		if [ -d "${glb_source_path}/${glb_gcc_name}/build3" ]; then
			rm -rf ${glb_source_path}/${glb_gcc_name}/build3
		fi
		
		# create new build dir
		mkdir -p ${glb_source_path}/${glb_gcc_name}/build3
		cd ${glb_source_path}/${glb_gcc_name}/build3
		
		# configure gcc part 3
		echo -n "Configure final compiler... " 2>&1 | tee -a $glb_build_log
		
		CC_FOR_BUILD=${glb_cc} \
		CFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE" \
		LDFLAGS="-lstdc++ -lm" \
		CXXFLAGS_FOR_TARGET="-mlittle-endian -march=armv7-a   -mtune=cortex-a9 -mfpu=vfpv3-d16 -mhard-float -g -O2" \
		LDFLAGS_FOR_TARGET="-Wl,-EL" \
		../configure \
			--build=$BUILD \
			--host=$BUILD \
			--target=$TARGET \
			--prefix=${glb_prefix} \
			--with-sysroot=${glb_prefix}/arm-linux-gnueabihf/libc \
			--enable-languages=c,c++,fortran \
			--enable-multilib \
			--with-arch=armv7-a \
			--with-tune=cortex-a9 \
			--with-fpu=vfpv3-d16 \
			--with-float=hard \
			--with-pkgversion="$BUILDVERSION" \
			--with-bugurl="$BUGURL" \
			--enable-__cxa_atexit \
			--enable-libmudflap \
			--enable-libgomp \
			--enable-libssp \
			--with-gmp=${glb_build_path}/static \
			--with-mpfr=${glb_build_path}/static \
			--with-mpc=${glb_build_path}/static \
			--with-isl=${glb_build_path}/static \
			--with-cloog=${glb_build_path}/static \
			--with-libelf=${glb_build_path}/static \
			--enable-threads=posix \
			--disable-libstdcxx-pch \
			--enable-linker-build-id \
			--enable-gold \
			--with-local-prefix=${glb_prefix}/arm-linux-gnueabihf/libc \
			--enable-c99 \
			--enable-long-long \
			--with-mode=thumb >> ${glb_log_path}/gcc3.log 2>&1 || exit 1
		
		echo "done" 2>&1 | tee -a $glb_build_log
		
		# build gcc part 3
		echo -n "Build final compiler... " 2>&1 | tee -a $glb_build_log
		make all >> ${glb_log_path}/gcc3.log 2>&1 || exit 1
		echo "done" 2>&1 | tee -a $glb_build_log
		
		# install gcc part 3
		echo -n "Install final compiler... "
		make install >> ${glb_log_path}/gcc3.log 2>&1 || exit 1
		echo "done" 2>&1 | tee -a $glb_build_log
		
		# install gcc part 3 docu 
		echo -n "Install compiler documentation... " 2>&1 | tee -a $glb_build_log
	
		if tex_loc="$(type -p tex)" || [ -z "tex_loc" ]; then	
		
			make pdf html >> ${glb_log_path}/gcc3.log
			make install-pdf-gcc install-html-gcc >> ${glb_log_path}/gcc3.log
			echo "done" 2>&1 | tee -a $glb_build_log
		else
			echo "skipped - MacTeX is not installed" 2>&1 | tee -a $glb_build_log
		fi
		
		ln -sf \
			${glb_prefix}/bin/arm-linux-gnueabihf-gcc \
			${glb_prefix}/bin/arm-linux-gnueabihf-cc 2>&1 | tee -a $glb_build_log
				
	else
		echo "Error: ${glb_download_path}/${glb_gcc_arch} not found" 2>&1 | tee -a $glb_build_log
	fi
}


##
## Build eXpat
##
build_expat(){

	echo "Building eXpat..." 2>&1 | tee -a $glb_build_log
	
	# Go into download dir
	cd ${glb_download_path}
	
	# Check if expat archive exists 
	if [ ! -f "${glb_expat_arch}" ]; then
		echo "*** Error *** ${glb_expat_arch} not found!" 2>&1 | tee -a $glb_build_log
		exit 1
	fi
	
	# Test if expat archive is not corrupted
	echo -n "md5 check of ${glb_expat_arch}... " 2>&1 | tee -a $glb_build_log
	if [ ! $(md5 -q ${glb_download_path}/${glb_expat_arch}) = ${glb_expat_md5} ]; then
		echo "faild!" 2>&1 | tee -a $glb_build_log
		exit 1
	fi
	echo "passed" 2>&1 | tee -a $glb_build_log

	# extract expat if not already done
	cd ${glb_source_path}
	if [ ! -d "${glb_source_path}/${glb_expat_name}" ]; then
		
		echo -n "Extracting eXpat... " 2>&1 | tee -a $glb_build_log
		tar xjf ${glb_download_path}/${glb_expat_arch} >> $glb_build_log 2>&1 || exit 1
		echo "done" 2>&1 | tee -a $glb_build_log
		
		# Patching 
		if [ -f "${glb_patch_path}/${glb_expat_name}.patch" ]; then
		
			echo -n "Patching ${glb_expat_name}... " 2>&1 | tee -a $glb_build_log
			cd ${glb_source_path}/${glb_expat_name}
			patch --no-backup-if-mismatch -g0 -F1 -p1 -f < ${glb_patch_path}/${glb_expat_name}.patch >> $glb_build_log
			echo "done" 2>&1 | tee -a $glb_build_log
		fi
	else
		# remove old build
		if [ -d "${glb_source_path}/${glb_expat_name}/build" ]; then
			rm -rf ${glb_source_path}/${glb_expat_name}/build
		fi
	fi

	# create new build dir
	mkdir -p ${glb_source_path}/${glb_expat_name}/build >> $glb_build_log 2>&1 || exit 1
	cd ${glb_source_path}/${glb_expat_name}/build

	# configure eXpat
	echo -n "Configure eXpat... " 2>&1 | tee -a $glb_build_log

	../configure \
		--build=$BUILD \
		--host=$BUILD \
		--target=$TARGET \
		--prefix=${glb_build_path}/static \
		--enable-static \
		--disable-shared >> ${glb_log_path}/expat.log 2>&1 || exit 1

	echo "done" 2>&1 | tee -a $glb_build_log
	
	# build expat
	echo -n "Build eXpat... " 2>&1 | tee -a $glb_build_log
	make >> ${glb_log_path}/expat.log 2>&1 || exit 1
	echo "done" 2>&1 | tee -a $glb_build_log
	
	# install expat
	echo -n "Install eXpat... " 2>&1 | tee -a $glb_build_log
	make install >> ${glb_log_path}/expat.log 2>&1 || exit 1
	echo "done" 2>&1 | tee -a $glb_build_log
}


##
## Build ncurses
##
build_ncurses(){

	echo "Building ncurses:" 2>&1 | tee -a $glb_build_log
	
	# Go into download dir
	cd ${glb_download_path}
	
	# Check if ncurses archive exists 
	if [ ! -f "${glb_ncurses_arch}" ]; then
		echo "*** Error *** ${glb_ncurses_arch} not found!" 2>&1 | tee -a $glb_build_log
		exit 1
	fi
	
	# Test if ncurses archive is not corrupted
	echo -n "md5 check of ${glb_ncurses_arch}... " 2>&1 | tee -a $glb_build_log
	if [ ! $(md5 -q ${glb_download_path}/${glb_ncurses_arch}) = ${glb_ncurses_md5} ]; then
		echo "faild!" 2>&1 | tee -a $glb_build_log
		exit 1
	fi
	echo "passed" 2>&1 | tee -a $glb_build_log

	# extract ncurses if not already done
	cd ${glb_source_path}
	if [ ! -d "${glb_source_path}/${glb_ncurses_name}" ]; then
		
		echo -n "Extracting ncurses... " 2>&1 | tee -a $glb_build_log
		tar xjf ${glb_download_path}/${glb_ncurses_arch} >> $glb_build_log 2>&1 || exit 1
		echo "done" 2>&1 | tee -a $glb_build_log
		
		# Patching 
		if [ -f "${glb_patch_path}/${glb_ncurses_name}.patch" ]; then
		
			echo -n "Patching ${glb_ncurses_name}... " >> $glb_build_log 2>&1 || exit 1
			cd ${glb_source_path}/${glb_ncurses_name}
			patch --no-backup-if-mismatch -g0 -F1 -p1 -f < ${glb_patch_path}/${glb_ncurses_name}.patch >> $glb_build_log
			echo "done" >> $glb_build_log 2>&1 || exit 1
		fi
	else
		# remove old build
		if [ -d "${glb_source_path}/${glb_ncurses_name}/build" ]; then
			rm -rf ${glb_source_path}/${glb_ncurses_name}/build
		fi
	fi

	# create new build dir
	mkdir -p ${glb_source_path}/${glb_ncurses_name}/build >> $glb_build_log 2>&1 || exit 1
	cd ${glb_source_path}/${glb_ncurses_name}/build

	# configure ncurses
	echo -n "Configure ncurses... " >> $glb_build_log 2>&1 || exit 1

	CC="${glb_cc}" \
	../configure \
		--build=$BUILD \
		--host=$BUILD \
		--target=$TARGET \
		--prefix=${glb_build_path}/static \
		--disable-shared \
		--enable-static \
		--without-ada >> ${glb_log_path}/ncurses.log 2>&1 || exit 1

	echo "done" >> $glb_build_log 2>&1 || exit 1
	
	# build ncurses
	echo -n "Build ncurses... " >> $glb_build_log 2>&1 || exit 1
	make >> ${glb_log_path}/ncurses.log 2>&1 || exit 1
	echo "done" 
	
	# install ncurses
	echo -n "Install ncurses... " >> $glb_build_log 2>&1 || exit 1
	make install >> ${glb_log_path}/ncurses.log 2>&1 || exit 1
	echo "done" >> $glb_build_log 2>&1 || exit 1
}


##
## Build gdb
##
build_gdb(){

	echo "Building gdb:" 2>&1 | tee -a $glb_build_log
	
	# Go into download dir
	cd ${glb_download_path}

	# Check if gdb archive exists 
	if [ ! -f "${glb_gdb_arch}" ]; then
		echo "*** Error *** ${glb_gdb_arch} not found!" 2>&1 | tee -a $glb_build_log
		exit 1 2>&1 | tee -a $glb_build_log
	fi
	
	# Test if gdb archive is not corrupted
	echo -n "md5 check of ${glb_gdb_arch}... "
	if [ ! $(md5 -q ${glb_download_path}/${glb_gdb_arch}) = ${glb_gdb_md5} ]; then 2>&1 | tee -a $glb_build_log
		echo "faild!" 2>&1 | tee -a $glb_build_log
		exit 1
	fi
	echo "passed" 2>&1 | tee -a $glb_build_log

	# extract gdb if not already done
	cd ${glb_source_path}
	if [ ! -d "${glb_source_path}/${glb_gdb_name}" ]; then
		echo -n "Extracting gdb... " 2>&1 | tee -a $glb_build_log
		tar xjf ${glb_download_path}/${glb_gdb_arch} >> $glb_build_log 2>&1 || exit 1
		echo "done" 2>&1 | tee -a $glb_build_log
		
		# Patching 
		if [ -f "${glb_patch_path}/${glb_gdb_name}.patch" ]; then
			
			echo -n "Patching ${glb_gdb_name}... " 2>&1 | tee -a $glb_build_log
			cd ${glb_source_path}/${glb_gdb_name}
			patch --no-backup-if-mismatch -g0 -F1 -p1 -f < ${glb_patch_path}/${glb_gdb_name}.patch >> $glb_build_log
			echo "done" 2>&1 | tee -a $glb_build_log
		fi
	else
		# remove old build
		if [ -d "${glb_source_path}/${glb_gdb_name}/build" ]; then
			rm -rf ${glb_source_path}/${glb_gdb_name}/build
		fi
	fi

	# create new build dir
	mkdir -p ${glb_source_path}/${glb_gdb_name}/build >> $glb_build_log 2>&1 || exit 1
	cd ${glb_source_path}/${glb_gdb_name}/build

	# configure gdb
	echo -n "Configure gdb... " 2>&1 | tee -a $glb_build_log
	
	CC="" \
	LD="" \
	CFLAGS="-O2 -g -pipe -fno-stack-protector -U_FORTIFY_SOURCE -I${glb_build_path}/static/zlib/include" \
	LDFLAGS="-L${glb_build_path}/static/lib -L${glb_build_path}/static/zlib/lib" \
	../configure \
		--build=$BUILD \
		--host=$BUILD \
		--target=$TARGET \
		--prefix=${glb_prefix} \
		--with-build-sysroot=${glb_prefix}/arm-linux-gnueabihf/libc \
		--with-sysroot=${glb_prefix}/arm-linux-gnueabihf/libc \
		--with-expat=yes \
		--disable-werror \
		--with-pkgversion="$BUILDVERSION" \
		--with-bugurl="$BUGURL" \
		--enable-threads \
		--with-python=no \
		--with-libexpat-prefix=${glb_build_path}/static \
		--disable-sim >> ${glb_log_path}/gdb.log 2>&1 || exit 1
	
	echo "done" 2>&1 | tee -a $glb_build_log
	
	# build gdb
	echo -n "Build gdb... " 2>&1 | tee -a $glb_build_log
	make -j2 >> ${glb_log_path}/gdb.log 2>&1 || exit 1
	echo "done"  2>&1 | tee -a $glb_build_log

	echo -n "Install gdb... " 2>&1 | tee -a $glb_build_log
	make install >> ${glb_log_path}/gdb.log 2>&1 || exit 1
	echo "done" 2>&1 | tee -a $glb_build_log
	
	# install gdb docu 
	echo -n "Install gdb documentation... " 2>&1 | tee -a $glb_build_log

	if tex_loc="$(type -p tex)" || [ -z "tex_loc" ]; then	
		make -j2 pdf html  >> ${glb_log_path}/gdb.log
		make install-pdf-gdb install-html-gdb >> ${glb_log_path}/gdb.log
		echo "done" 2>&1 | tee -a $glb_build_log
	else
		echo "skipped - MacTeX is not installed" 2>&1 | tee -a $glb_build_log
	fi
}


##
## Build pkgconf
##
build_pkgconf(){

	echo "Building pkgconf:" 2>&1 | tee -a $glb_build_log
	
	# Go into download dir
	cd ${glb_download_path}

	# Check if pkg-config archive exists 
	if [ ! -f "${glb_pkgconf_arch}" ]; then
		echo "*** Error *** ${glb_pkgconf_arch} not found!" 2>&1 | tee -a $glb_build_log
		exit 1
	fi
	
	# Test if pkg-config archive is not corrupted
	echo -n "md5 check of ${glb_pkgconf_arch}... " 2>&1 | tee -a $glb_build_log
	if [ ! $(md5 -q ${glb_download_path}/${glb_pkgconf_arch}) = ${glb_pkgconf_md5} ]; then
		echo "faild!" 2>&1 | tee -a $glb_build_log
		exit 1
	fi
	echo "passed" 2>&1 | tee -a $glb_build_log

	# extract pkg-config if not already done
	cd ${glb_source_path}
	if [ ! -d "${glb_source_path}/${glb_pkgconf_name}" ]; then
		echo -n "Extracting pkgconf... " 2>&1 | tee -a $glb_build_log
		tar xjf ${glb_download_path}/${glb_pkgconf_arch} >> $glb_build_log 2>&1 || exit 1
		echo "done" 2>&1 | tee -a $glb_build_log
		
		# Patching 
		if [ -f "${glb_patch_path}/${glb_pkgconf_name}.patch" ]; then
			
			echo -n "Patching ${glb_pkgconf_name}... " 2>&1 | tee -a $glb_build_log
			cd ${glb_source_path}/${glb_pkgconf_name}
			patch --no-backup-if-mismatch -g0 -F1 -p1 -f < ${glb_patch_path}/${glb_pkgconf_name}.patch >> $glb_build_log
			echo "done" 2>&1 | tee -a $glb_build_log
		fi
	else
		# remove old build
		if [ -d "${glb_source_path}/${glb_pkgconf_name}/build" ]; then
			rm -rf ${glb_source_path}/${glb_pkgconf_name}/build
		fi
	fi

	# create new build dir
	mkdir -p ${glb_source_path}/${glb_pkgconf_name}/build >> $glb_build_log 2>&1 || exit 1
	cd ${glb_source_path}/${glb_pkgconf_name}/build

	# configure pkgconf
	echo -n "Configure pkg-config... " 2>&1 | tee -a $glb_build_log
	
	../configure \
		--prefix=${glb_prefix} \
		--build=$BUILD \
		--host=$BUILD \
		--program-prefix=$TARGET- \
		--program-suffix=-real \
		--with-pc-path="${glb_prefix}/arm-linux-gnueabihf/libc/usr/lib/arm-linux-gnueabihf/pkgconfig:${glb_prefix}/arm-linux-gnueabihf/libc/usr/lib//pkgconfig:${glb_prefix}/arm-linux-gnueabihf/libc/usr/share/pkgconfig" >> ${glb_log_path}/pkgconf.log 2>&1 || exit 1

	echo "done" 2>&1 | tee -a $glb_build_log
	
	# build pkg-config
	echo -n "Build pkg-config... " 2>&1 | tee -a $glb_build_log
	make >> ${glb_log_path}/pkgconf.log 2>&1 || exit 1
	echo "done"  2>&1 | tee -a $glb_build_log

	echo -n "Install pkg-config... "
	make install >> ${glb_log_path}/pkgconf.log 2>&1 || exit 1
	echo "done" 2>&1 | tee -a $glb_build_log
}