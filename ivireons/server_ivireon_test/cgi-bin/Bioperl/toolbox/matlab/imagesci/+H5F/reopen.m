function new_file_id = reopen(file_id)
%H5F.reopen  Reopen HDF5 file.
%   new_file_id = H5F.reopen(file_id) returns a new file identifier for the 
%   already open HDF5 file specified by file_id.  
%
%   See also H5F, H5F.open.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5.2.1 $ $Date: 2010/07/23 15:40:04 $

id = H5ML.unwrap_ids(file_id);
raw_file_id = H5ML.hdf5lib2('H5Freopen', id);            
new_file_id = H5ML.id(raw_file_id,'H5Fclose');
