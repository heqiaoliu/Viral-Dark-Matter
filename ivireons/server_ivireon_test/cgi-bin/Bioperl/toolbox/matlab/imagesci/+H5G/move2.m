function move2(src_loc, src, dst_loc, dst)
%H5G.move2  Rename specified object.
%
%   H5G.move2 is not recommended.  Use H5L.move instead.
%
%   H5G.move2(src_loc_id, src_name, dst_loc_id, dst_name) renames the file 
%   or group object specified by src_loc_id, with the name specified by 
%   src_name, with the name specified by dst_name and location specified by 
%   dst_loc_id.
%
%   The HDF5 group has deprecated the use of this function.
%
%   See also H5G, H5L.move.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.7 $ $Date: 2010/05/13 17:39:48 $

[src_id, dst_id] = H5ML.unwrap_ids(src_loc, dst_loc);
H5ML.hdf5lib2('H5Gmove2', src_id, src, dst_id, dst);            
