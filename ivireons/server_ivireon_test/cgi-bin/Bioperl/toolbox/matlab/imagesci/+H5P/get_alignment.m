function [threshold, alignment] = get_alignment(fapl_id)
%H5P.get_alignment  Retrieve alignment properties.
%   [threshold alignment] = H5P.get_alignment(plist_id) retrieves the
%   current settings for alignment properties from the file access property
%   list specified by plist_id.
%
%   Example:
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       fapl = H5F.get_access_plist(fid);
%       [threshold, alignment] = H5P.get_alignment(fapl);
%       H5P.close(fapl);
%       H5F.close(fid);
%
%   See also H5P.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:21:42 $

id = H5ML.unwrap_ids(fapl_id);
[threshold, alignment] = H5ML.hdf5lib2('H5Pget_alignment', id);            
