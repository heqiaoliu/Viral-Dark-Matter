function unlink(loc_id, name)
%H5G.unlink  Remove link to object from group.
%
%   H5G.unlink is not recommended.  Use H5L.delete instead.
%
%   H5G.unlink(loc_id, name) removes the object specified by name from the
%   file or group specified by loc_id.
%
%   The HDF5 group has deprecated the use of this function.
%
%   See also H5G, H5L.delete.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.7 $ $Date: 2010/05/13 17:39:51 $

id = H5ML.unwrap_ids(loc_id);
H5ML.hdf5lib2('H5Gunlink', id, name);            
