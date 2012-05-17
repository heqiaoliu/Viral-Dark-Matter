function linkStruct = get_info(link_id,link_name,lapl_id)
%H5L.get_info  Return information about link.
%   linkStruct = H5L.get_info(link_id,link_name,lapl_id) returns
%   information about a link.
%
%   A file or group identifier, link_id, specifies the location of the
%   link. link_name, interpreted relative to link_id, specifies the link
%   being queried.
%
%   Example:
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       info = H5L.get_info(fid,'g3','H5P_DEFAULT');
%       H5F.close(fid);
%
%   See also H5L.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $ $Date: 2010/04/15 15:21:08 $


[id, lid] = H5ML.unwrap_ids(link_id, lapl_id);
linkStruct = H5ML.hdf5lib2('H5Lget_info', id, link_name, lid);            

