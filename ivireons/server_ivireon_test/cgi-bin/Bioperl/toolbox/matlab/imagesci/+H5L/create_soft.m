function create_soft(varargin)
%H5L.create_soft  Create soft link.
%   H5L.create_soft(target_path,link_loc_id,link_name,lcpl_id,lapl_id) 
%   creates a new soft link to an object in an HDF5 file. The new link may 
%   be one of many that point to that object.  target_path specifies the 
%   path to the target object, i.e., the object that the new soft link 
%   points to. target_path can be anything and is interpreted at lookup 
%   time. This target_path may be absolute in the file or relative to 
%   link_loc_id.
%
%   link_loc_id and link_name specify the location and name, respectively,
%   of the new link. link_name is interpreted relative to link_loc_id.
%
%   lcpl_id and lapl_id are the link creation and access property lists
%   associated with the new link.
%
%   Example:
%       plist_id = 'H5P_DEFAULT';
%       fid = H5F.create('myfile.h5','H5F_ACC_TRUNC',plist_id,plist_id);
%       gid1 = H5G.create(fid,'/g1',plist_id,plist_id,plist_id);
%       gid3 = H5G.create(gid1,'g3',plist_id,plist_id,plist_id);
%       gid2 = H5G.create(fid,'/g2',plist_id,plist_id,plist_id);
%       H5L.create_soft('/g1/g3',gid2,'g4',plist_id,plist_id);
%       H5G.close(gid3);
%       H5G.close(gid2);
%       H5G.close(gid1);
%       H5F.close(fid);
%
%   See also H5L, H5L.create_hard.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $ $Date: 2010/04/15 15:21:05 $


[varargin{:}] = H5ML.unwrap_ids(varargin{:});
H5ML.hdf5lib2('H5Lcreate_soft', varargin{:});            

