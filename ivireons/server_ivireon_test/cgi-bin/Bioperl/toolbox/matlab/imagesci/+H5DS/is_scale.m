function tf = is_scale(dataset_id)
%H5DS.is_scale  Determine if dataset is a dimension scale.
%   bool = H5DS.is_scale(dataset_id) determines whether the dataset
%   dataset_id is a dimension scale.
%
%   Example:
%       plist = 'H5P_DEFAULT';
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY',plist);
%       lat_dset_id = H5D.open(fid,'/g4/lat',plist);
%       if H5DS.is_scale(lat_dset_id)
%           fprintf('/g4/lat is a dimension scale.\n');
%       else
%           fprintf('/g4/lat is not a dimension scale.\n');
%       end
%       H5D.close(lat_dset_id);
%       H5F.close(fid);
%
%   See also H5DS.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $ $Date: 2010/04/15 15:20:10 $

[id] = H5ML.unwrap_ids(dataset_id);
tf = H5ML.hdf5lib2('H5DSis_scale', id);            
