function set_fapl_sec2(fapl_id)
%H5P.set_fapl_sec2  Set file access for sec2 driver.
%   H5P.set_fapl_sec2(fapl_id) modifies the file access property list,
%   fapl_id, to use the H5FD_SEC2 driver.
%
%   Example:
%       fcpl = H5P.create('H5P_FILE_CREATE');
%       fapl = H5P.create('H5P_FILE_ACCESS');
%       H5P.set_fapl_sec2(fapl);
%       fid = H5F.create('myfile.h5','H5F_ACC_TRUNC',fcpl,fapl);
%       H5F.close(fid);
%
%   See also H5P.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:22:56 $

id = H5ML.unwrap_ids(fapl_id);
H5ML.hdf5lib2('H5Pset_fapl_sec2', id);            
