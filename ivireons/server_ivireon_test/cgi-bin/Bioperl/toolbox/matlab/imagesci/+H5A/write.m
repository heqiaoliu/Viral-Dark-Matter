function write(varargin)
%H5A.write  Write attribute.
%   H5A.write(attr_id, type_id, buf) writes the data in buf into the
%   attribute specified by attr_id. type_id specifies the attribute's
%   memory datatype. The memory datatype may be 'H5ML_DEFAULT', which
%   specifies that MATLAB should determine the appropriate memory datatype.
%
%   Note:  The HDF5 library uses C-style ordering for multidimensional 
%   arrays, while MATLAB uses FORTRAN-style ordering.  If the MATLAB array
%   size is 5-by-4-by-3, then the HDF5 library should be reporting the
%   attribute size as 3-by-4-by-5. Please consult "Using the MATLAB 
%   Low-Level HDF5 Functions" in the MATLAB documentation for more 
%   information.
%
%   Example:  write a scalar double precision attribute.
%       fcpl = H5P.create('H5P_FILE_CREATE');
%       fapl = H5P.create('H5P_FILE_ACCESS');
%       acpl = H5P.create('H5P_ATTRIBUTE_CREATE');
%       aapl = 'H5P_DEFAULT';
%       type_id = H5T.copy('H5T_NATIVE_DOUBLE');
%       space_id = H5S.create('H5S_SCALAR');
%       fid = H5F.create('myfile.h5','H5F_ACC_TRUNC',fcpl,fapl);
%       attr_id = H5A.create(fid,'my_attr',type_id,space_id,acpl,aapl);
%       H5A.write(attr_id,'H5ML_DEFAULT',10.0)
%       H5A.close(attr_id);
%       H5F.close(fid);
%       H5T.close(type_id);
%
%   See also H5A, H5A.read.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.7 $ $Date: 2010/04/15 15:19:48 $

[varargin{:}] = H5ML.unwrap_ids(varargin{:});

H5ML.hdf5lib2('H5Awrite', varargin{:});            
