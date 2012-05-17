function [ctype,cparms,cpercentage] = getCompression(cdfId)
%cdflib.getCompression Return CDF file compression settings
%   [ctype,cparms,cpercentage] = cdflib.getCompression(cdfId) returns the 
%   compression type ctype, compression parameters cparms, and the 
%   compression percentage cpercentage.  
%
%   This function corresponds to the CDF library C API routine 
%   CDFgetCompression.  
%
%   Example:
%       cdfid = cdflib.open('example.cdf');
%       [ctype,cparms,cpercentage] = cdflib.getCompression(cdfid);
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
% 
%   See also cdflib, cdflib.setCompression, cdflib.getVarCompression, 
%   cdflib.setVarCompression.

% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2010/05/13 17:40:51 $

[ctype,cparms,cpercentage] = cdflibmex('getCompression',cdfId);
