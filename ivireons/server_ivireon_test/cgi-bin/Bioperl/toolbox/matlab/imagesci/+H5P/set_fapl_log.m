function set_fapl_log(fapl_id, logfile, flags, buf_size)
%H5P.set_fapl_log  Set use of logging driver.
%   H5P.set_fapl_log(fapl_id, logfile, flags, buf_size) modifies the file
%   access property list, fapl_id, to use the logging driver H5FD_LOG.
%   logfile is the name of the file in which the logging entries are to be
%   recorded. flags is a bit mask that specifies the types of activity to
%   log. See the HDF5 documentation for a list of available flag settings.
%   buf_size specifies the size of the logging buffer.
%
%   See also H5P.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:22:54 $

id = H5ML.unwrap_ids(fapl_id);
H5ML.hdf5lib2('H5Pset_fapl_log', id, logfile, flags, buf_size);            
