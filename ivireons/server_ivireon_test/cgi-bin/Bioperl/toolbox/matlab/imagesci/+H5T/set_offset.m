function set_offset(type_id, offset)
%H5T.set_offset  Set bit offset of first significant bit.
%   H5T.set_offset(type_id, offset) sets the bit offset of the first 
%   significant bit. type_id is the identifier of the datatype. offset
%   specifies the number of bits of padding that appear.
%
%   Example:
%       type_id = H5T.copy('H5T_NATIVE_INT');
%       H5T.set_offset(type_id,16);
%
%   See also H5T, H5T.get_offset.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:24:49 $

[id] = H5ML.unwrap_ids(type_id);
H5ML.hdf5lib2('H5Tset_offset',id,offset); 
