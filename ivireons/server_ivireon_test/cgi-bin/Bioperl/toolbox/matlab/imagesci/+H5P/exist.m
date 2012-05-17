function value = exist(prop_id, name)
%H5P.exist  Determine if specified property exists in property list.
%   value = H5P.exist(prop_id, name) returns a positive value if the 
%   property specified by the text string name exists within the property 
%   list or class specified by prop_id.  
%
%   Example:
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       fapl = H5F.get_access_plist(fid);
%       if H5P.exist(fapl,'sieve_buf_size')
%           fprintf('sieve buffer size property exists\n');
%       else
%           fprintf('sieve buffer size property does not exist\n');
%       end
%
%   See also H5P.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:21:38 $

id = H5ML.unwrap_ids(prop_id);
value = H5ML.hdf5lib2('H5Pexist', id, name);            
