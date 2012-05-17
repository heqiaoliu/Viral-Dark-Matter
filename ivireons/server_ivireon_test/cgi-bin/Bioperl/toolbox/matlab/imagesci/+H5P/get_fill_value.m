function value = get_fill_value(plist_id, type_id)
%H5P.get_fill_value  Return dataset fill value.
%   value = H5P.get_fill_value(plist_id, type_id) returns the dataset fill
%   value defined in the dataset creation property list plist_id. type_id
%   specifies the datatype of the returned fill value.
%
%   Example:
%       plist_id = 'H5P_DEFAULT';
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY',plist_id);
%       dset_id = H5D.open(fid,'/g3/integer',plist_id);
%       dcpl = H5D.get_create_plist(dset_id);
%       type_id = H5T.copy('H5T_NATIVE_INT');
%       fill_value = H5P.get_fill_value(dcpl,type_id);
%
%   See also H5P, H5P.set_fill_value, H5P.get_fill_time, H5P.set_fill_time.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:22:07 $

[p_id, t_id] = H5ML.unwrap_ids(plist_id, type_id);
value = H5ML.hdf5lib2('H5Pget_fill_value', p_id, t_id);            
