# Run h5py tests
import sys
import unittest
suite = unittest.TestLoader().discover("h5py")
res = unittest.TextTestRunner(verbosity=3).run(suite)
sys.exit(not res.wasSuccessful())
