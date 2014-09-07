#!/bin/bash
#
# This is a part of ARM Linux Cross-Toolchain for Mac OS X build script
#
# Copyright (C) 2014  Knut Welzel
#


##
## get Linaro crosscompiler sources 
##
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


##
## Download a source package
##
## @param $1 Name of the package
## @param $2 Archive extansion of the package
## @param $3 Url where the package can be download
## @param $4 md5 sum of the package archiv
##
download_package(){

	name=$1
	kind=$2
	url=$3
	m5dsum=$4
	archive="${name}${kind}"
	
	
	# download package archiv
	print_log -n "Download ${archive}..."
	if ! [ -f "${glb_download_path}/${archive}" ]; then
		
		curl --retry 3 \
			--connect-timeout 10 \
			--silent \
			--location \
			--output "${glb_download_path}/${archive}" \
			$url
		
		print_log "${archive} loaded"
	else
		print_log "${archive} already loaded"
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


##
## Check md5 sum of an package archive
##
## @param $1 The archive name
## @param $2 The m5d sum number
##
md5_test(){
	
	archive=$1
	m5dsum=$2
	
	# Test if archive is corrupted
	print_log -n "md5 check of $1... "
	if [ $(md5 -q "${glb_download_path}/${archive}") != "$m5dsum" ]; then
		print_log "faild"
		echo "*** error md5 test of ${archive} faild ***"
		exit 1
	else
		print_log "passed"
	fi
}


##
## Extract an package archive
##
## @param $1 Destination where to extract the archive
## @param $2 Archive extansion of the package
## @param $3 Name of the package
##
extract_archive(){
	
	destination=$1
	kind=$2
	name=$3
	archive="${name}${kind}"
	
	# remove existing directory	
	if [ -d "${destination}/${name}/build" ]; then
			
		print_log -n "Remove existing build directory... "
		rm -rf "${destination}/${name}/build"
		print_log "done"
	else
			
		print_log -n "Remove existing directory... "
		rm -rf "${destination}/${name}"
		print_log "done"
			
		print_log -n "Extracting ${archive}... "
		
		mkdir -p "${destination}/${name}"
		tar \
			--extract \
			--file="${glb_download_path}/${archive}" \
			--strip-components=1 \
			--directory="${destination}/${name}"
		
		print_log "done"
	fi
}


##
## Patch an extract package
##
## @param $1 Name of the package
##
patch_package(){

	name=$1
		
	if [ -d "${glb_patch_path}/${name}" ]; then
		
		print_log -n "Patch ${name}... "
		
		if ! [ -f "${glb_source_path}/${name}/.patched" ]; then
			
			cd "${glb_source_path}/${name}"
				
			FILES="${glb_patch_path}/${name}/*.patch"
			for file in $FILES; do
			
				patch --no-backup-if-mismatch -g0 -F1 -p1 -f < $file >/dev/null 2>&1
			done
		
			touch "${glb_source_path}/${name}/.patched"
			
			print_log "done"
		else
			print_log "already patched"
		fi
	fi
}
