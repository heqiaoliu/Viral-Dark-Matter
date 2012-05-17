function output = H5Tget_native_type(type_id, direction)
%H5T.get_native_type  Return native datatype of specified datatype.
%   output = H5T.get_native_type(type_id, direction) returns the equivalent 
%   native datatype for the dataset datatype specified in type_id. direction
%   indicates the order in which the library searches for a native datatype match: 
%   match: H5T_DIR_ASCEND or H5T_DIR_DESCEND.
%
%   See also H5T.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:24:26 $

[id] = H5ML.unwrap_ids(type_id);
output = H5ML.hdf5lib2('H5Tget_native_type',id, direction); 
output = H5ML.id(output,'H5Tclose');
