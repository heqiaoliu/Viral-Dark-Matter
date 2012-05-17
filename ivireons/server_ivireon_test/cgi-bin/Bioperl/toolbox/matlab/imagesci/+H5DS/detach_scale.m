function detach_scale(dataset_id,dimscale_id,idx)
%H5DS.detach_scale  Detach dimension scale from specific dataset dimension.
%   H5DS.detach_scale(dataset_id,dimscale_id,idx) detaches dimension scale
%   dimscale_id from dimension idx of the dataset dataset_id.
%
%   Note:  The ordering of the dimension scale indices are the same as the
%   HDF5 library C API. 
%
%   See also H5DS, H5DS.attach_scale.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $ $Date: 2010/05/13 17:39:33 $

[id, ds_id] = H5ML.unwrap_ids(dataset_id,dimscale_id);
H5ML.hdf5lib2('H5DSdetach_scale', id, ds_id, idx);            
