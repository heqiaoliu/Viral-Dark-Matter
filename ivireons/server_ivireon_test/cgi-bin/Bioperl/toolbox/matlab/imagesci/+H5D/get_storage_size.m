function dataset_size = get_storage_size(dataset_id)
%H5D.get_storage_size  Determine required storage size.
%   dataset_size = H5D.get_storage_size(dataset_id) returns the amount of 
%   storage that is required for the dataset specified by dataset_id.
%
%   Example:
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       dset_id = H5D.open(fid,'/g1/g1.1/dset1.1.1');
%       dataset_size = H5D.get_storage_size(dset_id);
%       H5D.close(dset_id);
%       H5F.close(fid);
%
%   See also H5D.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:19:58 $

[id] = H5ML.unwrap_ids(dataset_id);
dataset_size = H5ML.hdf5lib2('H5Dget_storage_size', id);            
