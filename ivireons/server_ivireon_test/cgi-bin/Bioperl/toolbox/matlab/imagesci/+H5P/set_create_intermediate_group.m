function set_create_intermediate_group(lcpl_id,flag)
%H5P.set_create_intermediate_group  Set creation of intermediate groups.
%   H5P.set_create_intermediate_group(lcpl_id,flag) specifies in the 
%   link creation property list lcpl_id whether to create missing 
%   intermediate groups.
%
%   Example:  Enable the creation of intermediate groups.
%       plist_id = 'H5P_DEFAULT';
%       fid = H5F.create('myfile.h5','H5F_ACC_TRUNC',plist_id,plist_id);
%       lcpl = H5P.create('H5P_LINK_CREATE');
%       H5P.set_create_intermediate_group(lcpl,1);
%       gid = H5G.create(fid,'/a/b/c/d',lcpl,plist_id,plist_id);
%       H5G.close(gid);
%       H5F.close(fid);
%
%   See also H5P, H5P.get_create_intermediate_group.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:22:46 $

[id] = H5ML.unwrap_ids(lcpl_id);
H5ML.hdf5lib2('H5Pset_create_intermediate_group', id, flag);            



