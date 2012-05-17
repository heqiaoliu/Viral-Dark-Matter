function driver_id = get_driver(plist_id)
%H5P.get_driver  Return low-level file driver.
%   driver_id = H5P.get_driver(plist_id) returns the identifier of the
%   low-level file driver associated with the file access property list or
%   data transfer property list specified by plist_id. See HDF5
%   documentation for a list of valid return values.
%
%   Example:
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       fapl = H5F.get_access_plist(fid);
%       driver_id = H5P.get_driver(fapl);
%       if ( driver_id == H5ML.get_constant_value('H5FD_SEC2') )
%           fprintf('File driver is H5FD_SEC2.\n');
%       end
%       H5P.close(fapl);
%       H5F.close(fid);
%
%   See also H5P, H5ML.get_constant_value.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $ $Date: 2010/05/13 17:40:09 $

id = H5ML.unwrap_ids(plist_id);
driver_id = H5ML.hdf5lib2('H5Pget_driver', id);            
