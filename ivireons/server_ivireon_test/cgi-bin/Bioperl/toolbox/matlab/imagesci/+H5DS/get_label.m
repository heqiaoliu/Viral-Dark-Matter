function label = get_label(dataset_id,idx)
%H5DS.get_label  Retrieve label from specific dataset dimension.
%   label = H5DS.get_label(dataset_id,idx) retrieves the label for
%   dimension idx of the dataset dataset_id.
%
%   Note:  The ordering of the dimension scale indices are the same as the
%   HDF5 library C API. 
%
%   Example:  
%       plist = 'H5P_DEFAULT';
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY',plist);
%       world_dset_id = H5D.open(fid,'/g4/world',plist);
%       label = H5DS.get_label(world_dset_id,0);
%       H5D.close(world_dset_id);
%       H5F.close(fid);
%
%   See also H5DS, H5DS.set_label.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $ $Date: 2010/05/13 17:39:34 $

[id] = H5ML.unwrap_ids(dataset_id);
label = H5ML.hdf5lib2('H5DSget_label', id, idx);            
