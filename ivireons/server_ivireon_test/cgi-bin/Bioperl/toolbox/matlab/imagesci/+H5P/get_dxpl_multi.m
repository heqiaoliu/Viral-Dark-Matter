function memb_dxpl = get_dxpl_multi(dxpl_id)
%H5P.get_dxpl_multi  Return data access property lists for multiple files.
%   memb_dxpl = H5P.get_dxpl_multi(dxpl_id) returns an array of data access 
%   property lists for the multi-file data transfer property list specified
%   by dxpl_id.
%
%   See also H5P, H5P.set_dxpl_multi.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:21:57 $

id = H5ML.unwrap_ids(dxpl_id);
memb_dxp = H5ML.hdf5lib2('H5Pget_dxpl_multi', id);            
for i = 1 : H5ML.get_constant_value('H5FD_MEM_NTYPES')
   memb_dxpl(i) = H5ML.id(memb_dxp(i),'H5Pclose'); %#ok<AGROW>
end

