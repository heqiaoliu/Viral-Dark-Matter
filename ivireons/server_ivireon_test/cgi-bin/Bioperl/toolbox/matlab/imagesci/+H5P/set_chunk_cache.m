function set_chunk_cache(dapl_id, varargin)
%H5P.set_chunk_cache  Set raw data chunk cache parameters.  
%   H5P.set_chunk_cache(dapl_id, rdcc_nslots, rdcc_nbytes, rdcc_w0) sets
%   the number of elements (rdcc_nslots), the total number of bytes
%   (rdcc_nbytes), and the preemption policy value (rdcc_w0) in the raw
%   data chunk cache.
%
%   Example:
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       dset_id = H5D.open(fid,'/g3/vlen3D');
%       dapl = H5D.get_access_plist(dset_id);
%       H5P.set_chunk_cache(dapl,500,1e6,0.7);
%       H5P.close(dapl);
%       H5D.close(dset_id);
%       H5F.close(fid);
%
%   See also H5P, H5P.get_chunk_cache.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2010/04/15 15:22:44 $

id = H5ML.unwrap_ids(dapl_id);
H5ML.hdf5lib2('H5Pset_chunk_cache', id, varargin{:});            
