function [ik, lk] = get_sym_k(plist_id)
%H5P.get_sym_k  Return size of B-tree 1/2 rank and leaf node 1/2 size.
%   [ik lk] = H5P.get_sym_k(plist_id) returns the size of the symbol table
%   B-tree 1/2 rank, ik, and the symbol table leaf node 1/2 size, lk. 
%   plist_id is a file creation property list identifier.
%
%   Example:
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       fcpl = H5F.get_create_plist(fid);
%       [ik, lk] = H5P.get_sym_k(fcpl);
%       H5P.close(fcpl);
%       H5F.close(fid);
%
%   See also H5P, H5P.set_sym_k.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:22:27 $

id = H5ML.unwrap_ids(plist_id);
[ik, lk] = H5ML.hdf5lib2('H5Pget_sym_k', id);            
