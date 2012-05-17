function attr_id = create(varargin)
%H5A.create  Create attribute.
%   attr_id = H5A.create(loc_id, name, type_id, space_id, acpl_id) creates
%   the attribute name that is attached to the object specified by loc_id.
%   loc_id is a group, dataset, or named datatype identifier. The datatype
%   and dataspace identifiers of the attribute, type_id and space_id,
%   respectively, are created with the H5T and H5S interfaces. The
%   attribute property list, acpl_id, is currently unused and should be set
%   to 'H5P_DEFAULT'.  This interface corresponds to the 1.6.x version of
%   H5Acreate.
%
%   attr_id = H5A.create(loc_id,name,type_id,space_id,acpl_id,aapl_id) 
%   creates the attribute with the additional attribute access property
%   list identifier aapl_id.  aapl_id should currently be set to 
%   'H5P_DEFAULT'.  This interface corresponds to the 1.8.x version of
%   H5Acreate.
%
%   Example:
%       fcpl = H5P.create('H5P_FILE_CREATE');
%       fapl = H5P.create('H5P_FILE_ACCESS');
%       acpl = H5P.create('H5P_ATTRIBUTE_CREATE');
%       aapl = 'H5P_DEFAULT';
%       type_id = H5T.copy('H5T_NATIVE_DOUBLE');
%       space_id = H5S.create('H5S_SCALAR');
%       fid = H5F.create('myfile.h5','H5F_ACC_TRUNC',fcpl,fapl);
%       attr_id = H5A.create(fid,'my_attr',type_id,space_id,acpl,aapl);
%       H5A.close(attr_id);
%       H5F.close(fid);
%
%   See also H5A, H5A.close, H5P.create.
%   

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:19:34 $

[varargin{:}] = H5ML.unwrap_ids(varargin{:});
id = H5ML.hdf5lib2('H5Acreate', varargin{:} );
attr_id = H5ML.id(id,'H5Aclose');
