# Define custom utilities
# Test for OSX with [ -n "$IS_OSX" ]

function pre_build {
    source multibuild/library_builders.sh
    build_hdf5
    if [ -n "$IS_OSX" ]; then
        return
    fi
    # Add workaround for auditwheel bug:
    # https://github.com/pypa/auditwheel/issues/29
    local bad_lib="/usr/local/lib/libhdf5.so"
    if [ -z "$(readelf --dynamic $bad_lib | grep RUNPATH)" ]; then
        patchelf --set-rpath $(dirname $bad_lib) $bad_lib
    fi
}

function build_wheel {
    local repo_dir=${1:-$REPO_DIR}
    if [ -z "$IS_OSX" ]; then
        build_pip_wheel "$repo_dir"
        return
    fi
    local wheelhouse=$(abspath ${WHEEL_SDIR:-wheelhouse})
    # Build dual arch wheel
    export CC=clang
    export CXX=clang++
    brew install pkg-config
    # 32-bit wheel
    export CFLAGS="-arch i386"
    local wheelhouse32=${wheelhouse}32
    mkdir -p $wheelhouse32
    build_pip_wheel "$repo_dir"
    mv ${wheelhouse}/*whl $wheelhouse32
    # 64-bit wheel
    export CFLAGS="-arch x86_64"
    # Force rebuild of all libs
    rm *-stamp
    build_pip_wheel "$repo_dir"
    # Fuse into dual arch wheel(s)
    for whl in ${wheelhouse}/*.whl; do
        delocate-fuse "$whl" "${wheelhouse32}/$(basename $whl)"
    done
}

function run_tests {
    # Runs tests on installed distribution from an empty directory
    python ../run_tests.py
    if [ -n "$IS_OSX" ]; then  # Run 32-bit tests on dual arch wheel
        arch -i386 python ../run_tests.py
    fi
}
