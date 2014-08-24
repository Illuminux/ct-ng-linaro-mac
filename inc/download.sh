#!/bin/bash

# get Linaro crosscompiler sources 
download_sources(){

	cd ${glb_download_path}

	echo -n "Download Linaro crosscompiler sources Part 1... "
	if [ ! -f "${glb_linaro_src1_arch}" ]; then
		echo ""
		wget ${glb_linaro_src1_url} || exit 1
	else
		echo "already loaded"
	fi
	
	if [ -f "${glb_linaro_src1_arch}" ]; then
		echo -n "md5 check of ${glb_linaro_src1_name}... "
		if [ ! $(md5 -q ${glb_download_path}/${glb_linaro_src1_arch}) = ${glb_linaro_src1_md5} ]; then
			echo "faild!"
			exit 1
		fi
		echo "passed"
		
		echo -n "Extracting Linaro crosscompiler sources Part 1... "
		tar xjf ${glb_download_path}/${glb_linaro_src1_arch} -C ${glb_download_path} || exit 1
		echo "done"
	fi
	
	if [ -d "${glb_linaro_src_name}" ]; then
	
		echo -n "Download Linaro crosscompiler sources Part 2... "
		if [ ! -f "${glb_linaro_src2_arch}" ]; then
			echo ""
			wget ${glb_linaro_src2_url} || exit 1
		else
			echo "already loaded"
		fi

		echo -n "md5 check of ${glb_linaro_src2_name}... "
		if [ ! $(md5 -q ${glb_download_path}/${glb_linaro_src2_arch}) = ${glb_linaro_src2_md5} ]; then
			echo "faild!"
			exit 1
		fi
		echo "passed"

		echo -n "Extracting Linaro crosscompiler sources Part 2... "
		tar xjf ${glb_download_path}/${glb_linaro_src2_arch} -C ${glb_download_path} || exit 1
		echo "done"
	
		mv ${glb_download_path}/${glb_linaro_src_name}/* ${glb_download_path}/ || exit 1
		rm -rf ${glb_download_path}/${glb_linaro_src_name} || exit 1
	fi

	cd ${glb_download_path}
	
	echo -n "Download Linaro eglibc... "
	if [ ! -f "${glb_eglibc_arch}" ]; then
		wget ${glb_eglibc_url} || exit 1
	else 
		echo "already loaded"
	fi
	
	cd ${glb_disk_image_path}
}