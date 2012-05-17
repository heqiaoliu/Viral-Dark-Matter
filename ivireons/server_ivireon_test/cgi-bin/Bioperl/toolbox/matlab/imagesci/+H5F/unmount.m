function unmount(loc_id, name)
%H5F.unmount  Unmount file or group from mount point.
%   H5F.unmount(loc_id, name) dissassociates the file or group specified by
%   loc_id from the mount point specified by name. loc_id can be a file or
%   group identifier. 
%
%   See also H5F, H5F.mount.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:20:37 $

id = H5ML.unwrap_ids(loc_id);
H5ML.hdf5lib2('H5Funmount', id, name);            
