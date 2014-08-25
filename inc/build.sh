#!/bin/bash

# Build Linux Kernel Source and Headers
build_kernel(){

	echo "Building Linux Kernel Source and Headers..." 2>&1 | tee -a ${glb_log_build}
	
	cd ${glb_download_path}
	
	# check if kernel source tar exist
	if [ ! -f "${glb_kernel_arch}" ]; then
		echo "Error: ${glb_kernel_arch} not found!" 2>&1 | tee -a ${glb_log_build}
		exit 1
	fi

	echo -n "md5 check of ${glb_kernel_arch}... " 2>&1 | tee -a ${glb_log_build}
	if [ ! $(md5 -q ${glb_download_path}/${glb_kernel_arch}) = ${glb_kernel_md5} ]; then
		echo "faild!" 2>&1 | tee -a ${glb_log_build}
		exit 1
	fi
	echo "passed" 2>&1 | tee -a ${glb_log_build}

	cd ${glb_source_path}
	if [ -d "${glb_kernel_name}" ]; then
		rm -rf ${glb_source_path}/${glb_kernel_name} 
	fi

	echo -n "Extracting Kernel... " 2>&1 | tee -a ${glb_log_build}
	tar xjf ${glb_download_path}/${glb_kernel_arch} || exit 1
	echo "done" 2>&1 | tee -a ${glb_log_build}

	cd ${glb_source_path}/${glb_kernel_name}

	echo -n "Configure Kernel... " 2>&1 | tee -a ${glb_log_build}
	make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabihf- defconfig >/dev/null 2>&1 | tee -a ${glb_log_build} || exit 1
	echo "done" 2>&1 | tee -a ${glb_log_build}
	
	echo -n "Install Kernel headers... " 2>&1 | tee -a ${glb_log_build}
	make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabihf- headers_install >/dev/null 2>&1 | tee -a ${glb_log_build} || exit 1
	cp -r ${glb_source_path}/${glb_kernel_name}/usr/include ${glb_build_path} || exit 1
	echo "done" 2>&1 | tee -a ${glb_log_build}

	cd ${glb_disk_image_path}
}

# Build Binutils
build_binutils(){

	echo "Building Binutils..." 2>&1 | tee -a ${glb_log_build}
	
	cd ${glb_download_path}
	
	if [ ! -f "${glb_binutils_arch}" ]; then
		echo "Error: ${glb_binutils_arch} not found!" 2>&1 | tee -a ${glb_log_build}
		exit 1
	fi

	echo -n "md5 check of ${glb_binutils_arch}... " 2>&1 | tee -a ${glb_log_build}
	if [ ! $(md5 -q ${glb_download_path}/${glb_binutils_arch}) = ${glb_binutils_md5} ]; then
		echo "faild!" 2>&1 | tee -a ${glb_log_build}
		exit 1
	fi
	echo "passed" 2>&1 | tee -a ${glb_log_build}

	cd ${glb_source_path}
	if [ ! -d "${glb_source_path}/${glb_binutils_name}" ]; then
		echo -n "Extracting Binutils... " 2>&1 | tee -a ${glb_log_build}
		tar xjf ${glb_download_path}/${glb_binutils_arch} || exit 1
		echo "done" 2>&1 | tee -a ${glb_log_build}
	else
		if [ -d "${glb_source_path}/${glb_binutils_name}/build" ]; then
			rm -rf ${glb_source_path}/${glb_binutils_name}/build
		fi
	fi

	mkdir -p ${glb_source_path}/${glb_binutils_name}/build
	cd ${glb_source_path}/${glb_binutils_name}/build

	echo -n "Configure Binutils... " 2>&1 | tee -a ${glb_log_build}
	../configure --target=$TARGET --prefix=$PREFIX \
		--disable-werror --disable-nls --disable-gdb --disable-libdecnumber \
		--disable-readline --disable-sim --enable-plugins --enable-poison-system-directories \
		>/dev/null 2>&1 | tee -a ${glb_log_build} || exit 1
	echo "done" 2>&1 | tee -a ${glb_log_build}
	
	echo -n "Build Binutils... " 2>&1 | tee -a ${glb_log_build}
	make >/dev/null >/dev/null 2>&1 | tee -a ${glb_log_build} || exit 1
	echo "done" 2>&1 | tee -a ${glb_log_build}
	
	echo -n "Install Binutils... " 2>&1 | tee -a ${glb_log_build}
	make install >/dev/null >/dev/null 2>&1 | tee -a ${glb_log_build} || exit 1
	echo "done" 2>&1 | tee -a ${glb_log_build}
	
	cd ${glb_disk_image_path}
}

