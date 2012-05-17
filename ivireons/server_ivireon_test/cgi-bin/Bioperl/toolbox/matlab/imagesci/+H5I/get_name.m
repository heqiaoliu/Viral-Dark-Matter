function name = get_name(obj_id)
%H5I.get_name  Return name of specified object.
%   name = H5I.get_name(obj_id) returns the name of the object specified 
%   by obj_id.  If no name is attached to the object, the empty string
%   is returned.
%
%   Example:  Display the names of all the objects in the /g3 group in the
%   example file by alphabetical order.
%       plist_id = 'H5P_DEFAULT';
%       idx_type = 'H5_INDEX_NAME';
%       order = 'H5_ITER_INC';
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY',plist_id);
%       gid = H5G.open(fid,'/g3',plist_id);
%       info = H5G.get_info(gid);
%       for j = 1:info.nlinks
%           obj_id = H5O.open_by_idx(fid,'g3',idx_type,order,j-1,plist_id);
%           name = H5I.get_name(obj_id);
%           fprintf('Object %d: ''%s''.\n', j-1, name);
%           H5O.close(obj_id);
%       end
%       H5G.close(gid);
%       H5F.close(fid);
%
%   See also H5I, H5A.get_name, H5F.get_name.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $ $Date: 2010/05/13 17:39:55 $

[id] = H5ML.unwrap_ids(obj_id);
name = H5ML.hdf5lib2('H5Iget_name', id);            
