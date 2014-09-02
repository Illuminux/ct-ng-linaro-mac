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

	# go into download dir
	cd ${glb_download_path}
	

	# Download Linaro crosscompiler sources if not already loaded 
	echo -n "Download Linaro crosscompiler sources Part 1... " 2>&1 | tee -a $glb_build_log
	if [ ! -f "${glb_linaro_src1_arch}" ]; then
		
		wget ${glb_linaro_src1_url} >/dev/null 2>&1 || exit 1
		echo "successfully loaded" 2>&1 | tee -a $glb_build_log
	else

		echo "already loaded" 2>&1 | tee -a $glb_build_log
	fi

	# Test if Linaro crosscompiler sources archive is not corrupted
	if [ -f "${glb_linaro_src1_arch}" ]; then
		
		echo -n "md5 check of ${glb_linaro_src1_name}... " 2>&1 | tee -a $glb_build_log
		if [ ! $(md5 -q ${glb_download_path}/${glb_linaro_src1_arch}) = ${glb_linaro_src1_md5} ]; then
			echo "faild!" 2>&1 | tee -a $glb_build_log 
			exit 1
		fi
		echo "passed" 2>&1 | tee -a $glb_build_log
		
		echo -n "Extracting Linaro crosscompiler sources Part 1... " 2>&1 | tee -a $glb_build_log 
		tar xjf ${glb_download_path}/${glb_linaro_src1_arch} -C ${glb_download_path} || exit 1
		echo "done" 2>&1 | tee -a $glb_build_log
	fi
	

	# go into download dir
	cd ${glb_download_path}
	

	# Download Linaro kernel sources if not already loaded 
	if [ -d "${glb_linaro_src_name}" ]; then
	
		echo -n "Download Linaro crosscompiler sources Part 2... " 2>&1 | tee -a $glb_build_log
		if [ ! -f "${glb_linaro_src2_arch}" ]; then
			wget ${glb_linaro_src2_url} >/dev/null 2>&1 || exit 1
			echo "successfully loaded" 2>&1 | tee -a $glb_build_log
		else
			echo "already loaded" 2>&1 | tee -a $glb_build_log
		fi

		echo -n "md5 check of ${glb_linaro_src2_name}... " 2>&1 | tee -a $glb_build_log
		if [ ! $(md5 -q ${glb_download_path}/${glb_linaro_src2_arch}) = ${glb_linaro_src2_md5} ]; then
			echo "faild!" 2>&1 | tee -a $glb_build_log
			exit 1
		fi
		echo "passed" 2>&1 | tee -a $glb_build_log

		echo -n "Extracting Linaro crosscompiler sources Part 2... " 2>&1 | tee -a $glb_build_log
		tar xjf ${glb_download_path}/${glb_linaro_src2_arch} -C ${glb_download_path} || exit 1
		echo "done" 2>&1 | tee -a $glb_build_log
	
		mv ${glb_download_path}/${glb_linaro_src_name}/* ${glb_download_path}/ || exit 1
		rm -rf ${glb_download_path}/${glb_linaro_src_name} || exit 1
	fi


	# go into download dir
	cd ${glb_download_path}
	
	
#	# Download Linaro eglibc, is not in the main archive
#	echo -n "Download Linaro eglibc... " 2>&1 | tee -a $glb_build_log
#	if [ ! -f "${glb_eglibc_arch}" ]; then
#		wget ${glb_eglibc_url} >/dev/null 2>&1 || exit 1
#		echo "successfully loaded" 2>&1 | tee -a $glb_build_log
#	else 
#		echo "already loaded" 2>&1 | tee -a $glb_build_log
#	fi
	

	# go into download dir
	cd ${glb_download_path}
	
	
	# Download zlib, is not in the main archive
	echo -n "Download zlib... " 2>&1 | tee -a $glb_build_log
	if [ ! -f "${glb_zlib_arch}" ]; then
		wget ${glb_zlib_url} >/dev/null 2>&1 || exit 1
		echo "successfully loaded" 2>&1 | tee -a $glb_build_log
	else 
		echo "already loaded" 2>&1 | tee -a $glb_build_log
	fi
	
	
	# go into download dir
	cd ${glb_download_path}
	
	
	# Download ncurses, is not in the main archive
	echo -n "Download ncurses... " 2>&1 | tee -a $glb_build_log
	if [ ! -f "${glb_ncurses_arch}" ]; then
		wget ${glb_ncurses_url} >/dev/null 2>&1 || exit 1
		echo "successfully loaded" 2>&1 | tee -a $glb_build_log
	else 
		echo "already loaded" 2>&1 | tee -a $glb_build_log
	fi
}