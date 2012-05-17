function type_id = get_type(attr_id)
%H5A.get_type  Return copy of attribute datatype.
%   type_id = H5A.get_type(attr_id) returns a copy of the datatype for the
%   attribute specified by attr_id.
%
%   Example:  
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       gid = H5G.open(fid,'/');
%       attr_id = H5A.open(gid,'attr1','H5P_DEFAULT');
%       type_id = H5A.get_type(attr_id);
%       H5T.close(type_id);
%       H5A.close(attr_id);
%       H5G.close(gid);
%       H5F.close(fid);
%  
%   See also H5A, H5A.open, H5T.close.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:19:40 $

id = H5ML.unwrap_ids(attr_id);
type_id = H5ML.hdf5lib2('H5Aget_type', id);            
type_id = H5ML.id(type_id,'H5Tclose');
