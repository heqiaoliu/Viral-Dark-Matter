function super_type_id = get_super(type_id)
%H5T.get_super  Return bad datatype.
%   super_type_id = H5T.get_super(type_id) returns the base datatype from
%   which the datatype type specified by type_id is derived.
%
%   Example:  retrieve the base datatype for an enumerated dataset.
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       dset_id = H5D.open(fid,'/g3/enum');
%       dtype_id = H5D.get_type(dset_id);
%       super_type_id = H5T.get_super(dtype_id);

%   See also H5T.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5.2.1 $ $Date: 2010/07/23 15:40:06 $

[id] = H5ML.unwrap_ids(type_id);
raw_super_type_id = H5ML.hdf5lib2('H5Tget_super',id); 
super_type_id = H5ML.id(raw_super_type_id,'H5Tclose');
