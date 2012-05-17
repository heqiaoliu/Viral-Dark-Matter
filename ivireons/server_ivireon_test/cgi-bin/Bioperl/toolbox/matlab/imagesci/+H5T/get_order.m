function output = get_order(type_id)
%H5T.get_order  Return byte order of atomic datatype.
%   output = H5T.get_order(type_id) returns the byte order of an atomic 
%   datatype. type_id is a datatype identifier. Possible return values are
%   the constant values corresponding to the following strings:
% 
%       'H5T_ORDER_LE' 
%       'H5T_ORDER_BE'
%       'H5T_ORDER_VAX'
%
%   Example:
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       dset_id = H5D.open(fid,'/g2/dset2.2');
%       type_id = H5D.get_type(dset_id);
%       switch(H5T.get_order(type_id))
%           case H5ML.get_constant_value('H5T_ORDER_LE')
%               fprintf('little endian\n');
%           case H5ML.get_constant_value('H5T_ORDER_BE')
%               fprintf('big endian\n');
%           case H5ML.get_constant_value('H5T_ORDER_VAX')
%               fprintf('vax\n');
%       end
%
%   See also H5T, H5T.set_order, H5ML.get_constant_value.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:24:30 $

[id] = H5ML.unwrap_ids(type_id);
output = H5ML.hdf5lib2('H5Tget_order',id); 
