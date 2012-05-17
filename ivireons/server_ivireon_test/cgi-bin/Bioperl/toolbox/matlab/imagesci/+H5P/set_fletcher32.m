function set_fletcher32(plist_id)
%H5P.set_fletcher32  Set Fletcher32 checksum filter in dataset creation.
%   H5P.set_fletcher32(plist_id) sets the Fletcher32 checksum filter in the 
%   dataset creation property list specified by plist.  The dataset 
%   creation property list must also have chunking enabled.
%
%   Example:  
%         plist_id = 'H5P_DEFAULT';
%         fid = H5F.create('myfile.h5','H5F_ACC_TRUNC',plist_id,plist_id);
%         type_id = H5T.copy('H5T_NATIVE_DOUBLE');
%         dims = [100 200];
%         h5_dims = fliplr(dims);
%         space_id = H5S.create_simple(2,dims,[]);
%         dcpl = H5P.create('H5P_DATASET_CREATE');
%         chunk_dims = [10 20];
%         h5_chunk_dims = fliplr(chunk_dims);
%         H5P.set_chunk(dcpl,h5_chunk_dims);
%         H5P.set_fletcher32(dcpl);
%         dset_id = H5D.create(fid,'DS',type_id,space_id,dcpl);
%         H5D.close(dset_id);
%         H5F.close(fid);
%
%   See also H5P, H5P.set_deflate, H5P.set_shuffle.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:23:03 $

id = H5ML.unwrap_ids(plist_id);
H5ML.hdf5lib2('H5Pset_fletcher32', id);            
