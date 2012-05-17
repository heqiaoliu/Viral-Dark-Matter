function num_scales = get_num_scales(dataset_id,idx)
%H5DS.get_num_scales  Retrieve number of scales attached to dataset dimension.
%   num_scales = H5DS.get_num_scales(dataset_id,idx) determines the number
%   of dimension scales that are attached to dimension idx of the dataset
%   dataset_id.
%
%   Example:  
%       plist = 'H5P_DEFAULT';
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY',plist);
%       world_dset_id = H5D.open(fid,'/g4/world',plist);
%       num_scales = H5DS.get_num_scales(world_dset_id,0);
%       H5D.close(world_dset_id);
%       H5F.close(fid);
%
%   See also H5DS.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $ $Date: 2010/04/15 15:20:08 $

[id] = H5ML.unwrap_ids(dataset_id);
num_scales = H5ML.hdf5lib2('H5DSget_num_scales', id, idx);            
