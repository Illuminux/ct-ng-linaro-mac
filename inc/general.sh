#!/bin/bash
#
# This is a part of ARM Linux Cross-Toolchain for Mac OS X build script
#
# Copyright (C) 2014  Knut Welzel
#

##
## \file general.sh
##
## Geeral functions 
##


##
## Print the default start screen
##
print_start_screen(){

	# Clear screen
	clear 

	while true; do

		echo "This script will build ARM Linux Cross-Toolchain on and for Mac OS X,"
		echo "based on Linaro Toolchain Sources."
		echo "During the execution, several files and programs will be downloaded" 
		echo "from the Internet and installed on your Computer."
		echo "For the execution ${glb_disk_image_size}Bytes of free hard drives"
		echo "memory will be needed!"
		echo
		echo "This program comes with ABSOLUTELY NO WARRANTY; for details type [l]."
		echo "This is free software, and you are welcome to redistribute it"
		echo "under certain conditions; type [l] for details."
		echo
	
		read -p "Continue the script [Y/n]? Or for read the License [l]: " Yn
		
		Yn=${Yn:-Y}
		
		case $Yn in
		
			[Yy]* ) break;;
		
			[Ll]* ) less gpl-3.0.txt; clear;;
		
			[Nn]* ) clear; exit 0;;
		
				* ) clear; echo  "Please answer Y (Yes) or n (No)."; echo;;
		esac
	done

	clear
	
	echo "Start build process. This may take several hours!"
	echo
	
	return 0
}



##
## Print the default start screen
##
print_end_screen(){
	
	echo ""
	echo "ARM Linux Cross-Toolchain for Mac OS X was build successfully."
	echo "You can find them in: "
	echo "   '${glb_prefix}'"
	echo 
	echo "You will also find a compressed archive of the tool-chains in your build directory."
	echo ""
	echo "Have fun with it!" 
	echo
	echo "Please report bugs to:"
	echo "   '$glb_bug_url'"
	echo 
	
	return 0
}



##
## Create directories
## 
create_dir_structure(){
	
	
	# Create "log" directory if not exist	
	echo -n "Create log directory... " 
	
	if [ -d "${glb_log_path}" ]; then
	
		rm -rf ${glb_log_path}
	fi
	
	mkdir -p ${glb_log_path} || error_mkdir
	
	# cerate defaul build log-file
	echo ${glb_build_log}

	print_log "done" 
	

	
	# Create "download" directory if not exist
	print_log -n "Create download directory... " 
	
	if [ -d "${glb_download_path}" ]; then
	
		print_log "already exists"
	else
	
		mkdir -p ${glb_download_path} || error_mkdir
		print_log "done" 
	fi
	
	
	
	# Create "src" directory if not exist	
	print_log -n "Create source directory... " 
	
	if [ -d "${glb_source_path}" ]; then
	
		print_log "already exists" 
	else
	
		mkdir -p ${glb_source_path} || error_mkdir
		print_log "done" 
	fi 
	
	
	
	# Create "build" directory if not exist
	print_log -n "Create build directory... " 
	
	if [ -d "${glb_build_path}" ]; then
	
		rm -rf ${glb_build_path}
	fi
	
	mkdir -p ${glb_build_path}/{static,build-kernel-headers} || error_mkdir
	
	print_log "done" 
	
	
	
	# Create "install" directory if not exist	
	print_log -n "Create install directory... " 
	
	if [ -d "${glb_prefix}" ]; then
	
		rm -rf ${glb_prefix}
	fi
	
	mkdir -p ${glb_prefix}/arm-linux-gnueabihf || error_mkdir
	
	print_log "done" 
	
	
	# remove old builds 
	rm -f "$BASEPATH/${glb_build_name}-mac.zip"
	rm -f "$BASEPATH/${glb_build_name}.dmg"
}



## 
## Check if Xcode Command Line Tools are installd.
## If not try to install Command Line Tools
##
check_for_Command_Line_Tools(){
	
	print_log -n "Checking for Xcode Command Line Tools... "
	
	if [ ! -f "/Library/Developer/CommandLineTools/usr/bin/gcc" ]; then
		
		echo "not installed" print_log
		echo "Command Line Tools are required for the following steps."
		
		while true; do
		
			read -p "Install Command Line Tools or cancel the script? [I/c] " Ic
		
			Ic=${Ic:-I}
			case $Ic in
				[Ii]* ) 
					echo -n "Installing Command Line Tools... "
					
					# Install Command Line Tools
					xcode-select --install 
					
					echo "Please wait until the command line tools has been installed and run the script again!"
					
					# Script has to be abort at this point, because the installer will not halt the script
					exit 0
					;;
					
				[Cc]* ) 
					exit 0
					;;
					
					* ) 
					echo "Please answer I (Install) or c (cancel)."
					;;
			esac
		done
	else
		
		print_log "installed"
	fi
}



