function set_fapl_multi(fapl_id, memb_map, memb_fapl, memb_name, memb_addr, relax)
%H5P.set_fapl_multi  Set use of multi-file driver.
%   H5P.set_fapl_multi(fapl_id, memb_map, memb_fapl, memb_name, memb_addr,
%   relax) sets the file access property list fapl_id to use the multi-file
%   driver H5Pset_fapl_multi. memb_map maps memory usage types to other
%   memory usage types. memb_fapl contains a property list for each memory
%   usage type. memb_name is a name generator for names of member files.
%   memb_addr specifies the offsets within the virtual address space at
%   which each type of data storage begins. relax is a Boolean value that
%   allows read-only access to incomplete file sets when set to 1.
%
%   See also H5P, H5P.get_fapl_multi.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:22:55 $

id = H5ML.unwrap_ids(fapl_id);
for i = 1 : length(memb_fapl)
   memb_fap(i) = H5ML.unwrap_ids(memb_fapl(i));
end
H5ML.hdf5lib2('H5Pset_fapl_multi', id, memb_map, memb_fap, memb_name, memb_addr, relax);            
