function info = get_info(attr_id)
%H5A.get_info  Retrieve information about attribute.
%   info = H5A.get_info(attr_id) returns information about an attribute
%   specified by attr_id.  
%
%   Example:  
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       gid = H5G.open(fid,'/');
%       attr_id = H5A.open(gid,'attr1','H5P_DEFAULT');
%       info = H5A.get_info(attr_id);
%       H5A.close(attr_id);
%       H5G.close(gid);
%       H5F.close(fid);
%
%   See also H5A, H5A.open.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $ $Date: 2010/04/15 15:19:36 $

id = H5ML.unwrap_ids(attr_id);
info = H5ML.hdf5lib2('H5Aget_info', id);            

