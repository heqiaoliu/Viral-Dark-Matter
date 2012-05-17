function set_scaleoffset(plist_id,scaleType,scaleFactor)
%H5P.set_scaleoffset  Setup Scale-Offset filter.
%   H5P.set_scaleoffset(plistId,scaleType,scaleFactor) sets the
%   Scale-Offset filter, H5Z_FILTER_SCALEOFFSET, for a dataset.  For
%   integer datatypes, the parameter scaleType should be set to the
%   enumerated value H5Z_SO_INT.  For floating-point datatypes, the
%   scaleType should be the enumerated value H5Z_SO_FLOAT_DSCALE.  Chunking
%   must already be enabled on the dataset creation property list.
%
%   See also H5P, H5P.set_chunk.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:23:17 $

id = H5ML.unwrap_ids(plist_id);
H5ML.hdf5lib2('H5Pset_scaleoffset',id,scaleType,scaleFactor);            

