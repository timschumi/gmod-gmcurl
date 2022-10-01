cmake_minimum_required(VERSION 3.10)
project(gmod-gmcurl LANGUAGES CXX)

set(CMAKE_CONFIGURATION_TYPES Release Debug)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_subdirectory(gmod-module-base/include)
add_subdirectory(curl-static-bin)

add_library(gmcurl SHARED)

# Add sources
add_subdirectory(src)

# Link against the GMod API
target_link_libraries(gmcurl gmod-module-base)

# Link against curl
target_link_libraries(gmcurl curl-phony)

# Set linker script for Linux
if(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
	target_link_options(gmcurl PRIVATE "-Wl,--version-script=${CMAKE_CURRENT_SOURCE_DIR}/gmcurl-linux.exp")
endif()

set_gmod_suffix_prefix(gmcurl)

if("${MORE_STATIC_LINKS}" AND ${CMAKE_SYSTEM_NAME} MATCHES "Linux")
	target_link_options(gmcurl PRIVATE "-static-libstdc++" "-static-libgcc")
endif()
