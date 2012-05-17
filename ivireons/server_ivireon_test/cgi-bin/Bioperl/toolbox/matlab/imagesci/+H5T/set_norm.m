function set_norm(type_id, norm)
%H5T.set_norm  Set mantissa normalization of floating-pint datatype.
%   H5T.set_norm(type_id, norm) sets the mantissa normalization of a
%   floating-point datatype. Valid normalization types are:
%   H5T_NORM_IMPLIED, H5T_NORM_MSBSET, or H5T_NORM_NONE.
%
%   Example:
%       type_id = H5T.copy('H5T_NATIVE_FLOAT');
%       norm_type = H5ML.get_constant_value('H5T_NORM_MSBSET');
%       H5T.set_norm(type_id,norm_type);
%
%   See also H5T, H5T.get_norm.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:24:48 $

[id] = H5ML.unwrap_ids(type_id);
H5ML.hdf5lib2('H5Tset_norm',id, norm); 
