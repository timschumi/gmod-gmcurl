cmake_minimum_required(VERSION 3.10)
project(gmod-curl LANGUAGES CXX)

set(CMAKE_CONFIGURATION_TYPES Release Debug)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_subdirectory(gmod-module-base/include)
add_subdirectory(gmod-common-curl)

add_library(gmsv-curl SHARED)

# Add sources
add_subdirectory(src)

# Link against the GMod API
target_link_libraries(gmsv-curl gmod-module-base)

# Link against curl
target_link_libraries(gmsv-curl curl-phony)

# Set linker script for Linux
if(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
	target_link_options(gmsv-curl PRIVATE "-Wl,--version-script=${CMAKE_CURRENT_SOURCE_DIR}/linux-exports.exp")
endif()

if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
	add_definitions(-DWINDOWS_BUILD)
endif()

SET_TARGET_PROPERTIES(gmsv-curl PROPERTIES OUTPUT_NAME "curl")
set_gmod_suffix_prefix(gmsv-curl)
