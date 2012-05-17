function sz = get_meta_block_size(fapl_id)
%H5P.get_meta_block_size  Return metadata block size setting.
%   sz = H5P.get_meta_block_size(fapl_id) returns the current minimum 
%   size, in bytes, of new metadata block allocations.
%
%   Example:
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       fapl = H5F.get_access_plist(fid);
%       sz = H5P.get_meta_block_size(fapl);
%       H5P.close(fapl);
%       H5F.close(fid);
%
%   See also H5P, H5P.set_meta_block_size.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $ $Date: 2010/04/15 15:22:18 $

id = H5ML.unwrap_ids(fapl_id);
sz = H5ML.hdf5lib2('H5Pget_meta_block_size', id);            
