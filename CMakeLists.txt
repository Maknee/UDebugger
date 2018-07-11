set(LLVM_LINK_COMPONENTS support)

set(CMAKE_CXX_STANDARD 14)

project(UDebugger)

file(GLOB_RECURSE headers include/*.h)
file(GLOB_RECURSE sources src/*.cpp)

add_clang_executable(${PROJECT_NAME}
	${sources}
	)

target_include_directories(${PROJECT_NAME}
	PRIVATE
	include/
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
	)

