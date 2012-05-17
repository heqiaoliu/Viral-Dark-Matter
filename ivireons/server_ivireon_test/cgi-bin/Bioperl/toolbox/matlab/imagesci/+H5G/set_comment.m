function set_comment(loc_id,name,comment)
%H5G.set_comment  Set comment for object.
%
%   H5G.set_comment is not recommended.  Use H5O.set_comment instead.
%
%   H5G.set_comment(loc_id, name, comment) sets the comment for the object 
%   specified by loc_id and name to comment. loc_id is a file, group, 
%   dataset, or datatype identifier.
%
%   The HDF5 group has deprecated the use of this function.
%
%   See also H5G, H5O.set_comment.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.7 $ $Date: 2010/05/13 17:39:50 $

id = H5ML.unwrap_ids(loc_id);
H5ML.hdf5lib2('H5Gset_comment', id,name,comment);
