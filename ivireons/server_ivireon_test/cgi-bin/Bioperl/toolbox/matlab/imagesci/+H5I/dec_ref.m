function ref_count = dec_ref(obj_id)
%H5I.dec_ref  Decrement reference count.
%   ref_count = H5I.dec_ref(obj_id) decrements the reference count of the 
%   object identified by obj_id and returns the new count.
%
%   See also H5I, H5I.get_ref, H5I.inc_ref.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $ $Date: 2010/05/13 17:39:53 $

[id] = H5ML.unwrap_ids(obj_id);
ref_count = H5ML.hdf5lib2('H5Idec_ref', id);            
