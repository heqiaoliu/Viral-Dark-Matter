function free_space = get_freespace(file_id)
%H5F.get_freespace  Return amount of free space in file.
%   free_space = H5F.get_freespace(file_id) returns the amount of space 
%   that is unused by any objects in the file specified by file_id.
%
%   See also H5F.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:20:24 $

id = H5ML.unwrap_ids(file_id);
free_space = H5ML.hdf5lib2('H5Fget_freespace', id);            
