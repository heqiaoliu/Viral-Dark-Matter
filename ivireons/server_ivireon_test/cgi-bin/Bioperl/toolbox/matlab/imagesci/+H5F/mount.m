function mount(varargin)
%H5F.mount  Mount HDF5 file onto specified location.
%   H5F.mount(loc_id, name, child_id, plist_id) mounts the file specified 
%   by child_id onto the group specified by loc_id and name, using the 
%   mount properties specified by plist_id.   
%
%   See also H5F, H5F.unmount.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:20:33 $

[varargin{:}] = H5ML.unwrap_ids(varargin{:});
H5ML.hdf5lib2('H5Fmount', varargin{:});            
