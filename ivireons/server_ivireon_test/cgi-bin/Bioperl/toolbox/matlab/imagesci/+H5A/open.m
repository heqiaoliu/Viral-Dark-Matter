function attr_id = open(obj_id,attr_name,acpl_id)
%H5A.open  Open attribute. 
%   attr_id = H5A.open(obj_id,attr_name,aapl_id) opens an attribute for an
%   object specified by a parent object identifier and attribute name.  An 
%   additional attribute access property list should be given as 
%   'H5P_DEFAULT'.
%
%   Example:  
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       gid = H5G.open(fid,'/');
%       attr_id = H5A.open(gid,'attr1','H5P_DEFAULT');
%       H5A.close(attr_id);
%       H5G.close(gid);
%       H5F.close(fid);
%
%   See also H5A, H5A.close, H5A.open_by_name, H5A.open_by_idx.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:19:42 $

[id, a_id] = H5ML.unwrap_ids(obj_id, acpl_id);
id = H5ML.hdf5lib2('H5Aopen', id, attr_name, a_id);
attr_id = H5ML.id(id, 'H5Aclose');

