function set_dxpl_multi(dxpl_id, memb_dxpl)
%H5P.set_dxpl_multi  Set data transfer property list for multi-file driver.
%   H5P.set_dxpl_multi(dxpl_id, memb_dxpl) sets the data transfer property
%   list dxpl_id to use the multi-file driver. memb_dxpl is an array of
%   data access property lists.
%
%   See also H5P, H5P.get_dxpl_multi.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:22:48 $

id = H5ML.unwrap_ids(dxpl_id);
for i = 1 : length(memb_dxpl) 
   memb_dxp(i) = H5ML.unwrap_ids(memb_dxpl(i));
end
H5ML.hdf5lib2('H5Pset_dxpl_multi', id, memb_dxp);            
