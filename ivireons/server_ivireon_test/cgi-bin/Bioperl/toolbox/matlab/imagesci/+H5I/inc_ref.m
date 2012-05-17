function ref_count = inc_ref(obj_id)
%H5I.inc_ref  Increment reference count of specified object.
%   ref_count = H5I.inc_ref(obj_id) increments the reference count of the
%   specified by obj_id and returns the new count.
%
%   See also H5I, H5I.dec_ref, H5I.get_ref.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $ $Date: 2010/05/13 17:39:58 $

[id] = H5ML.unwrap_ids(obj_id);
ref_count = H5ML.hdf5lib2('H5Iinc_ref', id);            
