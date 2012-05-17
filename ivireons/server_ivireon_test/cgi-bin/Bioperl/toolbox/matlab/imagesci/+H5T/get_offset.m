function output = get_offset(type_id)
%H5T.get_offset  Return bit offset of first significant bit.
%   offset = H5T.get_offset(type_id) returns the offset of the first 
%   significant bit. type_id is a datatype identifier.
%
%    Example:
%        fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%        dset_id = H5D.open(fid,'/g3/float');
%        type_id = H5D.get_type(dset_id);
%        offset = H5T.get_offset(type_id);
%
%   See also H5T, H5T.set_offset.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:24:29 $

[id] = H5ML.unwrap_ids(type_id);
output = H5ML.hdf5lib2('H5Tget_offset',id); 
