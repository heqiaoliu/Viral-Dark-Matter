function config_struct = get_mdc_config(file_id)
%H5F.get_mdc_config  Return metadata cache configuration.
%   config_struct = H5F.get_mdc_config(file_id) returns the current 
%   metadata cache configuration for the target file.
%
%   Example:
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       config = H5F.get_mdc_config(fid);
%       H5F.close(fid);
%
%   See also H5F, H5F.set_mdc_config.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:20:26 $

id = H5ML.unwrap_ids(file_id);
config_struct = H5ML.hdf5lib2('H5Fget_mdc_config', id);            
