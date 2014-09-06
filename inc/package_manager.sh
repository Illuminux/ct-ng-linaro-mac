#!/bin/bash
#
# This is a part of ARM Linux Cross-Toolchain for Mac OS X build script
#
# Copyright (C) 2014  Knut Welzel
#

##
## serach for installed packagmanager
## - abort on fink/port
## - install brew if not found
##
package_manager(){

	# Test if Fink is installed 
	package_manager_fink

	package_manager_port
	
	package_manager_brew
	
	print_log -n "Checking for GNU Compiler Collection... "
	if ! gcc_loc="$(type -p gcc-4.8)" || [ -z "$gcc_loc" ]; then	
		print_log "not fond, will be installed!"
		brew install homebrew/versions/gcc48
		brew install binutils
	else
		print_log "yes"
	fi
}



## Test if package manager is installed
package_manager_test(){
	
	name=$1
	retval=1
		
	if ! pmt="$(type -p $name)" || [ -z "pmt" ]; then	
		retval=0
	fi
	
	return $retval
}



##
## Test if Fink is installed 
## The script is terminated here, because i am not able to test it with the Fink tools.
##
package_manager_fink(){
	
	package_manager_test "fink"
	
	echo -n "Checking for Package Manager Fink... "
	if [ $? -eq 1 ]; then
		echo "found"
		echo 
		echo "The following steps are designed for the package manager Brew."
		echo "Please uninstall Fink and the run script again, Brew will be installed automatically."
		exit 1
	else 
		echo "not found"
	fi
}



##
## Test if MacPort is installed 
## The script is terminated here, because i am not able to test it with the MacPort tools.
##
package_manager_port(){
	
	package_manager_test "port"
	
	echo -n "Checking for Package Manager MacPort... "
	if [ $? -eq 1 ]; then
		echo "found"
		echo 
		echo "The following steps are designed for the package manager Brew."
		echo "Please uninstall MacPort and the run script again, Brew will be installed automatically."
		exit 1
	else 
		echo "not found"
	fi
}



##
## Test if Homebrew is installed 
## If Homebrew, Fink and Macport are not installd, try to install Homebrew
##
package_manager_brew(){
	
	echo -n "Checking for Package Manager Brew... "
	
	package_manager_test "brew"
	
	if [ $? -eq 1 ]; then
		echo "found"
	else
		echo "not found"
		echo "The package manager is required for further installation!"
		while true; do
			read -p "Do you wish to install Brew or cancel the script? [I/c] " Ic
			Ic=${Ic:-I}
			case $Ic in
				[Ii]* ) package_manager_install; break;;
				[Cc]* ) exit 0;;
					* ) echo "Please answer I (Install) or c (cancel).";;
			esac
		done
	fi
}



##
## Try to install Homebrew
##
package_manager_install(){
	
	print_log "Installing Homebrew..."
	ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)" || exit 1
	
	brew doctor
	brew untap homebrew/dupes
	brew untap homebrew/versions
	#brew tap versions
	brew update
	
	print_log "Homebrew successfully installed"
}
