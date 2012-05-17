function num_files = get_external_count(plist_id)
%H5P.get_external_count  Return count of external files.
%   num_files = H5P.get_external_count(plist_id) returns the number of
%   external files for the dataset creation property list, plist_id.
%
%   See also H5P, H5P.get_external.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:22:00 $

id = H5ML.unwrap_ids(plist_id);
num_files = H5ML.hdf5lib2('H5Pget_external_count', id);            
