#!/bin/bash -e

GMCURL_DIR=$(realpath $(dirname $0))

# Ensure the machines are up
{
if ! docker start gmcurl_x86; then
    docker run --name gmcurl_x86 -td -v ${GMCURL_DIR}:/vagrant registry.gitlab.steamos.cloud/steamrt/scout/sdk/i386
    docker exec gmcurl_x86 /vagrant/provision-build.sh
fi
} 2>&1 | sed 's/^/x86 |  /' &

{
if ! docker start gmcurl_x64; then
    docker run --name gmcurl_x64 -td -v ${GMCURL_DIR}:/vagrant registry.gitlab.steamos.cloud/steamrt/scout/sdk
    docker exec gmcurl_x64 /vagrant/provision-build.sh
fi
} 2>&1 | sed 's/^/x64 |  /' &

{
if ! docker start gmcurl_win; then
    docker run --name gmcurl_win -td -v ${GMCURL_DIR}:/vagrant docker.io/debian:11
    docker exec -e PROVISION_NEEDS_MINGW=1 gmcurl_win /vagrant/provision-build.sh
fi
} 2>&1 | sed 's/^/win |  /' &

wait

# Build the different configurations
{
docker exec -u vagrant -w /home/vagrant gmcurl_x86 /vagrant/build.sh linux Debug $*
docker exec -u vagrant -w /home/vagrant gmcurl_x86 /vagrant/build.sh linux Release $*
docker exec -u vagrant -w /home/vagrant gmcurl_x86 /vagrant/build.sh linux Debug static $*
docker exec -u vagrant -w /home/vagrant gmcurl_x86 /vagrant/build.sh linux Release static $*
} &

{
docker exec -u vagrant -w /home/vagrant gmcurl_x64 /vagrant/build.sh linux64 Debug $*
docker exec -u vagrant -w /home/vagrant gmcurl_x64 /vagrant/build.sh linux64 Release $*
docker exec -u vagrant -w /home/vagrant gmcurl_x64 /vagrant/build.sh linux64 Debug static $*
docker exec -u vagrant -w /home/vagrant gmcurl_x64 /vagrant/build.sh linux64 Release static $*
} &

{
docker exec -u vagrant -w /home/vagrant gmcurl_win /vagrant/build.sh win32 Debug $*
docker exec -u vagrant -w /home/vagrant gmcurl_win /vagrant/build.sh win32 Release $*
docker exec -u vagrant -w /home/vagrant gmcurl_win /vagrant/build.sh win64 Debug $*
docker exec -u vagrant -w /home/vagrant gmcurl_win /vagrant/build.sh win64 Release $*
} &

wait

# Copy out artifacts
rm -rf dist
mkdir -p dist

docker cp gmcurl_x86:/home/vagrant/gmcurl-linux-Debug/gmsv_gmcurl_linux.dll dist/gmsv_gmcurl_linux-dbg.dll
docker cp gmcurl_x86:/home/vagrant/gmcurl-linux-Release/gmsv_gmcurl_linux.dll dist/gmsv_gmcurl_linux.dll
docker cp gmcurl_x86:/home/vagrant/gmcurl-linux-Debug-static/gmsv_gmcurl_linux.dll dist/gmsv_gmcurl_linux-dbg-static.dll
docker cp gmcurl_x86:/home/vagrant/gmcurl-linux-Release-static/gmsv_gmcurl_linux.dll dist/gmsv_gmcurl_linux-static.dll

docker cp gmcurl_x64:/home/vagrant/gmcurl-linux64-Debug/gmsv_gmcurl_linux64.dll dist/gmsv_gmcurl_linux64-dbg.dll
docker cp gmcurl_x64:/home/vagrant/gmcurl-linux64-Release/gmsv_gmcurl_linux64.dll dist/gmsv_gmcurl_linux64.dll
docker cp gmcurl_x64:/home/vagrant/gmcurl-linux64-Debug-static/gmsv_gmcurl_linux64.dll dist/gmsv_gmcurl_linux64-dbg-static.dll
docker cp gmcurl_x64:/home/vagrant/gmcurl-linux64-Release-static/gmsv_gmcurl_linux64.dll dist/gmsv_gmcurl_linux64-static.dll

docker cp gmcurl_win:/home/vagrant/gmcurl-win32-Debug/gmsv_gmcurl_win32.dll dist/gmsv_gmcurl_win32-dbg.dll
docker cp gmcurl_win:/home/vagrant/gmcurl-win32-Release/gmsv_gmcurl_win32.dll dist/gmsv_gmcurl_win32.dll
docker cp gmcurl_win:/home/vagrant/gmcurl-win64-Debug/gmsv_gmcurl_win64.dll dist/gmsv_gmcurl_win64-dbg.dll
docker cp gmcurl_win:/home/vagrant/gmcurl-win64-Release/gmsv_gmcurl_win64.dll dist/gmsv_gmcurl_win64.dll
