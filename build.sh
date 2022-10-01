#!/bin/bash -e

BASE_DIR="$(dirname "$(realpath "${0}")")"

if [ "$#" -lt 2 ]; then
	echo "error: Need at least a build target and build type"
	exit 1
fi

BUILD_TARGET="${1}"
BUILD_TYPE="${2}"

cmake_args=()

# Determine the correct file names and paths
OUTPUT_FILE="gmsv_gmcurl_${BUILD_TARGET}"
BUILD_DIR="gmcurl-${BUILD_TARGET}-${BUILD_TYPE}"

for i in "${@:3}"; do
	case "$i" in
	"clean")
		build_clean=1
		;;
	"verbose")
		build_verbose=1
		;;
	"static")
		build_static=1
		;;
	*)
		echo "Unknown argument: '$i'" >&2
		exit 1
	esac
done

if [ "$build_static" = "1" ]; then
	BUILD_DIR="${BUILD_DIR}-static"
	cmake_args+=("-DMORE_STATIC_LINKS:BOOL=ON")
fi

if [ "$build_verbose" = "1" ]; then
	cmake_args+=("-DCMAKE_VERBOSE_MAKEFILE:BOOL=ON")
fi

if [ "$build_clean" = "1" ]; then
	rm -rf "${BUILD_DIR}"
fi

mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"
cmake \
    -DCMAKE_TOOLCHAIN_FILE=toolchain-${BUILD_TARGET}.cmake \
    -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
    "${cmake_args[@]}" \
    "${BASE_DIR}"
make