# Build gcc part 1
build_gcc1(){

	echo "Building GCC Part 1..." 2>&1 | tee -a ${glb_log_build}
	
	cd ${glb_download_path}
	
	if [ ! -f "${glb_gcc_arch}" ]; then
		echo "Error: ${glb_gcc_arch} not found!" 2>&1 | tee -a ${glb_log_build}
		exit 1
	fi
	
	echo -n "md5 check of ${glb_gcc_arch}... " 2>&1 | tee -a ${glb_log_build}
	if [ ! $(md5 -q ${glb_download_path}/${glb_gcc_arch}) = ${glb_gcc_md5} ]; then
		echo "faild!" 2>&1 | tee -a ${glb_log_build}
		exit 1
	fi
	echo "passed" 2>&1 | tee -a ${glb_log_build}
	
	cd ${glb_source_path}
	if [ ! -d "${glb_source_path}/${glb_gcc_name}" ]; then
		echo -n "Extracting GCC... " 2>&1 | tee -a ${glb_log_build}
		tar xjf ${glb_download_path}/${glb_gcc_arch} || exit 1
		echo "done" 2>&1 | tee -a ${glb_log_build}
	else
		if [ -d "${glb_source_path}/${glb_gcc_name}/build1" ]; then
			rm -rf ${glb_source_path}/${glb_gcc_name}/build1
		fi
	fi
	
	cd ${glb_download_path}
	
	if [ ! -f "${glb_mpfr_arch}" ]; then
		echo "Error: ${glb_mpfr_arch} not found!" 2>&1 | tee -a ${glb_log_build}
		exit 1
	fi
	
	echo -n "md5 check of ${glb_mpfr_arch}... " 2>&1 | tee -a ${glb_log_build}
	if [ ! $(md5 -q ${glb_download_path}/${glb_mpfr_arch}) = ${glb_mpfr_md5} ]; then
		echo "faild!" 2>&1 | tee -a ${glb_log_build}
		exit 1
	fi
	echo "passed" 2>&1 | tee -a ${glb_log_build}
	
	cd ${glb_source_path}/${glb_gcc_name}/
	if [ ! -d "${glb_source_path}/${glb_gcc_name}/${glb_mpfr_name}" ]; then
		echo -n "Extracting MPFR... " 2>&1 | tee -a ${glb_log_build}
		tar xjf ${glb_download_path}/${glb_mpfr_arch} || exit 1
		ln -sf ${glb_mpfr_name} mpfr || exit 1
		echo "done" 2>&1 | tee -a ${glb_log_build}
	fi
	
	
	cd ${glb_download_path}
	
	if [ ! -f "${glb_gmp_arch}" ]; then
		echo "Error: ${glb_gmp_arch} not found!" 2>&1 | tee -a ${glb_log_build}
		exit 1
	fi
	
	echo -n "md5 check of ${glb_gmp_arch}... " 2>&1 | tee -a ${glb_log_build}
	if [ ! $(md5 -q ${glb_download_path}/${glb_gmp_arch}) = ${glb_gmp_md5} ]; then
		echo "faild!" 2>&1 | tee -a ${glb_log_build}
		exit 1
	fi
	echo "passed" 2>&1 | tee -a ${glb_log_build}
	
	cd ${glb_source_path}/${glb_gcc_name}/
	if [ ! -d "${glb_source_path}/${glb_gcc_name}/${glb_gmp_name}" ]; then
		echo -n "Extracting GMP... " 2>&1 | tee -a ${glb_log_build}
		tar xjf ${glb_download_path}/${glb_gmp_arch} || exit 1
		ln -sf ${glb_gmp_name} gmp || exit 1
		echo "done" 2>&1 | tee -a ${glb_log_build}
	fi	
	
	
	cd ${glb_download_path}
	
	if [ ! -f "${glb_mpc_arch}" ]; then
		echo "Error: ${glb_mpc_arch} not found!" 2>&1 | tee -a ${glb_log_build}
		exit 1
	fi
	
	echo -n "md5 check of ${glb_mpc_arch}... " 2>&1 | tee -a ${glb_log_build}
	if [ ! $(md5 -q ${glb_download_path}/${glb_mpc_arch}) = ${glb_mpc_md5} ]; then
		echo "faild!" 2>&1 | tee -a ${glb_log_build}
		exit 1
	fi
	echo "passed" 2>&1 | tee -a ${glb_log_build}
	
	cd ${glb_source_path}/${glb_gcc_name}/
	if [ ! -d "${glb_source_path}/${glb_gcc_name}/${glb_mpc_name}" ]; then
		echo -n "Extracting MPC... " 2>&1 | tee -a ${glb_log_build}
		tar xjf ${glb_download_path}/${glb_mpc_arch} || exit 1 
		ln -sf ${glb_mpc_name} mpc || exit 1
		echo "done" 2>&1 | tee -a ${glb_log_build}
	fi	
	
	
	mkdir -p ${glb_source_path}/${glb_gcc_name}/build1
	cd ${glb_source_path}/${glb_gcc_name}/build1
	
	echo -n "Configure GCC part 1... " 2>&1 | tee -a ${glb_log_build}
	../configure --target=$TARGET --prefix=$PREFIX --disable-threads \
		--disable-shared --with-newlib --disable-multilib --with-local-prefix=$PREFIX \
		--disable-nls --without-headers --enable-languages=c,c++ >/dev/null 2>&1 | tee -a ${glb_log_build} || exit 1

	echo "done" 2>&1 | tee -a ${glb_log_build}
	
	echo -n "Build GCC part 1... " 2>&1 | tee -a ${glb_log_build}
	make all-gcc all-target-libgcc >/dev/null 2>&1 | tee -a ${glb_log_build} || exit 1 
	echo "done" 2>&1 | tee -a ${glb_log_build}
	
	echo -n "Install GCC part 1... " 2>&1 | tee -a ${glb_log_build}
	make install-gcc install-target-libgcc >/dev/null 2>&1 | tee -a ${glb_log_build} || exit 1
	echo "done" 2>&1 | tee -a ${glb_log_build}
	
	cd ${glb_disk_image_path}
}

