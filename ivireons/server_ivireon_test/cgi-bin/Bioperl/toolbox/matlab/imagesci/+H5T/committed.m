function output = committed(type_id)
%H5T.committed  Determines if datatype is committed.
%   output = H5T.committed(type_id) returns a positive value to indicate
%   that the datatype has been committed, and zero to indicate that it has
%   not. A negative value indicates failure.
%
%   Example:
%       type_id = H5T.copy('H5T_NATIVE_DOUBLE');
%       is_committed = H5T.committed(type_id);
%
%   See also H5T, H5T.commit.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $ $Date: 2010/04/15 15:24:02 $

[id] = H5ML.unwrap_ids(type_id);
output = H5ML.hdf5lib2('H5Tcommitted', id);       
