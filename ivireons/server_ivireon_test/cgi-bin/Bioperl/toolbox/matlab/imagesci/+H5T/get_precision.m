function output = get_precision(type_id)
%H5T.get_precision  Return precision of atomic datatype.
%   output = H5T.get_precision(type_id) returns the precision of an atomic 
%   datatype. type_id is a datatype identifier.
%
%   Example:
%        fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%        dset_id = H5D.open(fid,'/g3/integer');
%        type_id = H5D.get_type(dset_id);
%        numbits = H5T.get_precision(type_id);
%
%   See also H5T, H5T.set_precision.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:24:32 $

[id] = H5ML.unwrap_ids(type_id);
output = H5ML.hdf5lib2('H5Tget_precision',id); 
