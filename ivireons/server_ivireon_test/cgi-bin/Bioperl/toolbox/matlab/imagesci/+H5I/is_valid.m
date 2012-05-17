function tf = is_valid(obj_id)
%H5I.is_valid  Determine if specified identifier is valid. 
%   tf = H5I.is_valid(obj_id) determines whether the identifier obj_id is
%   valid. 
%
%   Example:
%       fapl = H5P.create('H5P_FILE_ACCESS');
%       H5P.close(fapl);
%       if H5I.is_valid(fapl);
%           fprintf('File access property list is valid.\n');
%       else
%           fprintf('File access property list is not valid.\n');
%       end
%
%   See also H5I.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $ $Date: 2010/05/13 17:39:59 $

[id] = H5ML.unwrap_ids(obj_id);
tf = H5ML.hdf5lib2('H5Iis_valid', id);            
