function commit(loc_id,name,type_id)
%H5T.commit  Commit transient datatype.
%   H5T.commit(loc_id,name,type_id) commits a transient datatype to a file,
%   creating a new named datatype. loc_id is a file or group identifier. name
%   is the name of the datatype and type_id is the datatype id.  This 
%   interface corresponds to the 1.6.x version of H5Tcommit.
%
%   H5T.commit(loc_id,name,type_id,lcpl_id,tcpl_id,tapl_id) commits a 
%   transient datatype to a file, creating a new named datatype. loc_id 
%   is a file or group identifier. name is the name of the datatype and 
%   type_id is the datatype id.  lcpl_id, tcpl_id, and tapl_id are link
%   creation, datatype creation, and datatype access property list 
%   identifiers.  This interface corresponds to the 1.8.x version of 
%   H5Tcommit.
%
%   Example:  Create a named variable length datatype.
%       plist_id = 'H5P_DEFAULT';
%       fid = H5F.create('myfile.h5','H5F_ACC_TRUNC',plist_id,plist_id);
%       base_type_id = H5T.copy('H5T_NATIVE_DOUBLE');
%       vlen_type_id = H5T.vlen_create(base_type_id);
%       H5T.commit(fid,'MyVlen',vlen_type_id);
%       H5T.close(vlen_type_id);
%       H5T.close(base_type_id);
%       H5F.close(fid);
%
%   See also H5T, H5T.close, H5T.committed.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:24:01 $

[id, t_id] = H5ML.unwrap_ids(loc_id, type_id);
H5ML.hdf5lib2('H5Tcommit', id, name, t_id);            
