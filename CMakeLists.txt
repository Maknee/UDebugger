cmake_minimum_required (VERSION 3.8)
set(LLVM_LINK_COMPONENTS support)

project(UDebugger)

file(GLOB_RECURSE headers include/*.h)
file(GLOB_RECURSE sources src/*.cpp)

add_clang_executable(${PROJECT_NAME}
  ${sources}
  3rd_party/linenoise/linenoise.c
  )

target_include_directories(${PROJECT_NAME}
  PRIVATE
  include/
  3rd_party/libelfin
  3rd_party/linenoise
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
  ${PROJECT_SOURCE_DIR}/3rd_party/libelfin/dwarf/libdwarf++.so
  ${PROJECT_SOURCE_DIR}/3rd_party/libelfin/elf/libelf++.so)

add_dependencies(${PROJECT_NAME} libelfin)

set_target_properties(${PROJECT_NAME} PROPERTIES
  CXX_STANDARD 17
  CXX_STANDARD_REQUIRED ON
  )
