function set_nbit(plist_id)
%H5P.set_nbit  Setup use of N-Bit filter.
%   H5P.set_nbit(plist_id) sets the N-Bit filter, H5Z_FILTER_NBIT, in 
%   the dataset creation property list plist_id.
%
%   See also H5P.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:23:15 $

[id] = H5ML.unwrap_ids(plist_id);
H5ML.hdf5lib2('H5Pset_nbit',id);


