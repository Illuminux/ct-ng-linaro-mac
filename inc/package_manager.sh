#!/bin/bash

package_manager(){

	package_manager_fink

	package_manager_port
	
	package_manager_brew
	
	echo -n "Checking for GNU wget... "
	if ! foobar_loc="$(type -p wget)" || [ -z "$foobar_loc" ]; then	
		echo "not fond, will be installed!" 
		brew install wget
	else
		echo "yes"
	fi
	
	echo -n "Checking for GNU grep... "
	if ! foobar_loc="$(type -p ggrep)" || [ -z "$foobar_loc" ]; then	
		echo "not fond, will be installed!" 
		brew install grep
	else
		echo "yes"
	fi
	
	echo -n "Checking for GNU sed... "	
	if ! foobar_loc="$(type -p gsed)" || [ -z "$foobar_loc" ]; then	
		echo "not fond, will be installed!" 
		brew install gnu-sed
	else
		echo "yes"
	fi
	
	echo -n "Checking for GNU Compiler Collection... "	
	if ! foobar_loc="$(type -p gcc-4.9)" || [ -z "$foobar_loc" ]; then	
		echo "not fond, will be installed!" 
		brew install gcc binutils
	else
		echo "yes"
	fi
	
	echo -n "Checking for Subversion... "	
	if ! foobar_loc="$(type -p svn)" || [ -z "$foobar_loc" ]; then	
		echo "not fond, will be installed!" 
		brew install svn
	else
		echo "yes"
	fi
	
	echo -n "Checking for Gawk... "	
	if ! foobar_loc="$(type -p gawk)" || [ -z "$foobar_loc" ]; then	
		echo "not fond, will be installed!" 
		brew install gawk
	else
		echo "yes"
	fi
	
	echo -n "Checking for Gettext... "	
	if ! foobar_loc="$(type -p gettext)" || [ -z "$foobar_loc" ]; then	
		echo "not fond, will be installed!" 
		brew install gettext
		brew link gettext --force
	else
		echo "yes"
	fi
		
	package_manager_addlinks
}

package_manager_addlinks(){
	
	echo -n "Adding temporary symbolic links... "
	# relink brew stuf
	ln -sf /usr/local/bin/gsed /usr/local/bin/sed 
	ln -sf /usr/local/bin/ggrep /usr/local/bin/grep 
	ln -sf /usr/local/bin/${glb_cc} /usr/local/bin/gcc
	ln -sf /usr/local/bin/${glb_cxx} /usr/local/bin/g++
	ln -sf /usr/local/bin/${glb_cpp} /usr/local/bin/cpp
#	ln -sf /usr/local/bin/${glb_ar} /usr/local/bin/ar
#	ln -sf /usr/local/bin/${glb_nm} /usr/local/bin/nm
#	ln -sf /usr/local/bin/${glb_ranlib} /usr/local/bin/ranlib

	echo "done"
}

package_manager_dellinks(){
	
	echo -n "Remove temporary symbolic links... "
	# relink brew stuf
	rm /usr/local/bin/sed 
	rm /usr/local/bin/grep
	rm /usr/local/bin/gcc
	rm /usr/local/bin/g++
	rm /usr/local/bin/cpp
#	rm /usr/local/bin/ar
#	rm /usr/local/bin/nm
#	rm /usr/local/bin/ranlib

	echo "done"
}

## Test if package manager is installed
package_manager_test(){
	
	name=$1
	retval=1
		
	if ! foobar_loc="$(type -p $name)" || [ -z "$foobar_loc" ]; then	
		retval=0
	fi
	
	return $retval
}

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

package_manager_install(){
	echo "Installing Brew..."
	ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)" || exit 1
	echo "Brew successfully installed"
}