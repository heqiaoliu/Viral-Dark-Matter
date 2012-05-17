function output = H5Sget_simple_extent_ndims(space_id)
%H5S.get_simple_extent_ndims  Return rank of dataspace.
%   output = H5S.get_simple_extent_ndims(space_id) returns the dimensionality
%   (also called the rank) of a dataspace. 
%
%   See also H5S.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:23:46 $

[id] = H5ML.unwrap_ids(space_id);
output = H5ML.hdf5lib2('H5Sget_simple_extent_ndims', id);            
