function ngatts = getNumgAttributes(cdfId)
%cdflib.getNumgAttributes Return number of global attributes
%   ngatts = cdflib.getNumgAttributes(cdfId) returns the total number of 
%   global attributes in the CDF specified by cdfId.
%
%   This function corresponds to the CDF library C API routine 
%   CDFgetNumgAttributes.
%
%   Example:  
%       cdfid = cdflib.open('example.cdf');
%       numgAttrs = cdflib.getNumgAttributes(cdfid);
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.getNumAttributes.

% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2010/05/13 17:41:04 $

ngatts = cdflibmex('getNumgAttributes',cdfId);