##
## Create an case senitive disk image and mount it to /Volumes/[ImageName]
## 
create_image(){
	
	# Create image if not exists 
	print_log "Create Case-Sensitive Disk Image"
	
	if [ ! -f "${glb_disk_image_name}.sparseimage" ]; then
		
		hdiutil create "${glb_disk_image_name}.sparseimage" \
			-type SPARSE \
			-fs JHFS+X \
			-size ${glb_disk_image_size} \
			-volname ${glb_disk_image_name} || error_hdiutil
	else
		
		print_log "already exists"
	fi
	
	
	# Mount image
	print_log -n "Mounting image... "
	
	if [ ! -d "${glb_disk_image_path}" ]; then 
		
		hdiutil attach ${glb_disk_image_name}.sparseimage -mountroot $BASEPATH >/dev/null 2>&1 || error_hdiutil
		print_log "mounted to ${glb_disk_image_path}"
	else
		
		print_log "already mounted to ${glb_disk_image_path}"
	fi
}



##
## Stripping all toolchain executables
##
strip_bin(){
	
	print_log -n "Stripping all toolchain executables... "
	
	
	# Stripping files in bin
	FILES="${glb_prefix}/bin/*"
	
	for f in $FILES; do
		
		strip $f >/dev/null 2>&1 >> $glb_build_log
	done
	
	
	# Stripping files in TARGET/bin
	FILES="${glb_prefix}/${glb_target}/bin/*"
	
	for f in $FILES; do
		
		strip $f >/dev/null >/dev/null 2>&1 >> $glb_build_log
	done
	
	
	
	# Stripping files in libexec/gcc/TARGET
	FILES="${glb_prefix}/libexec/gcc/${glb_target}/${glb_linaro_gcc_version}/*"
	
	for f in $FILES; do
		
		strip $f >/dev/null >/dev/null 2>&1 >> $glb_build_log
	done
	
	
	print_log "done"
}



##
## End of the build
##
finish_build(){
	
	
	print_log "Clean-up toolchain directory:"
	
	# Stripping all toolchain executables
	strip_bin
	
	
	cd ${BASEPATH}
	
	# Create compressed archive
	print_log -n "Create compressed archive... " 
	
	mkdir -p "${BASEPATH}/image" || error_mkdir
	
	mv ${glb_prefix} "${BASEPATH}/image/${glb_build_name}" || warning_mv
	
	hdiutil \
		create "./${glb_build_name}.dmg" \
		-srcfolder "${BASEPATH}/image" \
		-volname ${glb_build_name}  >/dev/null 2>&1 || warning_hdiutil
	
	
	zip -r -X "${glb_build_name}-mac.zip" "${glb_build_name}.dmg" >/dev/null
	
	rm -rf "${glb_build_name}.dmg" >/dev/null 2>&1
	mv "${BASEPATH}/image/${glb_build_name}" ${glb_prefix} || warning_mv
	rm -rf "${BASEPATH}/image"
	
	print_log "done"
	
	
	cd $BASEPATH
	
	
	print_log "Cleaning-up the build directory:"
	
	
	
	# Compress all log files 
	print_log -n "Compress log files... "
	
	FILES="${glb_log_path}/*.log"
	for f in $FILES; do
		zip -X "${f}.zip" $f >/dev/null 2>&1
		rm -f $f >/dev/null 2>&1
	done
	
	print_log "done"
	
	
	print_log -n "Delete build directory... "
	rm -rf $glb_build_path >/dev/null 2>&1
	print_log "done"
	
	
	while true; do
		read -p "Delete source directory? [Y/n] " Yn
		Yn=${Yn:-Y}
		case $Yn in
			[Yy]* )
				print_log -n "Delete source directory... "
				rm -rf $glb_source_path
				print_log "done"
				break;;
			[Nn]* ) break;;
				* ) echo "Please answer Y (Yes) or n (No).";;
		esac
	done
	
	
	print_log -n "Unmount image... " 
	hdiutil detach $glb_disk_image_path >/dev/null 2>&1 || warning_hdiutil
	print_log "done" 
	
	
	while true; do
		read -p "Delete Case-Sensitive Disk Image? [Y/n] " Yn
		Yn=${Yn:-Y}
		case $Yn in
			[Yy]* ) 
				print_log -n "Delete disk image... "
				rm -rf "${glb_disk_image_name}.sparseimage"
				print_log "done"
				break;;
			[Nn]* ) break;;
				* ) echo "Please answer Y (Yes) or n (No).";;
		esac
	done
	
	
	cd $BASEPATH
	
	
	while true; do
		read -p "Install tool-chains now? [Y/n] " Yn
		Yn=${Yn:-Y}
		case $Yn in
			[Yy]* ) \
				print_log -n "Install tool-chains... "
				mv "./${glb_build_name}" "./gcc-${glb_target}"
				mv "gcc-${glb_target}" "/usr/local/"
				glb_prefix="/usr/local/gcc-${glb_target}"
				print_log "done"
				break;;
			[Nn]* ) break;;
				* ) echo "Please answer Y (Yes) or n (No).";;
		esac
	done
}