function sz = get_sieve_buf_size(fapl_id)
%H5P.get_sieve_buf_size  Return maximum data sieve buffer size.
%   sz = H5P.get_sieve_buf_size(fapl_id) returns the current maximum 
%   size of the data sieve buffer.
%
%   Example:
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       fapl = H5F.get_access_plist(fid);
%       sz = H5P.get_sieve_buf_size(fapl);
%       H5P.close(fapl);
%       H5F.close(fid);
%
%   See also H5P, H5P.set_sieve_buf_size.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $ $Date: 2010/04/15 15:22:23 $

id = H5ML.unwrap_ids( fapl_id);
sz = H5ML.hdf5lib2('H5Pget_sieve_buf_size', id);            
