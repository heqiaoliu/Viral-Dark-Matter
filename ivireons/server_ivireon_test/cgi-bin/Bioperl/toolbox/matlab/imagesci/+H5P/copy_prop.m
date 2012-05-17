function copy_prop(dst_plist_id, src_plist_id, name) %#ok<INUSD>
%H5P.copy_prop  Copy specified property from source to destination.
%   H5P.copy_prop(dst_plist_id, src_plist_id, name) copies the property specified 
%   by name from the property list specified by src_plist_id to the property
%   list specified by dst_plist_id. 
% 
%   The HDF5 function 'H5Pcopy_prop' implementation in HDF library version
%   1.8 has a critical bug/issue. Hence this function is currently
%   disabled and throws an error if called.
%
%   See also H5P.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:21:35 $

error('MATLAB:H5P:copy_prop:unsupported', ...
    'The HDF5 function ''H5Pcopy_prop'' implementation has a critical bug/issue.\n%s', ...
    'Hence this function is currently disabled.');
