#!/bin/bash
#
# This is a part of ARM Linux Cross-Toolchain for Mac OS X build script
#
# Copyright (C) 2014  Knut Welzel
#


##
## do echo and log file output
##
print_log(){

	if [ "$1" == "-n" ]; then 
		
		echo -n "${2}"
		echo -n $2 >> $glb_build_log
	else
	
		echo $1
		echo $1 >> $glb_build_log
	fi
}


warning_ln(){
	
	echo "Warning: Link could not be created"
}


warning_mv(){
	
	echo "Warning: Could not move files"
}


error_mkdir(){

	echo "*** Could not create directory ***"
	exit 1
}


error_tar(){

	echo "*** Could not extract archive ***"
	exit 1
}


error_copy(){
	
	echo "*** Error copy failed ***"
	exit 1
}


error_configure(){
	
	print_log "faild"
	echo "*** Error in the configuration ***"
	exit 1
}


error_make(){
	
	print_log "faild"
	echo "*** Error during make opatation ***"
	exit 1
}


error_install(){
	
	print_log "faild"
	echo "*** Error during installation ***"
	exit 1
}



error_hdiutil(){

	print_log "faild"
	echo "*** Error while using the hdiutil ***"
	exit 1
}



warning_hdiutil(){
	
	echo "Warning: Could not use hdiutil"
}




