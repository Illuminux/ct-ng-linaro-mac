#!/bin/bash
#
# This Script builds ARM Linux Cross-Toolchain on and for Mac OS X,
# based on Linaro Toolchain Sources.
#
# Copyright (C) 2015  Knut Welzel
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# 

# Abort on error
set -e

# Setup the base dir
BASEDIR=$(pwd)

# Error handler for clean up
error() {
	echo "*** ERROR ***"
	source "${BASEDIR}/dellinks.sh"
	hdiutil detach "${BASEDIR}/crosstool-ng"
	exit 1
}

# Lenaro release
RELEASE_VERSION="1.13.1"
RELEASE_DATE="14.08"
RELEASE_GCC="4.9"
RELEASE_URL="https://releases.linaro.org/${RELEASE_DATE}/components/toolchain/binaries/crosstool-ng-linaro-${RELEASE_VERSION}-${RELEASE_GCC}-20${RELEASE_DATE}.tar.bz2"
VERSION="${RELEASE_VERSION}-${RELEASE_GCC}-20${RELEASE_DATE}"


# Test if Homebrew is installed 
# If it is not installed print message and abort
if ! hash "brew" 2>/dev/null; then
	echo "To build the ARM Toolchain on Mac OS X you have to install Homebrew."
	echo "You can download Homebrew from: http://brew.sh."
	echo
	exit 1
fi

# Test if MacTeX is installed 
# If it is not installed print message and abort
if ! hash "tex" 2>/dev/null; then
	echo "To build the ARM Toolchain on Mac OS X you have to install MacTeX."
	echo "You can download MacTeX from: https://tug.org/mactex/."
	echo
	exit 1
fi


# Test if MacTeX is installed 
# If it is not installed print message
if ! hash "Xorg" 2>/dev/null; then
	echo "To build the ARM Toolchain on Mac OS X it is recommended to install Xquartz."
	echo "You can install Xquartz from Launchpad Utilitys, by clicking the X11 Icon"
	echo "or download Xquartz from: http://xquartz.macosforge.org/landing/."
	echo
	echo -n "Press enter for continue or [A] for abbort: "
	read KEY
	
	case $KEY in
		[Aa]* ) exit 0;;
		* ) 	echo;;
	esac
fi


# Samples that can be created with this script
SAMPLES=(
	"linaro-arm-linux-gnueabi"
	"linaro-arm-linux-gnueabihf"
	"linaro-arm-linux-gnueabihf-raspbian"
)


# Placeholder for the target sample
SAMPLE=false

# Parse command line arguments for supported sample
# If a supported sample was found set it to SAMPLE
for SAMPLE in "${SAMPLES[@]}"; do
	if [ "$1" == "$SAMPLE" ]; then
		break
	else
		SAMPLE=false
	fi
done

