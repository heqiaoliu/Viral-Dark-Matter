function H5Tpack(type_id)
%H5T.pack  Recursively remove padding from compound datatype.
%   H5T.pack(type_id) recursively removes padding from within a compound datatype
%   to make it more efficient (space-wise) to store that data. type_id is a
%   datatype identifier.
%
%   See also H5T.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:24:43 $

[id] = H5ML.unwrap_ids(type_id);
H5ML.hdf5lib2('H5Tpack',id); 
