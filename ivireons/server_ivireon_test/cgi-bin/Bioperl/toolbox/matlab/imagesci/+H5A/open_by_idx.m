function attr_id = open_by_idx(varargin)
%H5A.open_by_idx  Open attribute specified by index.
%   attr_id = H5A.open_by_idx(loc_id,obj_name,idx_type,order,n,aapl_id,lapl_id)
%   opens an existing attribute at index n attached to an object specified
%   by its location loc_id and name obj_name. aapl_id specifies the
%   attribute access property list and lapl_id specifies the link access
%   property list. 
% 
%   idx_type is the type of index and valid values include the following: 
% 
%      'H5_INDEX_NAME'      - an alpha-numeric index by attribute name
%      'H5_INDEX_CRT_ORDER' - an index by creation order
%
%   order specifies the index traversal order. Valid values include the
%   following: 
% 
%      'H5_ITER_INC'    - iteration is from beginning to end
%      'H5_ITER_DEC'    - iteration is from end to beginning
%      'H5_ITER_NATIVE' - iteration is in the fastest available order
%
%   Example:  loop through a set of dataset attributes in reverse
%   alphabetical order
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       gid = H5G.open(fid,'/g1/g1.1');
%       dsetId = H5D.open(fid,'/g1/g1.1/dset1.1.1');
%       info = H5O.get_info(dsetId);
%       aapl = 'H5P_DEFAULT';
%       lapl = 'H5P_DEFAULT';
%       for idx = 0:info.num_attrs-1
%           attr_id =H5A.open_by_idx(gid,'dset1.1.1','H5_INDEX_NAME','H5_ITER_DEC',idx,aapl,lapl);
%           fprintf('attribute name:  %s\n', H5A.get_name(attr_id));
%           H5A.close(attr_id);
%       end
%       H5G.close(gid);
%       H5F.close(fid);
%
%   See also H5A, H5A.open, H5A.open_by_name, H5A.close.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4.2.1 $ $Date: 2010/07/23 15:40:01 $

[varargin{:}] = H5ML.unwrap_ids(varargin{:});
raw_attr_id = H5ML.hdf5lib2('H5Aopen_by_idx', varargin{:});            
attr_id = H5ML.id(raw_attr_id,'H5Aclose');
