function H5Tlock(type_id)
%H5T.lock  Lock specified datatype.
%   H5T.lock(type_id) locks the datatype specified by the type_id identifier,
%   making it read-only and non-destructible.
%
%   See also H5T.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:24:41 $

[id] = H5ML.unwrap_ids(type_id);
H5ML.hdf5lib2('H5Tlock',id); 
