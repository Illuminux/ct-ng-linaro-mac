#!/bin/bash


## Create an case senitive disk image and mount it to /Volumes/[ImageName]
## @autor Knut
create_image(){
	
	size="10M"

	echo -n "Create case sensitive image"
	if [ ! -f "${glb_disk_image_name}.dmg" ]; then
		hdiutil create "${glb_disk_image_name}.dmg" -fs "Case-sensitive Journaled HFS+" -size ${glb_disk_image_size} -volname ${glb_disk_image_name} || exit 1
	else
		echo "already exists"
	fi
	
	echo -n "Mounting image... "
	if [ ! -d "${glb_disk_image_path}" ]; then 
		hdiutil attach "${glb_disk_image_name}.dmg" >/dev/null 2>&1 || exit 1
		echo "mounted to ${glb_disk_image_path}"
	else
		echo "already mounted to ${glb_disk_image_path}"
	fi
	
	echo -n "Create download directory... "
	if [ ! -d "${glb_download_path}" ]; then
		mkdir ${glb_download_path} || exit 1
		echo "done"
	else
		echo "already exists"
	fi 
	
	echo -n "Create source directory... "
	if [ ! -d "${glb_source_path}" ]; then
		mkdir ${glb_source_path} || exit 1
		echo "done"
	else
		echo "already exists"
	fi 
	
	echo -n "Create build directory... "
	if [ ! -d "${glb_build_path}" ]; then
		mkdir ${glb_build_path} || exit 1
		echo "done"
	else
		echo "already exists"
	fi
}


check_for_Command_Line_Tools(){
	
	echo -n "Checking for Command Line Tools... "
	if [ ! -f "/Library/Developer/CommandLineTools/usr/bin/gcc" ]; then
		echo "not installed"
		echo "Command Line Tools are required for the following steps."
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
		echo "installed"
	fi
}

install_Command_Line_Tools(){

	echo -n "Installing Command Line Tools... "
	xcode-select --install 
	echo "Please wait until the command line tools has been installed and run the script again!"
	exit 0
}

finish_build(){
	
	cd ${glb_disk_image_path}
	
	echo -n "Create compressed archiv... "
	mv build arm-linux
	tar -czf "$BASEPATH/${glb_target}.tar.gz" arm-linux/ >/dev/null 2>&1 || exit 1
	mv arm-linux build 
	echo "done"
	
	cd $BASEPATH
	
	echo -n "Unmount build image... "
	hdiutil detach ${glb_disk_image_path} >/dev/null 2>&1
	echo "done"
	
	while true; do
		read -p "Should the build image be deleted? [y/N] " yN
		yN=${yN:-N}
		case $yN in
#			[Yy]* ) rm -rf "${glb_disk_image_name}.dmg"; break;;
			[Yy]* ) echo "remove image"; break;;
			[Nn]* ) break;;
				* ) echo "Please answer Y (Yes) or n (No).";;
		esac
	done
}
