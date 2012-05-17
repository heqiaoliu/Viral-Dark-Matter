function set_fapl_family(fapl_id, memb_size, memb_fapl_id)
%H5P.set_fapl_family  Set file access to use family driver.
%   H5P.set_fapl_family(fapl_id, memb_size, memb_fapl_id) sets the file
%   access property list, specified by fapl_id, to use the family driver.
%   memb_size is the size in bytes of each file member. memb_fapl_id is the
%   identifier of the file access property list to be used for each family
%   member.
%
%   See also H5P, H5P.get_fapl_family.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:22:53 $

[id, memb_id] = H5ML.unwrap_ids(fapl_id, memb_fapl_id);
H5ML.hdf5lib2('H5Pset_fapl_family', id, memb_size, memb_id);            
