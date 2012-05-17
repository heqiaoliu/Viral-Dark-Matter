function extent_copy(varargin)
%H5S.extent_copy  Copy extent from source to destination dataspace.
%   H5S.extent_copy(dst_id, src_id) copies the extent from the source 
%   dataspace src_id to the destination dataspace dst_id.
%
%   Example:
%       space_id1 = H5S.create('H5S_SIMPLE');
%       dims = [100 200];
%       h5_dims = fliplr(dims);
%       maxdims = [100 H5ML.get_constant_value('H5S_UNLIMITED')];
%       h5_maxdims = fliplr(maxdims);
%       H5S.set_extent_simple(space_id1,2,h5_dims, h5_maxdims);
%       space_id2 = H5S.create('H5S_SIMPLE');
%       H5S.extent_copy(space_id2,space_id1);
%
%   See also H5S, H5S.create, H5S.get_simple_extent_dims, 
%   H5S.set_extent_simple.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:23:37 $

[varargin{:}] = H5ML.unwrap_ids(varargin{:});
H5ML.hdf5lib2('H5Sextent_copy', varargin{:});            
