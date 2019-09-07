# Run h5py tests, check for expected filters
from __future__ import print_function
import sys
import h5py

default_filters = set(('shuffle', 'gzip', 'fletcher32', 'scaleoffset'))
szip_filters = default_filters.union(('szip',))

good = bool(h5py.run_tests())

decode_missing = szip_filters.difference(h5py.filters.decode)
if decode_missing:
    print('Missing decode filters', ' '.join(decode_missing))
    good = False
encode_missing = default_filters.difference(h5py.filters.encode)
if encode_missing:
    print('Missing encode filters', ' '.join(encode_missing))
    good = False
sys.exit(not good)
