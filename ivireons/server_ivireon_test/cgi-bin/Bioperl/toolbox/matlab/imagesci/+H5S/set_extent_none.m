function set_extent_none(space_id)
%H5S.set_extent_none  Remove extent from dataspace.
%   H5S.set_extent_none(space_id) removes the extent from a dataspace and 
%   sets the type to H5S_NO_CLASS.
%
%   Example:
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       dset_id = H5D.open(fid,'/g3/integer2D');
%       space_id = H5D.get_space(dset_id);
%       H5S.set_extent_none(space_id);
%       extent_type = H5S.get_simple_extent_type(space_id);
%       switch(extent_type)
%           case H5ML.get_constant_value('H5S_SCALAR')
%               fprintf('scalar\n');
%           case H5ML.get_constant_value('H5S_SIMPLE')
%               fprintf('simple\n');
%           case H5ML.get_constant_value('H5S_NO_CLASS')
%               fprintf('no class\n');
%       end
%
%   See also H5S, H5S.get_simple_extent_dims.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:23:56 $

[id] = H5ML.unwrap_ids(space_id);
H5ML.hdf5lib2('H5Sset_extent_none', id);            
