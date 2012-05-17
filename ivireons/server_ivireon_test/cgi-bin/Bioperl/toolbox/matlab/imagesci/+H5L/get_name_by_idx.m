function name = get_name_by_idx(varargin)
%H5L.get_name_by_idx  Retrieve information about link specified by index.
%   name = H5L.get_name_by_idx(loc_id,group_name,idx_type,order,n,lapl_id)
%   retrieves information about a link at index n present in the group
%   group_name at location loc_id. lapl_id specifies the link access
%   property list for querying the group.
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
%   Example:
%       plist_id = 'H5P_DEFAULT';
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY',plist_id);
%       idx_type = 'H5_INDEX_NAME';
%       order = 'H5_ITER_DEC';
%       name = H5L.get_name_by_idx(fid,'g3',idx_type,order,0,plist_id);
%       H5F.close(fid);
%
%   See also H5L.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2010/04/15 15:21:09 $

[varargin{:}] = H5ML.unwrap_ids(varargin{:});
name = H5ML.hdf5lib2('H5Lget_name_by_idx', varargin{:});            

