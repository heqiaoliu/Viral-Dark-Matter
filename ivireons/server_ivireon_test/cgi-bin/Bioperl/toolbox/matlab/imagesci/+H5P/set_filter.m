function set_filter(plist_id, filter, flags, cd_values)
%H5P.set_filter  Add filter to filter pipeline.
%   H5P.set_filter(plist_id, filter, flags, cd_values) adds the specified
%   filter and corresponding properties to the end of an output filter
%   pipeline. plist_id is a property list identifier. filter is a filter
%   identifier and should correspond to on of the following values.
%
%       H5P_FILTER_DEFLATE
%       H5P_FILTER_SHUFFLE
%       H5P_FILTER_FLETCHER32
%
%   flags is a bit vector specifying properties of the filter.  cd_values 
%   is an array that contains auxiliary data for the filter.
%
%   See also H5P, H5P.set_deflate, H5P.set_fletcher32, H5P.set_shuffle.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:23:02 $

id = H5ML.unwrap_ids(plist_id);
H5ML.hdf5lib2('H5Pset_filter', id, filter, flags, cd_values);            
