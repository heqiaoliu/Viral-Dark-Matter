function output = get_ebias(type_id)
%H5T.get_ebias  Return exponent bias of floating point type.
%   output = H5T.get_ebias(type_id) returns the exponent bias of a 
%   floating-point type. type_id is datatype identifier.
%
%   Example:
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       dset_id = H5D.open(fid,'/g3/float');
%       type_id = H5D.get_type(dset_id);
%       ebias = H5T.get_ebias(type_id);
%
%   See also H5T, H5T.set_ebias.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:24:17 $

[id] = H5ML.unwrap_ids(type_id);
output = H5ML.hdf5lib2('H5Tget_ebias',id); 
