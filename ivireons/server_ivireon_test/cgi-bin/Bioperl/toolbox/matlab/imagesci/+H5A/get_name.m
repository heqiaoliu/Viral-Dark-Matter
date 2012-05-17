function attr_name = get_name(attr_id)
%H5A.get_name  Retrieve attribute name.
%   attr_name = H5A.get_name(attr_id) returns the name of the attribute
%   specified by attr_id. 
%
%   Example:
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       gid = H5G.open(fid,'/g1/g1.1');
%       idx_type = 'H5_INDEX_NAME';
%       order = 'H5_ITER_INC';
%       aapl = 'H5P_DEFAULT';
%       lapl = 'H5P_DEFAULT';
%       attr_id = H5A.open_by_idx(gid,'dset1.1.1',idx_type,order,0,aapl,lapl);
%       name = H5A.get_name(attr_id);
%       H5A.close(attr_id);
%       H5G.close(gid);
%       H5F.close(fid);
%
%   See also H5A, H5A.open_by_idx.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:19:37 $

id = H5ML.unwrap_ids(attr_id);
attr_name = H5ML.hdf5lib2('H5Aget_name', id);            
