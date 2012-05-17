function type_size = get_size(type_id)
%H5T.get_size  Return size of datatype in bytes.
%   type_size = H5T.get_size(type_id) returns the size of a datatype in
%   bytes. type_id is a datatype identifier.
%
%   Example:  determine the size of the datatype for a specific dataset.
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       dset_id = H5D.open(fid,'/g3/bitfield2D');
%       type_id = H5D.get_type(dset_id);
%       type_size = H5T.get_size(type_id);
%
%   See also H5T, H5T.set_size, H5D.get_type.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:24:34 $

[id] = H5ML.unwrap_ids(type_id);
type_size = H5ML.hdf5lib2('H5Tget_size',id); 
