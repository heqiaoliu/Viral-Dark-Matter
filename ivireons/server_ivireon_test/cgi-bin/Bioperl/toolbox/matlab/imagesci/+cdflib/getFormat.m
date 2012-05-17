function fmt = getFormat(cdfId)
%cdflib.getFormat Return file format of a CDF
%   fmt = cdflib.getFormat(cdfId) returns the file format, either 
%   'SINGLE_FILE' or 'MULTI_FILE', of a CDF file identified by cdfId.
%
%   This function corresponds to the CDF library C API routine 
%   CDFgetFormat.  
%
%   Example:
%       cdfid = cdflib.open('example.cdf');
%       fmt = cdflib.getFormat(cdfid);
%       cdflib.close(cdfid);
%       fprintf('The format is %s.\n', fmt);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.setFormat, cdflib.getConstantValue.

% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2010/05/13 17:40:56 $

fmt = cdflibmex('getFormat',cdfId);
