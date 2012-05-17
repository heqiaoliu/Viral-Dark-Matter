function [increment, backing_store] = get_fapl_core(fapl_id)
%H5P.get_fapl_core  Return information about core file driver properties.
%   [increment backing_store] = H5P.get_fapl_core(fapl_id) queries the
%   H5FD_CORE driver properties as set by H5P.set_fapl_core. fapl_id
%   specifies a file access property list. The return value increment
%   specifies the size, in bytes, of memory increments. backing_store is a
%   Boolean flag indicating whether to write the file contents to disk when
%   the file is closed.
%
%   See also H5P, H5P.set_fapl_core.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:22:02 $

id = H5ML.unwrap_ids(fapl_id);
[increment, backing_store] = H5ML.hdf5lib2('H5Pget_fapl_core', id);            
