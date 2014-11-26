# Run h5py tests
import sys
import h5py
res = h5py.run_tests(verbose=3)
sys.exit(not res.wasSuccessful())
