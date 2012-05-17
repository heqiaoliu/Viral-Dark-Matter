function extend(dataset_id, h5_size)
%H5D.extend  Extend dataset.
%
%   H5D.extend is not recommended.  Use H5D.set_extent instead.
%
%   H5D.extend(dataset_id,h5_size) extends the dataset specified by 
%   dataset_id to the size specified by h5_size.
%
%   The HDF5 group has deprecated use of this function.
%
%   See also H5D, H5D.set_extent.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.7 $ $Date: 2010/05/13 17:39:26 $

id = H5ML.unwrap_ids(dataset_id);
H5ML.hdf5lib2('H5Dextend', id, h5_size);            
