function [sizeof_addr, sizeof_size] = get_sizes(fcpl)
%H5P.get_sizes  Return size of offsets and lengths.
%   [sizeof_addr sizeof_size] = H5P.get_sizes(fcpl) returns the size of 
%   the offsets and lengths used in an HDF5 file. fcpl specifies a file
%   creation property list.
%
%   Example:
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       fcpl = H5F.get_create_plist(fid);
%       [soaddr, sosize] = H5P.get_sizes(fcpl);
%       H5P.close(fcpl);
%       H5F.close(fid);
%
%   See also H5P, H5P.set_sizes.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:22:25 $

id = H5ML.unwrap_ids(fcpl);
[sizeof_addr, sizeof_size] = H5ML.hdf5lib2('H5Pget_sizes', id);            
