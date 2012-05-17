function output = get_preserve(plist_id)
%H5P.get_preserve  Return status of dataset transfer property list.
%
%   This function is no longer necessary.  Its functional capability is now
%   internal to the HDF5 library.  See the HDF5 User's Guide and Reference
%   Manual.
%
%   output = H5P.get_preserve(plist_id) returns the status of the dataset
%   transfer property list.
%
%   See also H5P.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.7 $ $Date: 2010/05/13 17:40:11 $

warning('MATLAB:h5pgetpreserve:noLongerUseful', ...
     ['H5P.get_preserve no longer has any effect since compound ' ...
	  'datatype field preservation is now core functionality in ' ...
	  'the HDF5 Library.  Please consult the HDF5 User''s Guide and ' ...
	  'Reference Manual']);

[id] = H5ML.unwrap_ids(plist_id);
output = H5ML.hdf5lib2('H5Pget_preserve', id );
