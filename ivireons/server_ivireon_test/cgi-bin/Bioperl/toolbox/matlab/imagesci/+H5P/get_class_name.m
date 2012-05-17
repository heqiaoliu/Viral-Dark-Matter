function classname = get_class_name(pclass_id)
%H5P.get_class_name  Return name of property list class.
%   classname = H5P.get_class_name(pclass_id) retrieves the name of the 
%   generic property list class. classname is a text string.  If no
%   class is found, the empty string is returned.
%
%   Example:
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       fcpl = H5F.get_create_plist(fid);
%       pclass = H5P.get_class(fcpl);
%       name = H5P.get_class_name(pclass);
%
%   See also H5P, H5P.get_class.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:21:52 $

id = H5ML.unwrap_ids(pclass_id);
classname = H5ML.hdf5lib2('H5Pget_class_name', id);            
