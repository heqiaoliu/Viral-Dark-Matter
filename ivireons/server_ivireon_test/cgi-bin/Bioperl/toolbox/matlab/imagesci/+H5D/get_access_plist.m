function plist_id = get_access_plist(dataset_id)
%H5D.get_access_plist  Return copy of dataset access property list.
%   plist_id = H5D.get_access_plist(dataset_id) returns a copy of the
%   dataset access property list used to open the specified dataset. 
%
%   Example:
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       dset_id = H5D.open(fid,'/g1/g1.1/dset1.1.1');
%       dapl = H5D.get_access_plist(dset_id);
%       H5P.close(dapl);
%       H5D.close(dset_id);
%       H5F.close(fid);
%
%   See also H5D, H5D.get_create_plist, H5P.close.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2010/04/15 15:19:53 $

id = H5ML.unwrap_ids(dataset_id);
plist_id = H5ML.hdf5lib2('H5Dget_access_plist', id);            
plist_id = H5ML.id(plist_id,'H5Pclose');
