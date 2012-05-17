function output = get_nfilters(plist_id)
%H5P.get_nfilters  Return number of filters in pipeline.
%   num_filters = H5P.get_nfilters(plist_id) returns the number of filters
%   defined in the filter pipeline associated with the dataset creation
%   property list, plist_id.
%
%   Example:
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       dset_id = H5D.open(fid,'/g4/world');
%       dcpl = H5D.get_create_plist(dset_id);
%       num_filters = H5P.get_nfilters(dcpl);
%       H5D.close(dset_id);
%       H5F.close(fid);
%
%   See also H5P, H5P.get_filter, H5P.get_filter_by_id, H5P.modify_filter,
%   H5P.remove_filter.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $ $Date: 2010/05/13 17:40:10 $

id = H5ML.unwrap_ids(plist_id);
output = H5ML.hdf5lib2('H5Pget_nfilters', id);            
