function num_objs = get_num_objs(loc_id)
%H5G.get_num_objs  Return number of objects in file or group.
%
%   H5G.get_num_objs is not recommended.  Use H5G.get_info instead.
%
%   num_objs = H5G.get_num_objs(loc_id) returns number of objects in the
%   group or file specified loc_id. 
%
%   The HDF5 group has deprecated the use of this function.
%
%   See also H5G, H5G.get_info.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.7 $ $Date: 2010/05/13 17:39:42 $

id = H5ML.unwrap_ids(loc_id);
num_objs = H5ML.hdf5lib2('H5Gget_num_objs', id);            
