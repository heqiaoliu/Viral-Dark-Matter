function attr = read(attr_id, dtype_id)
%H5A.read  Read attribute.
%   attr = H5A.read(attr_id, dtype_id) reads the attribute specified by
%   attr_id. dtype_id specifies the attribute's memory datatype.  The
%   memory datatype may be 'H5ML_DEFAULT', which specifies that MATLAB
%   should determine the appropriate memory datatype.
%
%   Note:  The HDF5 library uses C-style ordering for multidimensional 
%   arrays, while MATLAB uses FORTRAN-style ordering.  If the HDF5 library
%   reports the attribute size as 3-by-4-by-5, then the corresponding 
%   MATLAB array size is 5-by-4-by-3.  Please consult "Using the MATLAB 
%   Low-Level HDF5 Functions" in the MATLAB documentation for more
%   information.
%
%   Example:
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       gid = H5G.open(fid,'/');
%       attr_id = H5A.open(gid,'attr1','H5P_DEFAULT');
%       data = H5A.read(attr_id,'H5ML_DEFAULT');
%       H5A.close(attr_id);
%       H5G.close(gid);
%       H5F.close(fid);
%
%   See also H5A, H5A.open, H5A.write.

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $ $Date: 2010/04/15 15:19:47 $

[id, d_id] = H5ML.unwrap_ids(attr_id, dtype_id);

% convert the H5ML_DEFAULT parameter, if present.
if ischar(d_id) && strcmp(d_id,'H5ML_DEFAULT')
	d_id = H5ML.hdf5lib2('H5MLget_mem_datatype', id);
end

attr = H5ML.hdf5lib2('H5Aread', id, d_id);            
