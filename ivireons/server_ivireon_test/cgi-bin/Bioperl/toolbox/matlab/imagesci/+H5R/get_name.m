function name = get_name(loc_id,ref_type,ref)
%H5R.get_name  Return name of referenced object.
%   name = H5R.get_name(loc_id,ref_type,ref) retrieves the name for the 
%   object identified by ref.  loc_id is the identifier for the dataset
%   containing the reference or for the group containing that dataset. 
%   ref_type specifies the type of the reference ref. Valid ref_types are
%   'H5R_OBJECT' or 'H5R_DATASET_REGION'.  
%
%   Example:
%       plist = 'H5P_DEFAULT';
%       space = 'H5S_ALL';
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY',plist);
%       dset_id = H5D.open(fid,'/g3/reference');
%       ref_data = H5D.read(dset_id,'H5T_STD_REF_OBJ',space,space,plist);
%       name = H5R.get_name(dset_id,'H5R_OBJECT',ref_data(:,1));
%       H5D.close(dset_id);
%       H5F.close(fid);
%
%   See also H5R, H5I.get_name.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $ $Date: 2010/05/13 17:40:16 $

id = H5ML.unwrap_ids(loc_id);
name = H5ML.hdf5lib2('H5Rget_name', id, ref_type, ref);            
