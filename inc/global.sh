#!/bin/bash

##
## Create an case senitive disk image and mount it to /Volumes/[ImageName]
## 
create_image(){
	
	# Create image if not exists 
	echo "Create case sensitive image" 2>&1 | tee -a $glb_build_log 
	if [ ! -f "${glb_disk_image_name}.sparseimage" ]; then
		hdiutil create "${glb_disk_image_name}.sparseimage" \
			-type SPARSE \
			-fs JHFS+X \
			-size ${glb_disk_image_size} \
			-volname ${glb_disk_image_name} || exit 1
	else
		echo "already exists" 2>&1 | tee -a $glb_build_log
	fi
	
	# Mount image
	echo -n "Mounting image... " 2>&1 | tee -a $glb_build_log
	if [ ! -d "${glb_disk_image_path}" ]; then 
		hdiutil attach ${glb_disk_image_name}.sparseimage -mountroot $BASEPATH >/dev/null 2>&1 || exit 1
		echo "mounted to ${glb_disk_image_path}" 2>&1 | tee -a $glb_build_log
	else
		echo "already mounted to ${glb_disk_image_path}" 2>&1 | tee -a $glb_build_log
	fi
	
	# Create "kernel-build" directory if not exist
	echo -n "Create kernel build directory... " 2>&1 | tee -a $glb_build_log 
	if [ -d "${glb_disk_image_path}/build" ]; then
		rm -rf ${glb_disk_image_path}/build
	fi
	mkdir ${glb_disk_image_path}/build || exit 1
	echo "done" 2>&1 | tee -a $glb_build_log
}


##
## Create directories
## 
create_dir_structure(){
			
	# Create "download" directory if not exist
	echo -n "Create download directory... " 
	if [ ! -d "${glb_download_path}" ]; then
		mkdir -p ${glb_download_path} || exit 1
		echo "done" 
	else
		echo "already exists" 
	fi 

	# Create "src" directory if not exist	
	echo -n "Create source directory... " 
	if [ ! -d "${glb_source_path}" ]; then
		mkdir -p ${glb_source_path} || exit 1
		echo "done" 
	else
		echo "already exists" 
	fi 
	
	# Create "build" directory if not exist
	echo -n "Create build directory... " 
	if [ -d "${glb_build_path}" ]; then
		rm -rf ${glb_build_path}
	fi
	mkdir -p ${glb_build_path} || exit 1
	mkdir -p ${glb_build_path}/static || exit 1
	mkdir -p ${glb_build_path}/gcc-core-static || exit 1
	mkdir -p ${glb_build_path}/gcc-core-shared || exit 1
	mkdir -p ${glb_build_path}/build-kernel-headers || exit 1
	echo "done" 


	# Create "install" directory if not exist	
	echo -n "Create install directory... " 
	if [ -d "${glb_prefix}" ]; then
		rm -rf ${glb_prefix}
	fi
	mkdir -p ${glb_prefix} || exit 1
	mkdir -p ${glb_prefix}/arm-linux-gnueabihf || exit 1
	echo "done" 
	
	
	# Create "log" directory if not exist	
	echo -n "Create log directory... " 
	if [ -d "${glb_log_path}" ]; then
		rm -rf ${glb_log_path}
	fi
	mkdir -p ${glb_log_path} || exit 1
	touch ${glb_build_log}
	echo "done" 
}


## 
## Check if Xcode Command Line Tools are installd.
## If not try to install Command Line Tools
##
check_for_Command_Line_Tools(){
	
	echo -n "Checking for Xcode Command Line Tools... " 2>&1 | tee -a $glb_build_log
	
	if [ ! -f "/Library/Developer/CommandLineTools/usr/bin/gcc" ]; then
		
		echo "not installed" 2>&1 | tee -a $glb_build_log
		echo "Command Line Tools are required for the following steps." 2>&1 | tee -a $glb_build_log
		
		while true; do
		
			read -p "Install Command Line Tools or cancel the script? [I/c] " Ic
		
			Ic=${Ic:-I}
			case $Ic in
				[Ii]* ) install_Command_Line_Tools; break;;
				[Cc]* ) exit 0;;
					* ) echo "Please answer I (Install) or c (cancel).";;
			esac
		done
	else
		echo "installed" 2>&1 | tee -a $glb_build_log
	fi
}


##
## Install Xcode Command Line Tools
## Script will be abort for this stepp
##
install_Command_Line_Tools(){

	echo -n "Installing Command Line Tools... "
	
	# Install Command Line Tools
	xcode-select --install 
	
	echo "Please wait until the command line tools has been installed and run the script again!"
	
	# Script musz be abort at this point, because the installer will not halt the script
	exit 0
}


##
## End of the build
##
finish_build(){
	
	cd $BASEPATH
	
	echo -n "Create compressed archiv... " 
	tar -cJPf ./${glb_build_name}.tar.xz ${glb_build_path} >/dev/null 2>&1 || exit 1
	echo "done" 

	cd $BASEPATH

	echo -n "Unmount build image... " 
	hdiutil detach ${glb_disk_image_path} >/dev/null 2>&1
	echo "done" 
	
	while true; do
		read -p "Should the build image be deleted? [y/N] " yN
		yN=${yN:-N}
		case $yN in
			[Yy]* ) echo "remove image"; break;;
			[Nn]* ) break;;
				* ) echo "Please answer Y (Yes) or n (No).";;
		esac
	done
}
