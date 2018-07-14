cmake_minimum_required (VERSION 3.5)
set(LLVM_LINK_COMPONENTS support)

add_compile_options(-std=c++14)

project(UDebugger)

file(GLOB_RECURSE headers include/*.h)
file(GLOB_RECURSE sources src/*.cpp)

include_directories(3rd_party/libelfin
                    3rd_party/linenoise
                    include)

add_clang_executable(${PROJECT_NAME}
	${sources}
  3rd_party/linenoise/linenoise.c
	)

target_include_directories(${PROJECT_NAME}
	PRIVATE
	include/
	)

add_custom_target(
  libelfin
  COMMAND make
  WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/3rd_party/libelfin
  )

target_link_libraries(${PROJECT_NAME}
	PRIVATE
	clangToolingCore
	clangTooling
	clangFrontend
	clangAST
	clangASTMatchers
	clangBasic
	clangLex
  ${PROJECT_SOURCE_DIR}/3rd_party/libelfin/dwarf/libdward++.so
  ${PROJECT_SOURCE_DIR}/3rd_party/libelfin/elf/libelf++.so)
	)

add_dependencies(${PROJECT_NAME} libelfin)

