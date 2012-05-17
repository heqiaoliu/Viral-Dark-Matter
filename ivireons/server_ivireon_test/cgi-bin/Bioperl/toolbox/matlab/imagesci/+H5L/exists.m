function output = exists(loc_id,name,lapl_id)
%H5L.exists  Determine if link exists.
%   bool = H5L.exists(loc_id,name,lapl_id) checks if a link specified by
%   the pairing of an object id and name exists within a group. lapl_id is
%   a link access property list identifier.
%
%   Example:
%       plist_id = 'H5P_DEFAULT';
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY',plist_id);
%       gid = H5G.open(fid,'/g1/g1.2/g1.2.1',plist_id);
%       if H5L.exists(gid,'slink',plist_id)
%           fprintf('link exists\n');
%       else
%           fprintf('link does not exist\n');
%       end
%
%   See also H5L.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $ $Date: 2010/04/15 15:21:07 $


[id, lid] = H5ML.unwrap_ids(loc_id, lapl_id);
output = H5ML.hdf5lib2('H5Lexists', id, name, lid);            

