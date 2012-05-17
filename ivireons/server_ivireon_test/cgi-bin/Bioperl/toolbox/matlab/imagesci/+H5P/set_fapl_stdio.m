function set_fapl_stdio(fapl_id)
%H5P.set_fapl_stdio  Set file access for standard I/O driver.
%   H5P.set_fapl_stdio(fapl_id) modifies the file access property list,
%   fapl_id, to use the standard I/O driver, H5FD_STDIO.
%
%   Example:
%       fcpl = H5P.create('H5P_FILE_CREATE');
%       fapl = H5P.create('H5P_FILE_ACCESS');
%       H5P.set_fapl_stdio(fapl);
%       fid = H5F.create('myfile.h5','H5F_ACC_TRUNC',fcpl,fapl);
%       H5F.close(fid);
%
%   See also H5P.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:22:58 $

id = H5ML.unwrap_ids(fapl_id);
H5ML.hdf5lib2('H5Pset_fapl_stdio', id);            
