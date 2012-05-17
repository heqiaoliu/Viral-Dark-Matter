function pclass_obj_id = get_class_parent(pclass_id)
%H5P.get_class_parent  Return identifier for parent class.
%   pclass_obj_id = H5P.get_class_parent(pclass_id) returns an identifier 
%   to the parent class object of the property class specified by 
%   pclass_id. 
%
%   Example:
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       fcpl = H5F.get_create_plist(fid);
%       fcpl_class = H5P.get_class(fcpl);
%       parent_class = H5P.get_class_parent(fcpl_class);
%       name = H5P.get_class_name(parent_class);
%
%   See also H5P, H5P.get_class, H5P.get_class_name.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:21:53 $

id = H5ML.unwrap_ids(pclass_id);
pclass_obj_id = H5ML.hdf5lib2('H5Pget_class_parent', id);            
pclass_obj_id = H5ML.id(pclass_obj_id,'H5Pclose_class');
