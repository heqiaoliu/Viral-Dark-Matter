function set_size(type_id, type_size)
%H5T.set_size  Set size of datatype in bytes.
%   H5T.set_size(type_id, type_size) sets the total size in bytes for 
%   the datatype specified by type_id.  The string 'H5T_VARIABLE' can 
%   also be used if a variable length string is desired.
%
%   Example:  create a variable length string with null termination.
%       type_id = H5T.copy('H5T_C_S1');
%       H5T.set_size(type_id,'H5T_VARIABLE');
%       H5T.set_strpad(type_id,'H5T_STR_NULLTERM');
%
%   See also H5T, H5T.get_size.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:24:54 $

[id] = H5ML.unwrap_ids(type_id);
H5ML.hdf5lib2('H5Tset_size', id, type_size);            
