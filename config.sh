# Define custom utilities
# Test for OSX with [ -n "$IS_OSX" ]

function build_wheel {
    source multibuild/library_builders.sh
    if [ -n "$IS_OSX" ]; then
        build_osx_wheel $@
    else
        bdist_linux_wheel $@
    fi
}

function build_osx_wheel {
    # Build dual arch wheel
    export CC=clang
    export CXX=clang++
    brew install pkg-config
    # 32-bit wheel
    export CFLAGS="-arch i386"
    mkdir wheelhouse32
    build_hdf5
    build_wheel_cmd $@
    mv wheelhouse/h5py*whl wheelhouse32
    # 64-bit wheel
    export CFLAGS="-arch x86_64"
    # Force rebuild of all libs
    rm *-stamp
    build_hdf5
    build_wheel_cmd $@
    # Fuse into dual arch wheel
    delocate-fuse wheelhouse/h5py*whl wheelhouse32/h5py*whl
}

function bdist_linux_wheel {
    build_hdf5
    # Add workaround for auditwheel bug:
    # https://github.com/pypa/auditwheel/issues/29
    local bad_lib="/usr/local/lib/libhdf5.so"
    if [ -z "$(readelf --dynamic $bad_lib | grep RUNPATH)" ]; then
        patchelf --set-rpath $(dirname $bad_lib) $bad_lib
    fi
    build_wheel_cmd $@
}


function run_tests {
    # Runs tests on installed distribution from an empty directory
    python ../run_tests.py
    if [ -n "$IS_OSX" ]; then  # Run 32-bit tests on dual arch wheel
        arch -i386 python ../run_tests.py
    fi
}
