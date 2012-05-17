function gc_ref = get_gc_references(fapl_id)
%H5P.get_gc_references  Return garbage collection references setting.
%   gc_ref = H5P.get_gc_references(fapl_id) returns the current setting for
%   the garbage collection references property from the file access
%   property list specified by fapl_id. If gc_ref is 1, garbage collection
%   is on; if 0, garbage collection is off.
%
%   Example:
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       fapl = H5F.get_access_plist(fid);
%       gc_ref = H5P.get_gc_references(fapl);
%       H5P.close(fapl);
%       H5F.close(fid);
%
%   See also H5P, H5P.set_gc_references.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:22:10 $

id = H5ML.unwrap_ids(fapl_id);
gc_ref = H5ML.hdf5lib2('H5Pget_gc_references', id);            
