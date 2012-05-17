function output = copy(space_id)
%H5S.copy  Create copy of dataspace.
%   output = H5S.copy(space_id) creates a new dataspace which is an exact copy
%   of the dataspace identified by space_id. output is a dataspace identifier.
%
%   Example:
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       dset_id = H5D.open(fid,'/g2/dset2.1');
%       space1_id = H5D.get_space(dset_id);
%       space2_id = H5S.copy(space1_id);
%       [~,dims1] = H5S.get_simple_extent_dims(space1_id)
%       [~,dims2] = H5S.get_simple_extent_dims(space2_id)
%
%   See also H5S, H5D.get_space, H5S.get_simple_extent_dims.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:23:34 $

[id] = H5ML.unwrap_ids(space_id);
output = H5ML.hdf5lib2('H5Scopy', id);            
output = H5ML.id(output,'H5Sclose');
