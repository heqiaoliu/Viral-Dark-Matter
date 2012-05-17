function set_mdc_config(fileId,config)
%H5F.set_mdc_config  Configure HDF5 file metadata cache.
%   H5F.set_mdc_config(fileId,config) attempts to configure the file's 
%   metadata cache according to the supplied configuration structure.
%   Before using this function, you should retrieve the current 
%   configuration using H5F.get_mdc_config.
%
%   See also H5F, H5F.get_mdc_config.
%

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:20:36 $

id = H5ML.unwrap_ids(fileId);
H5ML.hdf5lib2('H5Fset_mdc_config', id, config);            
