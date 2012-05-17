function plist_copy = copy(plist_id)
%H5P.copy  Return copy of property list.
%   plist_copy = H5P.copy(plist_id) returns a copy of the property list
%   specified by plist_id.
%
%   Example:  Make a copy of the file creation property list for
%   example.h5.
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       fcpl = H5F.get_create_plist(fid);
%       fcpl2 = H5P.copy(fcpl);
%       
%
%   See also H5P.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:21:34 $

id = H5ML.unwrap_ids(plist_id);
plist_copy = H5ML.hdf5lib2('H5Pcopy', id);            
plist_copy = H5ML.id(plist_copy,'H5Pclose');

