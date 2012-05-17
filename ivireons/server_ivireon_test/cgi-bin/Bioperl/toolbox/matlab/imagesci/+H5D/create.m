function dataset_id = create(varargin)
%H5D.create  Create new dataset.
%   dataset_id = H5D.create(loc_id, name, type_id, space_id, plist_id) 
%   creates the data set specified by name in the file or in the group 
%   specified by loc_id. type_id and space_id identify the datatype and 
%   dataspace, respectively. plist_id identifies the dataset creation
%   property list.  This interface corresponds to the H5Dcreate1 function
%   in the HDF5 library C 1.6 API.
%
%   datasetId = H5D.create(locId,name,typeId,spaceId,lcplId,dcplId,daplId) 
%   creates the data set with three distinct property lists:
%
%      lcplId:  link creation property list
%      dcplId:  dataset creation property list
%      daplId:  dataset access property list
%
%   This interface corresponds to the H5Dcreate function in the HDF5 
%   library C 1.8 API.
%
%   Example:  create a 10x5 double precision dataset with default property
%   list settings.
%       plist = 'H5P_DEFAULT';
%       fid = H5F.create('myfile.h5','H5F_ACC_TRUNC',plist,plist);
%       type_id = H5T.copy('H5T_NATIVE_DOUBLE');
%       dims = [10 5];
%       h5_dims = fliplr(dims);
%       h5_maxdims = h5_dims;
%       space_id = H5S.create_simple(2,h5_dims,h5_maxdims);
%       dset_id = H5D.create(fid,'DS',type_id,space_id,plist,plist,plist);
%       H5S.close(space_id);
%       H5T.close(type_id);
%       H5D.close(dset_id);
%       H5F.close(fid);
%       
%   See also H5D, H5D.close, H5S.create_simple, H5S.close, H5T.copy.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:19:50 $

[varargin{:}] = H5ML.unwrap_ids(varargin{:});
id = H5ML.hdf5lib2('H5Dcreate', varargin{:} );
dataset_id = H5ML.id(id,'H5Dclose');
