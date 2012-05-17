function output = get_array_ndims(type_id)
%H5T.get_array_ndims  Return rank of array datatype.
%   output = H5T.get_array_ndims(type_id) returns the rank, the number of 
%   dimensions, of an array datatype object.
%
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       dset_id = H5D.open(fid,'/g3/array2D');
%       type_id = H5D.get_type(dset_id);
%       ndims = H5T.get_array_ndims(type_id);
%
%   See also H5T, H5T.get_array_dims.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:24:13 $

[id] = H5ML.unwrap_ids(type_id);
output = H5ML.hdf5lib2('H5Tget_array_ndims',id); 
