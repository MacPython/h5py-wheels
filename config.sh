# Define custom utilities
# Test for OSX with [ -n "$IS_OSX" ]

function build_wheel {
    if [ -z "$IS_OSX" ]; then
        build_linux_wheel $@
    else
        build_osx_wheel $@
    fi
}

function build_libs {
    build_hdf5
}

function build_linux_wheel {
    source multibuild/library_builders.sh
    build_libs
    # Add workaround for auditwheel bug:
    # https://github.com/pypa/auditwheel/issues/29
    local bad_lib="/usr/local/lib/libhdf5.so"
    if [ -z "$(readelf --dynamic $bad_lib | grep RUNPATH)" ]; then
        patchelf --set-rpath $(dirname $bad_lib) $bad_lib
    fi
    build_pip_wheel $@
}

function build_osx_wheel {
    local repo_dir=${1:-$REPO_DIR}
    export CC=clang
    export CXX=clang++
    install_pkg_config
    # Build libraries
    source multibuild/library_builders.sh
    export ARCH_FLAGS="-arch x86_64"
    export CFLAGS=$ARCH_FLAGS
    export CXXFLAGS=$ARCH_FLAGS
    export FFLAGS=$ARCH_FLAGS
    export LDFLAGS=$ARCH_FLAGS
    build_libs
    # Build wheel
    export LDFLAGS="$ARCH_FLAGS -Wall -undefined dynamic_lookup -bundle"
    export LDSHARED="$CC $LDFLAGS"
    build_pip_wheel "$repo_dir"
}

function run_tests {
    # Runs tests on installed distribution from an empty directory
    python ../run_tests.py
}
