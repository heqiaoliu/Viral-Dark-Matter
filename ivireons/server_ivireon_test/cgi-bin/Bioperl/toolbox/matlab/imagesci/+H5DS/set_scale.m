function set_scale(dataset_id,dim_name)
%H5DS.set_scale  Converts a dataset to a dimension scale.
%   H5DS.set_scale(dataset_id,dim_name) converts the dataset dataset_id to
%   a dimension scale with name dim_name.
%
%   Example:  Create a dimension scale with name 'xdim'.  The dataset 
%   itself will have name 'x'.
%       plist = 'H5P_DEFAULT';
%       fid = H5F.create('myfile.h5','H5F_ACC_TRUNC',plist,plist);
%       space_id = H5S.create_simple(1,10,10);
%       dtype = 'H5T_NATIVE_INT';
%       dset_id = H5D.create(fid,'x',dtype,space_id,plist,plist,plist);
%       H5DS.set_scale(dset_id,'xdim');
%       H5S.close(space_id);
%       H5D.close(dset_id);
%       H5F.close(fid);
%
%   See also H5DS, H5DS.get_scale_name.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $ $Date: 2010/04/15 15:20:13 $

[id] = H5ML.unwrap_ids(dataset_id);
H5ML.hdf5lib2('H5DSset_scale', id, dim_name);            
