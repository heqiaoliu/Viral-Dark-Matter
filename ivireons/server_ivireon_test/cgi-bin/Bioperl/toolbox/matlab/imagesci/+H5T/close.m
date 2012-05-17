function close(type_id)
%H5T.close  Close datatype.
%   H5T.close(type_id) releases the datatype specified by type_id.
%
%   See also H5T, H5A.get_type, H5D.get_type.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:23:59 $

if isa(type_id, 'H5ML.id')
    id = type_id.identifier;
    type_id.identifier = -1;
else
    id = type_id;
end
H5ML.hdf5lib2('H5Tclose', id);            
