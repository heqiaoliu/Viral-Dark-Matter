function info = get_info(obj_id)
%H5O.get_info  Retrieve information for object.
%   info = H5O.get_info(obj_id) retrieves the metadata for an object
%   specified by obj_id.  For details about the object metadata, please
%   refer to the HDF5 documentation.
%
%   Example:  determine the number of attributes for a dataset.
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       dsetId = H5D.open(fid,'/g1/g1.1/dset1.1.1');
%       info = H5O.get_info(dsetId);
%       info.num_attrs
%  
%   See also H5O, H5F.open, H5G.open, H5D.open, H5T.open.
   
%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $ $Date: 2010/04/15 15:21:22 $

[id] = H5ML.unwrap_ids(obj_id);
info = H5ML.hdf5lib2('H5Oget_info', id);            


