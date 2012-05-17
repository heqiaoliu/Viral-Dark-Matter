function plist_id = get_create_plist(file_id)
%H5F.get_create_plist  Return file creation property list.
%   fcpl_id = H5F.get_create_plist(file_id) returns a file creation 
%   property list identifier identifying the creation properties used to 
%   create the file specified by file_id.
%
%   Example:
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       fcpl = H5F.get_create_plist(fid);
%       H5P.close(fcpl);
%       H5F.close(fid);
%        
%   See also H5F, H5F.get_access_plist.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:20:22 $

id = H5ML.unwrap_ids(file_id);
plist_id = H5ML.hdf5lib2('H5Fget_create_plist', id);            
plist_id = H5ML.id(plist_id,'H5Pclose');
