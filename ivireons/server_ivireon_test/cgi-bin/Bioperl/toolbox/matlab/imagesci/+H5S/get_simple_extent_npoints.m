function output = H5Sget_simple_extent_npoints(space_id)
%H5S.get_simple_extent_npoints  Return number of elements in dataspace.
%   output = H5S.get_simple_extent_npoints(space_id) returns the number of 
%   elements in the dataspace specified by space_id.
%
%   See also H5S.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:23:47 $

[id] = H5ML.unwrap_ids(space_id);
output = H5ML.hdf5lib2('H5Sget_simple_extent_npoints', id);            
