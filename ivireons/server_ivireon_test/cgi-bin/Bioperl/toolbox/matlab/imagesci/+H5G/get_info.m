function info = get_info(group_id)
%H5G.get_info  Return information about group.
%   info = H5G.get_info(group_id) retrieves information about the group 
%   specified by group_id.  
%
%   Example:
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       gid = H5G.open(fid,'/g2');
%       info = H5G.get_info(gid);
%       H5G.close(gid);
%       H5F.close(fid);
%     
%   See also H5G, H5G.open, H5G.create.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:20:42 $

[id] = H5ML.unwrap_ids(group_id);
info = H5ML.hdf5lib2('H5Gget_info', id );

