# Define custom utilities
# Test for OSX with [ -n "$IS_OSX" ]

function pre_build {
    # Any stuff that you need to do before you start building the wheels
    # Runs in the root directory of this repository.
    if [ -n "$IS_OSX" ]; then
        export CC=clang
        export CXX=clang++
        brew install pkg-config
    fi
    source multibuild/library_builders.sh
    build_hdf5
    # Add workaround for auditwheel bug:
    # https://github.com/pypa/auditwheel/issues/29
    if [ -z "$IS_OSX" ]; then
        local bad_lib="/usr/local/lib/libhdf5.so"
        if [ -z "$(readelf --dynamic $bad_lib | grep RUNPATH)" ]; then
            patchelf --set-rpath $(dirname $bad_lib) $bad_lib
        fi
    fi
}

function run_tests {
    # Runs tests on installed distribution from an empty directory
    python ../run_tests.py
}
