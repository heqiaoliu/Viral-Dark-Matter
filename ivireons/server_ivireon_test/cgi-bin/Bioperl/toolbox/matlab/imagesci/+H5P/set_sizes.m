function set_sizes(fcpl, sizeof_addr, sizeof_size)
%H5P.set_sizes  Set byte size of offsets and lengths.
%   H5P.set_sizes(plist_id, sizeof_addr, sizeof_size) sets the byte size of
%   the offsets and lengths used to address objects in an HDF5 file.
%   plist_id is a file creation property list.
%
%   See also H5P, H5P.get_sizes.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:23:24 $

id = H5ML.unwrap_ids(fcpl);
H5ML.hdf5lib2('H5Pset_sizes', id, sizeof_addr, sizeof_size);            
