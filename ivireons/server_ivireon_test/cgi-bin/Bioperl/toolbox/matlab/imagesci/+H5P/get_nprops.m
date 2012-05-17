function nprops = get_nprops(id)
%H5P.get_nprops  Query number of properties in property list or class.
%   nprops = H5P.get_nprops(id) returns the number of properties in the 
%   property list or class specified by id.
%
%   Example:
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       fcpl = H5F.get_create_plist(fid);
%       nprops = H5P.get_nprops(fcpl);
%
%   See also H5P.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:22:21 $

idx = H5ML.unwrap_ids(id);
nprops = H5ML.hdf5lib2('H5Pget_nprops', idx);            
