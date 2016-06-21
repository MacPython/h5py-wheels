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
    # Use local freetype for versions which support it
    source multibuild/library_builders.sh
    build_hdf5
}

function run_tests {
    # Runs tests on installed distribution from an empty directory
    python ../run_tests.py
}
