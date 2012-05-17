function dspace_id = get_space(attr_id)
%H5A.get_space  Retrieve copy of attribute dataspace.
%   dspace_id = H5A.get_space(attr_id) returns a copy of the dataspace for
%   the attribute specified by attr_id.
%
%   Example:  retrieve the dimensions of an attribute dataspace.
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       attr_id = H5A.open(fid,'attr2','H5P_DEFAULT');
%       space = H5A.get_space(attr_id);
%       [~,dims] = H5S.get_simple_extent_dims(space);
%       H5A.close(attr_id);
%       H5F.close(fid);
%  
%   See also H5A, H5A.open, H5S.close.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:19:39 $

id = H5ML.unwrap_ids(attr_id);
dspace_id = H5ML.hdf5lib2('H5Aget_space', id);            
dspace_id = H5ML.id(dspace_id,'H5Sclose');

