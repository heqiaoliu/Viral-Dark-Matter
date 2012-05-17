function set_fapl_core(fapl_id, increment, backing_store)
%H5P.set_fapl_core  Modify file access to use H5FD_CORE driver.
%   H5P.set_fapl_core(fapl_id, increment, backing_store) modifies the file
%   access property list to use the H5FD_CORE driver. increment specifies
%   the increment by which allocated memory is to be increased each time
%   more memory is required. backing_store is a Boolean flag that, when
%   non-zero, indicates the file contents should be written to disk when
%   the file is closed.
%
%   See also H5P, H5P.get_fapl_core.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:22:52 $

id = H5ML.unwrap_ids(fapl_id);
H5ML.hdf5lib2('H5Pset_fapl_core', id, increment, backing_store);            
