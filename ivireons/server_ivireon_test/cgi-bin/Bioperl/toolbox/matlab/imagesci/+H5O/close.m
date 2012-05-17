function H5Oclose(obj_id)
%H5O.close  Close object.
%   H5O.close(obj_id) closes the object specified by obj_id.
%   obj_id cannot be a dataspace, attribute, property list, or file. 
%
%   See also H5O.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $ $Date: 2010/04/15 15:21:18 $

if isa(obj_id, 'H5ML.id')
    id = obj_id.identifier;
    obj_id.identifier = -1;
else
    id = obj_id;
end
H5ML.hdf5lib2('H5Oclose', id);            


