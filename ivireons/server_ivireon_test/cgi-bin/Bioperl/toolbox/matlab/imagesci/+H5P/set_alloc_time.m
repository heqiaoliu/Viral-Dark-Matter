function set_alloc_time(plist_id, alloc_time)
%H5P.set_alloc_time  Set timing for storage space allocation.
%   H5P.set_alloc_time(plist_id, alloc_time) sets the timing for the
%   allocation of storage space for a dataset's raw data. plist_id is a
%   dataset creation property list. alloc_time can have any of the
%   following values: H5D_ALLOC_TIME_DEFAULT, H5D_ALLOC_TIME_EARLY,
%   H5D_ALLOC_TIME_INC, or H5D_ALLOC_TIME_LATE.
%   
%   Example:  create a 1000x500 double precision dataset with late
%   allocation time.
%       fcpl = 'H5P_DEFAULT';
%       fapl = 'H5P_DEFAULT';
%       fid = H5F.create('myfile.h5','H5F_ACC_TRUNC',fcpl,fapl);
%       type_id = H5T.copy('H5T_NATIVE_DOUBLE');
%       dims = [1000 500];
%       h5_dims = fliplr(dims);
%       h5_maxdims = h5_dims;
%       space_id = H5S.create_simple(2,h5_dims,h5_maxdims);
%       lcpl = 'H5P_DEFAULT';
%       dapl = 'H5P_DEFAULT';
%       dcpl = H5P.create('H5P_DATASET_CREATE');
%       alloc_time = H5ML.get_constant_value('H5D_ALLOC_TIME_LATE');
%       H5P.set_alloc_time(dcpl,alloc_time);
%       dset_id = H5D.create(fid,'DS',type_id,space_id,lcpl,dcpl,dapl);
%       H5D.close(dset_id);
%       H5F.close(fid);
%         
%   See also H5P, H5P.get_alloc_time.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:22:37 $

id = H5ML.unwrap_ids(plist_id);
H5ML.hdf5lib2('H5Pset_alloc_time', id, alloc_time);            
