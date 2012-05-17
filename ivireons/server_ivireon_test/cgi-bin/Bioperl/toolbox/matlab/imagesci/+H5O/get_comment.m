function comment = get_comment(obj_id)
%H5O.get_comment  Retrieve comment for specified object.
%   comment = H5O.get_comment(obj_id) retrieves the comment for the
%   object specified by obj_id.
%
%   Example:
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       dset_id = H5D.open(fid,'g4/world');
%       comment = H5O.get_comment(dset_id);
%       H5D.close(dset_id);
%       H5F.close(fid);
%
%   See also H5O, H5O.get_comment_by_name, H5O.set_comment,
%   H5O.set_comment_by_name.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $ $Date: 2010/05/13 17:40:03 $

[id] = H5ML.unwrap_ids(obj_id);
comment = H5ML.hdf5lib2('H5Oget_comment', id);            