# Build Embedded GLIBC
build_eglibc(){
	
	echo "Building Embedded GLIBC..." 2>&1 | tee -a ${glb_log_build}
	
	cd ${glb_download_path}
	
	if [ ! -f "${glb_eglibc_arch}" ]; then
		echo "Error: ${glb_eglibc_arch} not found!" 2>&1 | tee -a ${glb_log_build}
		exit 1
	fi
	
	echo -n "md5 check of ${glb_eglibc_arch}... " 2>&1 | tee -a ${glb_log_build}
	if [ ! $(md5 -q ${glb_download_path}/${glb_eglibc_arch}) = ${glb_eglibc_md5} ]; then
		echo "faild!" 2>&1 | tee -a ${glb_log_build} 2>&1 | tee -a ${glb_log_build}
		exit 1
	fi
	echo "passed" 2>&1 | tee -a ${glb_log_build}
	
	cd ${glb_source_path}
	if [ ! -d "${glb_source_path}/${glb_eglibc_name}" ]; then
		echo -n "Extracting Embedded GLIBC... " 2>&1 | tee -a ${glb_log_build}
		tar xjf ${glb_download_path}/${glb_eglibc_arch} || exit 1
		echo "done" 2>&1 | tee -a ${glb_log_build}
		
		echo -n "Patching Embedded GLIBC... " 2>&1 | tee -a ${glb_log_patch}
		patch -p1 < "${BASEPATH}/patches/eglibc.patch" >/dev/null 2>&2 | tee -a ${glb_log_patch} || exit 1
		echo "done" 2>&1 | tee ${glb_log_path}/patch.log 2>&1 | tee -a ${glb_log_patch}
	else
		if [ -d "${glb_source_path}/${glb_eglibc_name}/build" ]; then
			rm -rf ${glb_source_path}/${glb_eglibc_name}/build
		fi
	fi
		
	mkdir -p ${glb_source_path}/${glb_eglibc_name}/build
	cd ${glb_source_path}/${glb_eglibc_name}/build
	
	echo -n "Configure Embedded GLIBC... " 2>&1 | tee -a ${glb_log_build}
	CC=$TARGET-gcc ../configure --host=$TARGET --prefix=$PREFIX \
		--with-headers=$PREFIX/include --enable-add-ons \
		--disable-nls libc_cv_forced_unwind=yes >/dev/null 2>&1 | tee -a ${glb_log_build} || exit 1
	echo "done" 2>&1 | tee -a ${glb_log_build}
	
	echo -n "Build Embedded GLIBC... " 2>&1 | tee -a ${glb_log_build}
	make >/dev/null 2>&1 | tee -a ${glb_log_build} || exit 1
	echo "done" 2>&1 | tee -a ${glb_log_build}
	
	echo -n "Install Embedded GLIBC... " 2>&1 | tee -a ${glb_log_build}
	make install >/dev/null 2>&1 | tee -a ${glb_log_build} || exit 1
	echo "done" 2>&1 | tee -a ${glb_log_build}

}

# Build gcc part 2
build_gcc2(){
	
	echo "Building GCC Part 2..." 2>&1 | tee -a ${glb_log_build}
	
	if [ -d "${glb_source_path}/${glb_gcc_name}" ]; then
		
		if [ -d "${glb_source_path}/${glb_gcc_name}/build2" ]; then
			rm -rf ${glb_source_path}/${glb_gcc_name}/build2
		fi
		
		mkdir -p ${glb_source_path}/${glb_gcc_name}/build2
		cd ${glb_source_path}/${glb_gcc_name}/build2

		echo -n "Configure GCC part 2... " 2>&1 | tee -a ${glb_log_build}
		../configure --target=$TARGET --prefix=$PREFIX --disable-nls \
			--enable-languages=c,c++ --with-headers=$PREFIX/include \
			--with-libs=$PREFIX/lib >/dev/null 2>&1 | tee -a ${glb_log_build} || exit 1
		echo "done" 2>&1 | tee -a ${glb_log_build}
		
		echo -n "Build GCC part 2... " 2>&1 | tee -a ${glb_log_build}
		make >/dev/null 2>&1 | tee -a ${glb_log_build} || exit 1
		echo "done" 2>&1 | tee -a ${glb_log_build}
		
		echo -n "Install GCC part 2... " 2>&1 | tee -a ${glb_log_build}
		make install >/dev/null 2>&1 | tee -a ${glb_log_build} || exit 1
		echo "done" 2>&1 | tee -a ${glb_log_build}
	else
		echo "Error: ${glb_download_path}/${glb_gcc_arch} not found" 2>&1 | tee -a ${glb_log_build}
	fi
}