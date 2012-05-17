function modify_filter(plist_id, filter_id, flags, cd_values)
%H5P.modify_filter  Modify filter in pipeline.
%   H5P.modify_filter(plist_id, filter_id, flags, cd_values) modifies the 
%   specified filter in the filter pipeline. plist_id is a property list 
%   identifier. flags is a bit vector specifying certain general properties
%   of the filter.  cd_values specifies auxiliary data for the filter.
%
%   See also H5P, H5P.get_filter, H5P.get_nfilters, H5P.get_filter_by_id,
%   H5P.remove_filter.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:22:32 $

[p_id, f_id] = H5ML.unwrap_ids(plist_id, filter_id);
H5ML.hdf5lib2('H5Pmodify_filter', p_id, f_id, flags, cd_values);

