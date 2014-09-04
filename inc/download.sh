#!/bin/bash
#
# This is a part of ARM Linux Cross-Toolchain for Mac OS X build script
#
# Copyright (C) 2014  Knut Welzel
#

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
	extract_archive $kind $name $archive
	
	# pacht extract archive
	patch_package $name
}


#
# get Linaro crosscompiler sources 
#
download_sources(){
	
	download_package ${package_kernel[@]}
	download_package ${package_gmp[@]}
	download_package ${package_mpfr[@]}
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


