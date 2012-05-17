function close(plist_id)
%H5P.close  Close property list.
%   H5P.close(plist_id) terminates access to the property list specified by 
%   plist_id. 
%
%   See also H5P, H5P.create.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:21:32 $

if isa(plist_id, 'H5ML.id')
    id = plist_id.identifier;
    plist_id.identifier = -1;
else
    id = plist_id;
end
H5ML.hdf5lib2('H5Pclose', id);            
