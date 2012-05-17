function [flags, cd_values, name, filter_config] = get_filter_by_id(plist_id, idx)
%H5P.get_filter_by_id  Return information about specified filter.
%   [flags cd_values name filter_config] = H5P.get_filter_by_id(plist_id,idx)
%   returns information about the filter specified by the filter id, idx. 
%
%   See also H5P, H5P.get_filter, H5P.get_nfilters, H5P.modify_filter,
%   H5P.remove_filter.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:22:09 $

[id] = H5ML.unwrap_ids(plist_id);
[flags, cd_values, name, filter_config] = H5ML.hdf5lib2('H5Pget_filter_by_id', id, idx);            
