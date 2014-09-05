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
	
	echo -n "Checking for GNU grep... " 2>&1 | tee -a $glb_build_log
	if ggrep_loc="$(type -p ggrep)" || [ -z "$ggrep_loc" ]; then	
		echo "yes" 2>&1 | tee -a $glb_build_log
	elif fgrep_loc="$(type -p fgrep)" || [ -z "$fgrep_loc" ]; then	
		echo "yes" 2>&1 | tee -a $glb_build_log
	else
		echo "not fond, will be installed!"  2>&1 | tee -a $glb_build_log
		brew install grep
	fi
	
	echo -n "Checking for GNU sed... " 2>&1 | tee -a $glb_build_log
	if ! gsed_loc="$(type -p gsed)" || [ -z "gsed_loc" ]; then	
		echo "not fond, will be installed!"  2>&1 | tee -a $glb_build_log
		brew install gnu-sed
	else
		echo "yes" 2>&1 | tee -a $glb_build_log
	fi
	
	echo -n "Checking for GNU Compiler Collection... " 2>&1 | tee -a $glb_build_log
	if ! gcc_loc="$(type -p gcc-4.8)" || [ -z "$gcc_loc" ]; then	
		echo "not fond, will be installed!" 2>&1 | tee -a $glb_build_log
		brew install homebrew/versions/gcc48
		brew install binutils
	else
		echo "yes" 2>&1 | tee -a $glb_build_log
	fi
	
	echo -n "Checking for Gawk... " 2>&1 | tee -a $glb_build_log
	if ! gawk_loc="$(type -p gawk)" || [ -z "$gawk_loc" ]; then	
		echo "not fond, will be installed!" 2>&1 | tee -a $glb_build_log
		brew install gawk
	else
		echo "yes" 2>&1 | tee -a $glb_build_log
	fi
	
	echo -n "Checking for Gettext... " 2>&1 | tee -a $glb_build_log
	if ! gettext_loc="$(type -p gettext)" || [ -z "$gettext_loc" ]; then	
		echo "not fond, will be installed!" 2>&1 | tee -a $glb_build_log
		brew install gettext
		brew link gettext --force
	else
		echo "yes" 2>&1 | tee -a $glb_build_log
	fi
		
	package_manager_addlinks
}



##
## Add symbolic links to GNU Tolls to overwrite the Apple once
##
package_manager_addlinks(){
	
	echo -n "Adding temporary symbolic links... " 2>&1 | tee -a $glb_build_log
	# relink brew stuf
	ln -sf /usr/local/bin/gsed /usr/local/bin/sed 
	if ggrep_loc="$(type -p ggrep)" || [ -z "$ggrep_loc" ]; then	
		ln -sf /usr/local/bin/ggrep /usr/local/bin/grep 
	elif fgrep_loc="$(type -p fgrep)" || [ -z "$fgrep_loc" ]; then	
		ln -sf /usr/local/bin/fgrep /usr/local/bin/grep 
	fi	
	ln -sf /usr/local/bin/${glb_cc} /usr/local/bin/gcc
	ln -sf /usr/local/bin/${glb_cxx} /usr/local/bin/g++
	ln -sf /usr/local/bin/${glb_cpp} /usr/local/bin/cpp
#	ln -sf /usr/local/bin/${glb_ar} /usr/local/bin/ar
#	ln -sf /usr/local/bin/${glb_nm} /usr/local/bin/nm
#	ln -sf /usr/local/bin/${glb_ranlib} /usr/local/bin/ranlib

	echo "done" 2>&1 | tee -a $glb_build_log
}



##
## Remove symbolic links to GNU Tolls
##
package_manager_dellinks(){
	
	echo -n "Remove temporary symbolic links... " 2>&1 | tee -a $glb_build_log
	# relink brew stuf
	rm /usr/local/bin/sed 
	rm /usr/local/bin/grep
	rm /usr/local/bin/gcc
	rm /usr/local/bin/g++
	rm /usr/local/bin/cpp
#	rm /usr/local/bin/ar
#	rm /usr/local/bin/nm
#	rm /usr/local/bin/ranlib

	echo "done" 2>&1 | tee -a $glb_build_log
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
		echo ""
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
		echo ""
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
	
	echo "Installing Homebrew..."
	ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)" || exit 1
	
	brew doctor
	brew untap homebrew/dupes
	brew untap homebrew/versions
	#brew tap versions
	brew update
	
	echo "Homebrew successfully installed"
}
