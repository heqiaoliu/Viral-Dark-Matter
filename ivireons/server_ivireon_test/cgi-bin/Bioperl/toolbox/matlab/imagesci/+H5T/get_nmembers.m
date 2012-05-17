function output = get_nmembers(type_id)
%H5T.get_nmembers  Return number of elements in enumeration type.
%   output = H5T.get_nmembers(type_id) retrieves the number of fields in a 
%   compound datatype or the number of members of an enumeration datatype.
%   type_id is a datatype identifier.
%
%   Example:  Determine the number of fields in a compound dataset.
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       dset_id = H5D.open(fid,'/g3/compound');
%       dtype_id = H5D.get_type(dset_id);
%       nmembers = H5T.get_nmembers(dtype_id);
%
%   See also H5T.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:24:27 $

[id] = H5ML.unwrap_ids(type_id);
output = H5ML.hdf5lib2('H5Tget_nmembers',id); 
