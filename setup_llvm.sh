#!/bin/bash

program_name="UDebugger" 
cmake_flags="-DLLVM_USE_LINKER=gold -DCMAKE_BUILD_TYPE=Debug -DBUILD_SHARED_LIBS=true"

#references to this directory
PREVIOUS_DIR=$(cd ..; pwd)
TOOLS_DIR=$PREVIOUS_DIR/tools
PROGRAM_DIR=$PREVIOUS_DIR/$program_name

LLVM_VERSION="6.0.0" #version of llvm to fetch

LLVM_DOWNLOADS_PAGE=http://releases.llvm.org/${LLVM_VERSION}

LLVM_UNCOMPRESSED_FOLDER=llvm-${LLVM_VERSION}.src
LLVM_TAR_SOURCE=${LLVM_UNCOMPRESSED_FOLDER}.tar.xz
LLVM_SOURCE_PAGE=${LLVM_DOWNLOADS_PAGE}/${LLVM_TAR_SOURCE}

CLANG_UNCOMPRESSED_FOLDER=cfe-${LLVM_VERSION}.src
CLANG_TAR_SOURCE=${CLANG_UNCOMPRESSED_FOLDER}.tar.xz
CLANG_SOURCE_PAGE=${LLVM_DOWNLOADS_PAGE}/${CLANG_TAR_SOURCE}

CLANG_TOOLS_EXTRA_UNCOMPRESSED_FOLDER=clang-tools-extra-${LLVM_VERSION}.src
CLANG_TOOLS_EXTRA_TAR_SOURCE=${CLANG_TOOLS_EXTRA_UNCOMPRESSED_FOLDER}.tar.xz
CLANG_TOOLS_EXTRA_SOURCE_PAGE=${LLVM_DOWNLOADS_PAGE}/${CLANG_TOOLS_EXTRA_TAR_SOURCE}

#check for clang's path
if [ "$#" -eq 2 ]; then
	if [ "$1" = "SETUP" ]; then
		echo $LLVM_TAR_SOURCE
		echo $LLVM_SOURCE_PAGE
		clang_path="$2"
		clang_extra_path=$clang_path/llvm/tools/clang/tools/extra
		clang_cmake_lists_path=$clang_extra_path/CMakeLists.txt
		clang_program_path=$clang_extra_path/$program_name
		clang_build_path=$clang_path/build
		clang_bin_path=$clang_build_path/bin
		
		#make clang folder
		mkdir $clang_path 
		mkdir $clang_build_path 

		#fetch llvm/clang source code and uncompress into correct directories
		(
		cd $clang_path; \
		wget $LLVM_SOURCE_PAGE; \
		tar -xvf $LLVM_TAR_SOURCE; \
		mv $LLVM_UNCOMPRESSED_FOLDER llvm; \
		cd llvm/tools; \

		wget $CLANG_SOURCE_PAGE; \
		tar -xvf $CLANG_TAR_SOURCE; \
		mv $CLANG_UNCOMPRESSED_FOLDER clang; \
		cd clang/tools; \
		
		wget $CLANG_TOOLS_EXTRA_SOURCE_PAGE; \
		tar -xvf $CLANG_TOOLS_EXTRA_TAR_SOURCE; \
		mv $CLANG_TOOLS_EXTRA_UNCOMPRESSED_FOLDER extra; \
		)
		
		#make links to this directory
		ln -s $PROGRAM_DIR $clang_program_path

		#add to CMakeList.txt the program
		echo "add_subdirectory(${program_name})" >> $clang_cmake_lists_path

		#make links to tools in /build/bin directory
		for file in $TOOLS_DIR/*; do
			cp $file $clang_build_path
		done

		#fetch ninja and compile it
		(
		cd $clang_path; \
		git clone https://github.com/martine/ninja.git; \
		cd ninja; \
		git checkout release; \
		./configure.py --bootstrap; \
		cp -f ninja $clang_build_path; \
		)
		
		#generate cmakelists.txt
		(
		cd $clang_build_path; \
		cmake -G Ninja ../llvm ${cmake_flags}; \
		)

		#compile program using ninja
		(
		cd $clang_build_path; \
		./ninja $program_name; \
		)
	fi
fi
