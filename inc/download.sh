#!/bin/bash

# get Linaro crosscompiler sources 
download_sources(){

	cd ${glb_download_path}

	echo -n "Download Linaro crosscompiler sources Part 1... " 2>&1 | tee -a ${glb_log_download}
	if [ ! -f "${glb_linaro_src1_arch}" ]; then
		wget ${glb_linaro_src1_url} >/dev/null 2>&1 | tee -a ${glb_log_download} || exit 1
		echo "successfully loaded" 2>&1 | tee -a ${glb_log_download}
	else
		echo "already loaded" 2>&1 | tee -a ${glb_log_download}
	fi
	
	if [ -f "${glb_linaro_src1_arch}" ]; then
		echo -n "md5 check of ${glb_linaro_src1_name}... " 2>&1 | tee -a ${glb_log_download}
		if [ ! $(md5 -q ${glb_download_path}/${glb_linaro_src1_arch}) = ${glb_linaro_src1_md5} ]; then
			echo "faild!" 2>&1 | tee -a ${glb_log_download}
			exit 1
		fi
		echo "passed" 2>&1 | tee -a ${glb_log_download}
		
		echo -n "Extracting Linaro crosscompiler sources Part 1... " 2>&1 | tee -a ${glb_log_download}
		tar xjf ${glb_download_path}/${glb_linaro_src1_arch} -C ${glb_download_path} || exit 1
		echo "done" 2>&1 | tee -a ${glb_log_download}
	fi
	
	if [ -d "${glb_linaro_src_name}" ]; then
	
		echo -n "Download Linaro crosscompiler sources Part 2... " 2>&1 | tee -a ${glb_log_download}
		if [ ! -f "${glb_linaro_src2_arch}" ]; then
			wget ${glb_linaro_src2_url} >/dev/null 2>&1 | tee -a ${glb_log_download} || exit 1
			echo "successfully loaded" 2>&1 | tee -a ${glb_log_download}
		else
			echo "already loaded" 2>&1 | tee -a ${glb_log_download}
		fi

		echo -n "md5 check of ${glb_linaro_src2_name}... " 2>&1 | tee -a ${glb_log_download}
		if [ ! $(md5 -q ${glb_download_path}/${glb_linaro_src2_arch}) = ${glb_linaro_src2_md5} ]; then
			echo "faild!" 2>&1 | tee -a ${glb_log_download}
			exit 1
		fi
		echo "passed" 2>&1 | tee -a ${glb_log_download}

		echo -n "Extracting Linaro crosscompiler sources Part 2... " 2>&1 | tee -a ${glb_log_download}
		tar xjf ${glb_download_path}/${glb_linaro_src2_arch} -C ${glb_download_path} || exit 1
		echo "done" 2>&1 | tee -a ${glb_log_download}
	
		mv ${glb_download_path}/${glb_linaro_src_name}/* ${glb_download_path}/ || exit 1
		rm -rf ${glb_download_path}/${glb_linaro_src_name} || exit 1
	fi

	cd ${glb_download_path}
	
	echo -n "Download Linaro eglibc... " 2>&1 | tee -a ${glb_log_download}
	if [ ! -f "${glb_eglibc_arch}" ]; then
		wget ${glb_eglibc_url} >/dev/null 2>&1 | tee -a ${glb_log_download} || exit 1
		echo "successfully loaded" 2>&1 | tee -a ${glb_log_download}
	else 
		echo "already loaded" 2>&1 | tee -a ${glb_log_download}
	fi
	
	cd ${glb_disk_image_path}
}