# Get target from sample
TARGET=${SAMPLE#"linaro"*-}


# If no supported sample was found abort the script and print the usage
if [ "${SAMPLE}" == false ]; then
	echo "Usage: $0 [Sample]"
	echo "Samples:"
	for SAMPLE in "${SAMPLES[@]}"; do
		echo "  $SAMPLE"
	done
	echo 
	exit 1
fi


# Create file to remove the links
echo "#!/bin/bash" > "${BASEDIR}/dellinks.sh"
chmod +x "${BASEDIR}/dellinks.sh" 


# Required homebrew packages
REQUIRES=(
	"automake"
	"autoconf"
	"binutils"
	"bison"
	"cloog"
	"cvs"
	"doxygen"
	"gawk"
	"gcc"
	"grep"
	"gnu-sed"
	"libtool"
	"readline"
	"wget"
)


# Serach if the required packages are installed. This packages are all auto 
# linked. If a packet is not found it will be installed automatically.
for REQUIRE in "${REQUIRES[@]}"
do
	echo -n "Checking for '$REQUIRE'... "
	if [ $(brew list | grep -c $REQUIRE) = 0 ]; then
		brew install $REQUIRE 2>&1 || error
	else 
		echo "yes"
	fi
done


# Serche for homebrew ncurses.
# Ncurses must be linked with force and we need also the 32Bit libraray, by
# default only the 64bit version will installed.
echo -n "Checking for 'ncurses'... "
if [ $(brew list | grep -c ncurses) = 0 ]; then
	echo
	brew tap homebrew/dupes 2>&1 || error
	brew install ncurses --universal 2>&1 || error
	brew link ncurses --force 2>&1 || error
else 
	echo "yes"
	echo -n "Checking for 'ibncurses.dylib'... "
	if ! [ "/usr/local/lib/libncurses.dylib" ]; then
		echo "no"
		brew link ncurses --force 2>&1 || error
	else
		echo "yes"
	fi
	
	echo -n "Checking for 'libncurses' support for architecture i386... "
	if [ $(file /usr/local/lib/libncurses.dylib | grep -c i386) == 0 ]; then
		brew reinstall ncurses --universal 2>&1 || error
		brew link ncurses --force 2>&1 || error
	else
		echo "yes"
	fi
fi 


# Serche for homebrew gettext.
# Gettext must be linked with force and we need also the 32Bit libraray, by
# default only the 64bit version will installed.
echo -n "Checking for 'gettext'... "
if [ $(brew list | grep -c gettext) = 0 ]; then
	echo
	brew install gettext --universal 2>&1 || error
	brew link gettext --force 2>&1 || error
else 
	echo "yes"
	echo -n "Checking for 'libgettextlib.dylib'... "
	if ! [ "/usr/local/lib/libgettextlib.dylib" ]; then
		echo "no"
		brew link ncurses --force 2>&1 || error
	else
		echo "yes"
	fi
	
	echo -n "Checking for 'libgettext' support for architecture i386... "
	if [ $(file /usr/local/lib/libgettextlib.dylib | grep -c i386) == 0 ]; then
		brew reinstall ncurses --universal 2>&1 || error
		brew link ncurses --force 2>&1 || error
	else
		echo "yes"
	fi
fi


# check for gcc 4.9
echo -n "Checking for 'gcc-4.9'... "
if ! hash "gcc-4.9" 2>/dev/null; then
	echo
	brew tap homebrew/versions 2>&1 || error
	brew install gcc49 2>&1 || error
else
	echo "yes"
fi


# ceck for readelf
echo -n "Checking for 'readelf'... "
if ! hash "readelf" 2>/dev/null; then
	echo "link greadelf"
	ln -s /usr/local/bin/greadelf /usr/local/bin/readelf
	echo "rm /usr/local/bin/readelf" >> "${BASEDIR}/dellinks.sh"
else
	echo "yes"
fi


# for building the toolchains wir need a GNU Cross Compiler and not the Apple
# one. It is not possible to export CC, CXX etc. So the only way is to
# overwrite the Apple GCC temporary. At the end of the script we will remove 
# thes.
DARWIN_DUMP=$(gcc -dumpmachine)
BREW_DUMP=$(gcc-4.9 -dumpmachine)
if ! [ -L "/usr/local/bin/${DARWIN_DUMP}-c++" ]; then
	ln -s /usr/local/bin/${BREW_DUMP}-c++-4.9 /usr/local/bin/${DARWIN_DUMP}-c++
	echo "rm /usr/local/bin/${DARWIN_DUMP}-c++" >> "${BASEDIR}/dellinks.sh"
fi
if ! [ -L "/usr/local/bin/${DARWIN_DUMP}-g++" ]; then
	ln -s /usr/local/bin/${BREW_DUMP}-g++-4.9 /usr/local/bin/${DARWIN_DUMP}-g++
	echo "rm /usr/local/bin/${DARWIN_DUMP}-g++" >> "${BASEDIR}/dellinks.sh"
fi
if ! [ -L "/usr/local/bin/${DARWIN_DUMP}-gcc" ]; then
	ln -s /usr/local/bin/${BREW_DUMP}-gcc-4.9 /usr/local/bin/${DARWIN_DUMP}-gcc
	echo "rm /usr/local/bin/${DARWIN_DUMP}-gcc" >> "${BASEDIR}/dellinks.sh"
fi
if ! [ -L "/usr/local/bin/${DARWIN_DUMP}-gcc-ar" ]; then
	ln -s /usr/local/bin/${BREW_DUMP}-gcc-ar-4.9 /usr/local/bin/${DARWIN_DUMP}-gcc-ar
	echo "rm /usr/local/bin/${DARWIN_DUMP}-gcc-ar" >> "${BASEDIR}/dellinks.sh"
fi
if ! [ -L "/usr/local/bin/${DARWIN_DUMP}-gcc-nm" ]; then
	ln -s /usr/local/bin/${BREW_DUMP}-gcc-nm-4.9 /usr/local/bin/${DARWIN_DUMP}-gcc-nm
	echo "rm /usr/local/bin/${DARWIN_DUMP}-gcc-nm" >> "${BASEDIR}/dellinks.sh"
fi
if ! [ -L "/usr/local/bin/${DARWIN_DUMP}-gcc-ranlib" ]; then
	ln -s /usr/local/bin/${BREW_DUMP}-gcc-ranlib-4.9 /usr/local/bin/${DARWIN_DUMP}-gcc-ranlib
	echo "rm /usr/local/bin/${DARWIN_DUMP}-gcc-ranlib" >> "${BASEDIR}/dellinks.sh"
fi


# For building the kernel and all the stuff, we need a case sensitiv file 
# system. The only way to get this is to create a disk image with the option 
# JHFS+X. The option SPARSE means that the image will increase up to the
# specified size.
if ! [ -f "crosstool-ng.sparseimage" ]; then 
	echo -n "Create case sensitiv disc image... "
	hdiutil create crosstool-ng.sparseimage \
		-type SPARSE \
		-fs JHFS+X \
		-size 20G \
		-volname crosstool-ng > /dev/null 2>&1 || error
	echo "done"
fi

# The mountpoint is a folder inside the script directory. To mount it into 
# "/Volumes" is to confusing.
if ! [ -d "./crosstool-ng" ]; then
	echo -n "Mount case sensitiv disc image... "
	hdiutil attach crosstool-ng.sparseimage -mountroot ./ > /dev/null 2>&1 || error
	echo "done"
fi


#
# Her we have to download, patch and install the crosstool-ng-linaro
#

if ! [ -f "${BASEDIR}/version.txt" ]; then
	echo "new" > "${BASEDIR}/version.txt"
fi


if [ "$(cat ${BASEDIR}/version.txt)" != "${VERSION}" ]; then
	
	cd ${BASEDIR}
	
	# Download crosstool-ng-linaro
	if ! [ -f "${BASEDIR}/crosstool-ng-linaro-${VERSION}.tar.bz2" ]; then
		echo "Download crosstool-ng-linaro-${VERSION}"
		curl -OL# $RELEASE_URL
	fi

	# Extract crosstool-ng-linaro and rename crosstool-ng-linaro folder to a
	# name without version info 
	if [ -d "${BASEDIR}/crosstool-ng-linaro" ];then
		echo -n "Remove previous source dir... "
		rm -rf "${BASEDIR}/crosstool-ng-linaro" > /dev/null 2>&1 || error
		echo "done"
	fi	
	echo -n "Extract crosstool-ng-linaro-${VERSION}... "
	tar xf "crosstool-ng-linaro-${VERSION}.tar.bz2" > /dev/null
	mv "crosstool-ng-linaro-${VERSION}" crosstool-ng-linaro > /dev/null 2>&1 || error
	echo "done"
	
	# delete old ct-ng-linaro installation
	if [ -d "${BASEDIR}/crosstool-ng/ct-ng-linaro" ]; then 
		echo -n "Remove previous crosstool-ng install dir... "
		rm -rf "${BASEDIR}/crosstool-ng/ct-ng-linaro" > /dev/null 2>&1 || error
		echo "done"
	fi
	
	cd ${BASEDIR}/crosstool-ng-linaro
	
	echo "Patching crosstool-ng-linaro for use on Mac OS X:"
	patch -p1 < ../crosstool-ng-linaro-mac.patch 2>&1 || error
	
	# Configure crosstool-ng inside the case sensitve directory. So we do not
	# have any configurations on the samples.
	echo -n "Configure crosstool-ng-linaro... "
	./configure \
		--prefix="${BASEDIR}/crosstool-ng/ct-ng-linaro" \
		--with-sed=gsed \
		--with-grep=ggrep \
		--with-gcc=gcc-4.9 \
		--with-objcopy=gobjcopy \
		--with-objdump=gobjdump \
		--with-libtool=glibtool \
		--with-libtoolize=glibtoolize > /dev/null 2>&1 || error
	echo "done"
	
	# Make and install crosstool-ng
	echo -n "Build crosstool-ng-linaro... "
	make -j4 > /dev/null 2>&1 || error
	echo "done"
	echo -n "Install crosstool-ng-linaro... "
	make install > /dev/null 2>&1 || error
	make clean > /dev/null 2>&1 || error
	echo "done"
	cd $BASEDIR
	echo $VERSION > "${BASEDIR}/version.txt"
fi

# Remove a workspace of already builded toolchains
if [ -d "$BASEDIR/crosstool-ng/workspace/" ]; then 
	echo -n "Remove previous workspace... "
	rm -rf $BASEDIR/crosstool-ng/workspace > /dev/null 2>&1 || error
	echo "done"
fi


# Make som dirs and links for an simpler handling 
mkdir -p $BASEDIR/crosstool-ng/workspace/.build
mkdir -p $BASEDIR/crosstool-ng/tarballs
ln -s $BASEDIR/crosstool-ng/tarballs $BASEDIR/crosstool-ng/workspace/.build/.
ln -s $BASEDIR/crosstool-ng/workspace/.build $BASEDIR/crosstool-ng/workspace/build


# Predownload of components sources given in ct-ng-linaro are not available.
cd $BASEDIR/crosstool-ng/tarballs
# Download binutils
if ! [ -f "$BASEDIR/crosstool-ng/tarballs/binutils-linaro-2.24.0-2014.08.tar.bz2" ]; then
	echo "Download binutils-linaro:"
	curl -OL# https://releases.linaro.org/14.08/components/toolchain/binutils-linaro/binutils-linaro-2.24.0-2014.08.tar.bz2
fi
# Download binutils
if ! [ -f "$BASEDIR/crosstool-ng/tarballs/gcc-linaro-4.9-2014.08.tar.xz" ]; then
	echo "Download gcc-linaro:"
	curl -OL# https://releases.linaro.org/14.08/components/toolchain/gcc-linaro/4.9/gcc-linaro-4.9-2014.08.tar.xz
fi


# Build the toolchain
cd $BASEDIR/crosstool-ng/workspace
../ct-ng-linaro/bin/ct-ng $SAMPLE 2>&1 || error
../ct-ng-linaro/bin/ct-ng build 2>&1 || error


# Creat a gmg image of the toolchain, compress it to a ZIP archiv and move the 
# Archive into base dir
cd "${BASEDIR}/crosstool-ng/ct-ng-linaro/lib/ct-ng-linaro-${RELEASE_VERSION}-${RELEASE_GCC}-20${RELEASE_DATE}"
echo -n "Compressing ${SAMPLE} Toolchain... "
mv install $TARGET
hdiutil \
	create "./${SAMPLE}.dmg" \
	-srcfolder "./${TARGET}" \
	-fs JHFS+X \
	-volname "${TARGET}" > /dev/null 2>&1 || error
mv $TARGET install 
zip -r -X "${BASEDIR}/${SAMPLE}-${VERSION}-mac.zip" "./${SAMPLE}.dmg" > /dev/null 2>&1 || error
rm -rf "./${SAMPLE}.dmg"
cd $BASEDIR
echo "done"

# Cleanup 
echo -n "Cleaning up... "
# Unmount case sensitive disc image
hdiutil detach "${BASEDIR}/crosstool-ng" > /dev/null
source "${BASEDIR}/dellinks.sh" > /dev/null
rm "${BASEDIR}/dellinks.sh" > /dev/null
echo "done"

echo 
echo "Build of '${SAMPLE}' successfully finished!"
echo "Saved in '${BASEDIR}/${SAMPLE}-${VERSION}-mac.zip'"
echo 

exit 0
