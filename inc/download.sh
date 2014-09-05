#!/bin/bash
#
# This is a part of ARM Linux Cross-Toolchain for Mac OS X build script
#
# Copyright (C) 2014  Knut Welzel
#


#
# get Linaro crosscompiler sources 
#
download_sources(){
	
	download_package ${package_kernel[@]}
	download_package ${package_gmp[@]}
	download_package ${package_mpfr[@]}
	download_package ${package_isl[@]}
	download_package ${package_cloog[@]}
	download_package ${package_mpc[@]}
	download_package ${package_zlib[@]}
	download_package ${package_binutils[@]}
	download_package ${package_gcc[@]}
	download_package ${package_sysroot[@]}
	download_package ${package_gdb[@]}
	download_package ${package_ncurses[@]}
	download_package ${package_expat[@]}
	download_package ${package_pkgconf[@]}
}


#
# Download a source package
#
download_package(){

	name=$1
	kind=$2
	url=$3
	m5dsum=$4
	archive="${name}${kind}"
	
	
	# download package archiv
	echo -n "Download ${archive}..."
	if ! [ -f "${glb_download_path}/${archive}" ]; then
		
		curl --retry 3 \
			--connect-timeout 10 \
			--silent \
			--location \
			--output "${glb_download_path}/${archive}" \
			$url
		
		echo "${archive} loaded"
	else
		echo "${archive} already loaded"
	fi
	
	# test md5 sum of the package archiv
	md5_test $archive $m5dsum
	
	# extract extract the package archiv
	if [ "$name" == "${package_kernel[0]}" ]; then 
		extract_archive $glb_disk_image_path $kind $name $archive
	else
		# extract extract the package archiv
		extract_archive $glb_source_path $kind $name $archive
	fi
	
	# pacht extract archive
	patch_package $name
}


#
# check md5 sum of an package archive
#
md5_test(){
	
	archive=$1
	m5dsum=$2
	
	# Test if archive is corrupted
	echo -n "md5 check of $1... "
	if [ $(md5 -q "${glb_download_path}/${archive}") != "$m5dsum" ]; then
		echo "faild"
		echo "*** error md5 test of ${archive} faild ***"
		exit 1
	else
		echo "passed"
	fi
}


#
# extract an package archive
#
extract_archive(){
	
	destination=$1
	kind=$2
	name=$3
	archive="${name}${kind}"
	
	# remove existing directory	
	if [ -d "${destination}/${name}/build" ]; then
			
		echo -n "Remove existing build directory... "
		rm -rf "${destination}/${name}/build"
		echo "done"
	else
			
		echo -n "Remove existing directory... "
		rm -rf "${destination}/${name}"
		echo "done"
			
		echo -n "Extracting ${archive}... "
		tar \
			xf "${glb_download_path}/${archive}" \
			-C "${destination}" \
			>/dev/null 2>&1 || (echo "faild"; exit 1)
		echo "done"
	fi
}


#
# patching extract package
#
patch_package(){

	name=$1
		
	if [ -d "${glb_patch_path}/${name}" ]; then
		
		echo -n "Patch ${name}... "
		
		if ! [ -f "${glb_source_path}/${name}/.patched" ]; then
			
			cd "${glb_source_path}/${name}"
				
			FILES="${glb_patch_path}/${name}/*.patch"
			for file in $FILES; do
			
				patch --no-backup-if-mismatch -g0 -F1 -p1 -f < $file >/dev/null 2>&1
			done
		
			touch "${glb_source_path}/${name}/.patched"
			
			echo "done"
		else
			echo "already patched"
		fi
	fi
}
