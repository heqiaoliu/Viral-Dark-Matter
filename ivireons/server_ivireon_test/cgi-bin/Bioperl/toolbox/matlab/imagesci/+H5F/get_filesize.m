function size = get_filesize(file_id)
%H5F.get_filesize  Return size of HDF5 file.
%   size = H5F.get_filesize(file_id) returns the size of the HDF5 file 
%   specified by file_id
%
%   See also H5F.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:20:23 $

id = H5ML.unwrap_ids(file_id);
size = H5ML.hdf5lib2('H5Fget_filesize', id);            

