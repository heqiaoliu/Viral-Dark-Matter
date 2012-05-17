function remove_filter(plist_id, filter)
%H5P.remove_filter  Remove filter from property list.
%   H5P.remove_filter(plist_id, filter) removes the specified filter from
%   the filter pipeline.  plist_id is the dataset creation property list
%   identifier.
%
%   See also H5P, H5P.get_filter, H5P.get_nfilters, H5P.get_filter_by_id,
%   H5P.modify_filter.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:22:33 $

id = H5ML.unwrap_ids(plist_id);
H5ML.hdf5lib2('H5Premove_filter', id, filter);            
