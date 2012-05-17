function close_class(pclass_id)
%H5P.close_class  Close property list class.
%   H5P.close_class(class) closes the property list class specified by 
%   pclass_id.
%
%   See also H5P.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:21:33 $

if isa(pclass_id, 'H5ML.id')
    id = pclass_id.identifier;
    pclass_id.identifier = -1;
else
    id = pclass_id;
end
H5ML.hdf5lib2('H5Pclose_class', id);            
