function ik = get_istore_k(plist_id)
%H5P.get_istore_k  Return 1/2 rank of indexed storage B-tree.
%   ik = H5P.get_istore_k(plist_id) returns the chunked storage B-tree 1/2 
%   rank of the file creation property list specified by plist_id.
%
%   Example:
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       fcpl = H5F.get_create_plist(fid);
%       ik = H5P.get_istore_k(fcpl);
%       H5P.close(fcpl);
%       H5F.close(fid);
%
%   See also H5P, H5P.set_istore_k.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:22:12 $

id = H5ML.unwrap_ids(plist_id);
ik = H5ML.hdf5lib2('H5Pget_istore_k', id);            
