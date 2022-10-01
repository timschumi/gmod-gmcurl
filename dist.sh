#!/bin/bash -e

# Ensure the machines are up
vagrant up

# Empty dist folder
rm -rf dist
mkdir -p dist

# Build the different configurations
vagrant ssh x86 -c "rm -rf gmcurl-x86-dbg && mkdir -p gmcurl-x86-dbg && cd gmcurl-x86-dbg &&
                    cmake -DCMAKE_TOOLCHAIN_FILE=toolchain-linux32.cmake -DCMAKE_BUILD_TYPE=Debug /vagrant &&
                    make &&
                    cp gmsv_gmcurl_linux.dll /vagrant/dist/gmsv_gmcurl_linux-dbg.dll"

vagrant ssh x64 -c "rm -rf gmcurl-x64-dbg && mkdir -p gmcurl-x64-dbg && cd gmcurl-x64-dbg &&
                    cmake -DCMAKE_TOOLCHAIN_FILE=toolchain-linux64.cmake -DCMAKE_BUILD_TYPE=Debug /vagrant &&
                    make &&
                    cp gmsv_gmcurl_linux64.dll /vagrant/dist/gmsv_gmcurl_linux64-dbg.dll"

vagrant ssh x86 -c "rm -rf gmcurl-x86-rel && mkdir -p gmcurl-x86-rel && cd gmcurl-x86-rel &&
                    cmake -DCMAKE_TOOLCHAIN_FILE=toolchain-linux32.cmake -DCMAKE_BUILD_TYPE=Release /vagrant &&
                    make &&
                    cp gmsv_gmcurl_linux.dll /vagrant/dist/gmsv_gmcurl_linux.dll"

vagrant ssh x64 -c "rm -rf gmcurl-x64-rel && mkdir -p gmcurl-x64-rel && cd gmcurl-x64-rel &&
                    cmake -DCMAKE_TOOLCHAIN_FILE=toolchain-linux64.cmake -DCMAKE_BUILD_TYPE=Release /vagrant &&
                    make &&
                    cp gmsv_gmcurl_linux64.dll /vagrant/dist/gmsv_gmcurl_linux64.dll"
