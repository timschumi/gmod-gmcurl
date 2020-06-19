#!/bin/bash -e

# Ensure the machines are up
vagrant up

# Empty dist folder
rm -rf dist
mkdir -p dist

# Build the different configurations
vagrant ssh x86 -c "rm -rf curl-x86-dbg && mkdir -p curl-x86-dbg && cd curl-x86-dbg &&
                    cmake -DCMAKE_TOOLCHAIN_FILE=toolchain-linux32.cmake -DCMAKE_BUILD_TYPE=Debug /vagrant &&
                    make &&
                    cp gmsv_curl_linux.dll /vagrant/dist/gmsv_curl_linux-dbg.dll"

vagrant ssh x64 -c "rm -rf curl-x64-dbg && mkdir -p curl-x64-dbg && cd curl-x64-dbg &&
                    cmake -DCMAKE_TOOLCHAIN_FILE=toolchain-linux64.cmake -DCMAKE_BUILD_TYPE=Debug /vagrant &&
                    make &&
                    cp gmsv_curl_linux64.dll /vagrant/dist/gmsv_curl_linux64-dbg.dll"

vagrant ssh x86 -c "rm -rf curl-x86-rel && mkdir -p curl-x86-rel && cd curl-x86-rel &&
                    cmake -DCMAKE_TOOLCHAIN_FILE=toolchain-linux32.cmake -DCMAKE_BUILD_TYPE=Release /vagrant &&
                    make &&
                    cp gmsv_curl_linux.dll /vagrant/dist/gmsv_curl_linux.dll"

vagrant ssh x64 -c "rm -rf curl-x64-rel && mkdir -p curl-x64-rel && cd curl-x64-rel &&
                    cmake -DCMAKE_TOOLCHAIN_FILE=toolchain-linux64.cmake -DCMAKE_BUILD_TYPE=Release /vagrant &&
                    make &&
                    cp gmsv_curl_linux64.dll /vagrant/dist/gmsv_curl_linux64.dll"
