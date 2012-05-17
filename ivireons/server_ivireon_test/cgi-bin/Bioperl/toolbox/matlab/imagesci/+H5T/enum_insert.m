function enum_insert(type_id, name, value)
%H5T.enum_insert  Insert enumeration datatype member.
%   H5T.enum_insert(type, name, value) inserts a new enumeration datatype
%   member into the enumeration datatype specified by type. name is a text
%   string that specifies the name of the new member of the enumeration and
%   value is the value of the member.
%
%   Example:
%       parent_id = H5T.copy('H5T_NATIVE_UINT');
%       type_id = H5T.enum_create(parent_id);
%       H5T.enum_insert(type_id,'red',1);
%       H5T.enum_insert(type_id,'green',2);
%       H5T.enum_insert(type_id,'blue',3);
%       H5T.close(type_id);
%       H5T.close(parent_id);
%
%   See also H5T, H5T.enum_create.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:24:07 $

[id] = H5ML.unwrap_ids(type_id);
H5ML.hdf5lib2('H5Tenum_insert',id, name, value); 
