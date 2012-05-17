function size = vlen_get_buf_size(varargin)
%H5D.vlen_get_buf_size  Determine variable length storage requirements.
%   size = H5D.vlen_get_buf_size(dataset_id, type_id, space_id) determines 
%   the number of bytes required to store the VL data from the dataset, 
%   using the space_id for the selection in the dataset on disk and the 
%   type_id for the memory representation of the VL data in memory.
%
%   See also H5D.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:20:03 $

[varargin{:}] = H5ML.unwrap_ids(varargin{:});
size = H5ML.hdf5lib2('H5Dvlen_get_buf_size', varargin{:});            
