function [memb_size, memb_fapl_id] = get_fapl_family(fapl_id)
%H5P.get_fapl_family  Return file access property list information.
%   [memb_size memb_fapl_id] = H5P.get_fapl_family(fapl_id) returns a file
%   access property list for use with the family driver specified by
%   fapl_id.
%
%   See also H5P, H5P.set_fapl_family.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5.2.1 $ $Date: 2010/07/23 15:40:05 $

id = H5ML.unwrap_ids(fapl_id);
[memb_size, raw_memb_fapl_id] = H5ML.hdf5lib2('H5Pget_fapl_family', id);            
memb_fapl_id = H5ML.id(raw_memb_fapl_id,'H5Pclose');

