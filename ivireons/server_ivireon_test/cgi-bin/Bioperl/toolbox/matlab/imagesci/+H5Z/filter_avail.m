function output = filter_avail(filter_id)
%H5Z.filter_avail  Determine availability of specified filter.
%   output = H5Z.filter_avail(filter_id) determines whether the filter specified
%   by the filter identifier is available to the application.  filter_id
%   may be specified by one of the following strings or its numeric
%   equivalent:
%
%       'H5Z_FILTER_DEFLATE'
%       'H5Z_FILTER_SHUFFLE'
%       'H5Z_FILTER_FLETCHER32'
%       'H5Z_FILTER_SZIP'
%       'H5Z_FILTER_NBIT'
%       'H5Z_FILTER_SCALEOFFSET'
%
%   Example:  determine if the shuffle filter is available.
%       bool = H5Z.filter_avail('H5Z_FILTER_SHUFFLE');
%
%   See also H5Z, H5ML.get_constant_value.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/04/15 15:24:58 $

output = H5ML.hdf5lib2('H5Zfilter_avail', filter_id);            
