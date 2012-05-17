function obj_id = open(loc_id,relname,lapl_id)
%H5O.open  Open specified object.
%   obj_id = H5O.open(loc_id,relname,lapl_id) opens an object specified by
%   location identifier and relative path name.  lapl_id is the link access 
%   property list associated with the link pointing to the object. If 
%   default link access properties are appropriate, this can be passed in 
%   as 'H5P_DEFAULT'. 
%
%   Example:
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       obj_id = H5O.open(fid,'g3','H5P_DEFAULT');
%       H5O.close(obj_id);
%       H5F.close(fid);
%
%   See also H5O, H5O.open_by_idx, H5O.close.
   
%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $ $Date: 2010/04/15 15:21:24 $

[id, lid] = H5ML.unwrap_ids(loc_id, lapl_id);
output = H5ML.hdf5lib2('H5Oopen', id, relname, lid);
obj_id = H5ML.id(output,'H5Oclose');


