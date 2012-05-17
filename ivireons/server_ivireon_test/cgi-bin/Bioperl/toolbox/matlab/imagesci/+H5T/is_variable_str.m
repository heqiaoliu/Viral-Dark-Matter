function output = is_variable_str(type_id)
%H5T.is_variable_str  Determine if dataype is variable length string.
%   output = H5T.is_variable_str(type_id) returns a positive value if the
%   datatype specified by type_id is a variable-length string and zero if
%   it is not.  A negative value indicates failure.
%
%   Example:
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       dset_id = H5D.open(fid,'/g3/VLstring2D');
%       type_id = H5D.get_type(dset_id);
%       if H5T.is_variable_str(type_id) > 0
%           fprintf('variable length string\n');
%       end
%         
%   See also H5T, H5T.vlen_create, H5T.get_size, H5D.get_type.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:24:40 $

[id] = H5ML.unwrap_ids(type_id);
output = H5ML.hdf5lib2('H5Tis_variable_str',id); 
