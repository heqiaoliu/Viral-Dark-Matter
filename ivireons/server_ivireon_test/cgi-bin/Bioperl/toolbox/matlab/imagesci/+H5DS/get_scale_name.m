function name = get_scale_name(dimscale_id)
%H5DS.get_scale_name  Retrieve name of dimension scale.
%   name = H5DS.get_scale_name(dimscale_id) retrieves the name of the
%   dimension scale dimscale_id.
%
%   Example:
%       plist = 'H5P_DEFAULT';
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY',plist);
%       lat_dset_id = H5D.open(fid,'/g4/lat',plist);
%       scale_name = H5DS.get_scale_name(lat_dset_id);
%       H5D.close(lat_dset_id);
%       H5F.close(fid);
%
%   See also H5DS, H5DS.set_scale.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $ $Date: 2010/04/15 15:20:09 $

[id] = H5ML.unwrap_ids(dimscale_id);
name = H5ML.hdf5lib2('H5DSget_scale_name', id);            
