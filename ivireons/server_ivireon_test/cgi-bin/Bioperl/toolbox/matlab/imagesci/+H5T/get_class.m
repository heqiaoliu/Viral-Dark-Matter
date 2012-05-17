function output = get_class(type_id)
%H5T.get_class  Return datatype class identifier.
%   class_id = H5T.get_class(type_id) returns the datatype class identifier
%   of the datatype specified by type_id.
%
%   Valid class identifiers include
%
%       H5T_INTEGER
%       H5T_FLOAT
%       H5T_STRING
%       H5T_BITFIELD
%       H5T_OPAQUE
%       H5T_COMPOUND
%       H5T_ENUM
%       H5T_VLEN
%       H5T_ARRAY
%
%   Example:
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       dset_id = H5D.open(fid,'/g3/enum');
%       type_id = H5D.get_type(dset_id);
%       class_id = H5T.get_class(type_id);
%       switch(class_id)
%           case H5ML.get_constant_value('H5T_INTEGER')
%               fprintf('Integer\n');
%           case H5ML.get_constant_value('H5T_FLOAT')
%               fprintf('Floating point\n');
%           case H5ML.get_constant_value('H5T_STRING')
%               fprintf('String\n');
%           case H5ML.get_constant_value('H5T_BITFIELD')
%               fprintf('Bitfield\n');
%           case H5ML.get_constant_value('H5T_OPAQUE')
%               fprintf('Opaque\n');
%           case H5ML.get_constant_value('H5T_COMPOUND')
%               fprintf('Compound'\n');
%           case H5ML.get_constant_value('H5T_ENUM')
%               fprintf('Enumerated\n');
%           case H5ML.get_constant_value('H5T_VLEN')
%               fprintf('Variable length\n');
%           case H5ML.get_constant_value('H5T_ARRAY')
%               fprintf('Array\n');
%       end
%
%   See also H5T, H5ML.get_constant_value.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:24:14 $

[id] = H5ML.unwrap_ids(type_id);
output = H5ML.hdf5lib2('H5Tget_class',id); 
