function set_preserve(plist_id, status)
%H5P.set_preserve  Set dataset transfer property status.
%
%   This function is no longer necessary.  Its functional capability is now
%   internal to the HDF5 library.  See the HDF5 User's Guide and Reference
%   Manual.
%
%   H5P.set_preserve(plist_id, status) sets the status of the dataset 
%   transfer property list, plist_id, to the specified Boolean value.
%
%   See also H5P.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.7 $ $Date: 2010/05/13 17:40:12 $

warning('MATLAB:h5psetpreserve:noLongerUseful', ...
     ['H5P.set_preserve no longer has any effect since compound ', ...
	  'datatype field preservation is now core functionality in ', ...
	  'the HDF5 Library.  Please consult the HDF5 User''s Guide and ', ...
	  'Reference Manual.']);

[id] = H5ML.unwrap_ids(plist_id);
H5ML.hdf5lib2('H5Pset_preserve', id, status);
