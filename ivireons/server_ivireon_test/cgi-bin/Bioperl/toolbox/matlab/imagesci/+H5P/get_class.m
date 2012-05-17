function plist_class = get_class(plist_id)
%H5P.get_class  Return property list class.
%   plist_class = H5P.get_class(plist_id) returns the property list class for 
%   the property list specified by plist_id. 
%
%   Example:
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       fcpl = H5F.get_create_plist(fid);
%       pclass = H5P.get_class(fcpl);
%       name = H5P.get_class_name(pclass);
%
%   See also H5P, H5P.get_class_name.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:21:51 $

id = H5ML.unwrap_ids(plist_id);
plist_class = H5ML.hdf5lib2('H5Pget_class', id);            
plist_class = H5ML.id(plist_class, 'H5Pclose_class' );
