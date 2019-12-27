#!/bin/bash

# Simple script to create the Makefile and build

# export PATH="$PATH:/usr/local/cuda/bin/"
set -eu -o pipefail

function cmd_pref() {
    if type -p "$2" > /dev/null; then
        eval "$1=$2"
    else
        eval "$1=$3"
    fi
}

# If a g-prefixed version of the command exists, use it preferentially.
function gprefix() {
    cmd_pref "$1" "g$2" "$2"
}


# Allow user overrides to $MAKE. Typical usage for users who need it:
#   MAKE=gmake ./build.sh -j$(nproc)
if [[ -z "${MAKE-}" ]]; then
    MAKE=make
fi

# Allow overrides to $BUILD and $HOST for porters. Most users will not need it.
#   BUILD=i686-pc-linux-gnu ./build.sh
if [[ -z "${BUILD-}" ]]; then
    ls
    BUILD="$(./depends/config.guess)"
fi
if [[ -z "${HOST-}" ]]; then
    HOST="${BUILD}"
fi

# Allow users to set arbitrary compile flags. Most users will not need this.
if [[ -z "${CONFIGURE_FLAGS-}" ]]; then
    CONFIGURE_FLAGS=""
fi

make distclean || echo clean

rm -f Makefile.in
rm -f config.status
HOST="${HOST}" BUILD="${BUILD}" "${MAKE}" "$@" -C ./depends/ V=1
./autogen.sh || echo done

extracflags="-march=native -D_REENTRANT -falign-functions=16 -falign-jumps=16 -falign-labels=16"
CONFIG_SITE="${PWD}/depends/${HOST}/share/config.site" ./configure CXXFLAGS="-O2 $extracflags"

"$MAKE" "$@" V=1
