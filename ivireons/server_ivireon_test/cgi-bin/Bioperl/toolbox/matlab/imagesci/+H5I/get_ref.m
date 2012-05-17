function ref_count = get_ref(obj_id)
%H5I.get_ref  Return reference count of specified object.
%   refcount = H5I.get_ref(obj_id) returns the reference count of the 
%   object specified by obj_id.
%
%   See also H5I, H5I.dec_ref, H5I.inc_ref.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $ $Date: 2010/05/13 17:39:56 $

[id] = H5ML.unwrap_ids(obj_id);
ref_count = H5ML.hdf5lib2('H5Iget_ref', id);            
