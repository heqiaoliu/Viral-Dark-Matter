function output = get_tag(type_id)
%H5T.get_tag  Return tag associated with opaque datatype.
%   tag = H5T.get_tag(type_id) returns the tag associated with the opaque
%   datatype specified by type_id.
%
%   Example:
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       dset_id = H5D.open(fid,'/g3/opaque');
%       dtype_id = H5D.get_type(dset_id);
%       tag = H5T.get_tag(dtype_id);
%
%   See also H5T, H5T.set_tag.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:24:38 $

[id] = H5ML.unwrap_ids(type_id);
output = H5ML.hdf5lib2('H5Tget_tag',id); 
