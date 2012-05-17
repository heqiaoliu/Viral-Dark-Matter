function attr_id = open_by_name(varargin)
%H5A.open_by_name  Open attribute specified by name. 
%   attr_id = H5A.open_by_name(loc_id,obj_name,attr_name,aapl_id,lapl_id)
%   opens an existing attribute attr_name attached to an object specified
%   by its location loc_id and name obj_name. aapl_id specifies the
%   attribute access property list and lapl_id specifies the link access
%   property list. 
% 
%   Example:
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       gid = H5G.open(fid,'/g1/g1.1');
%       aapl_id = 'H5P_DEFAULT';
%       lapl_id = 'H5P_DEFAULT';
%       attr_id = H5A.open_by_name(gid,'dset1.1.1','attr1',aapl_id,lapl_id);
%       H5A.close(attr_id);
%       H5G.close(gid);
%       H5F.close(fid);
%
%   See also H5A, H5A.close, H5A.open, H5A.open_by_idx.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4.2.1 $ $Date: 2010/07/23 15:40:02 $

[varargin{:}] = H5ML.unwrap_ids(varargin{:});
raw_attr_id = H5ML.hdf5lib2('H5Aopen_by_name', varargin{:});            
attr_id = H5ML.id(raw_attr_id,'H5Aclose');

