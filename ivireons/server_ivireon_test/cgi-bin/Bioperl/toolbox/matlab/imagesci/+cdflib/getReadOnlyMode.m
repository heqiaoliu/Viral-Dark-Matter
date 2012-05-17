function mode = getReadOnlyMode(cdfId)
%cdflib.getReadOnlyMode Return read-only mode of CDF
%   mode = cdflib.getReadOnlyMode(cdfId) returns the read-only mode of the
%   CDF identified by cdfId.   
%
%   This function corresponds to the CDF library C API routine 
%   CDFgetReadOnlyMode.  
%
%   Example:
%       cdfid = cdflib.open('example.cdf');
%       mode = cdflib.getReadOnlyMode(cdfid);
%       cdflib.close(cdfid);
%       fprintf('The mode is %s.\n', mode);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.setReadOnlyMode.

% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2010/05/13 17:41:05 $

mode = cdflibmex('getReadOnlyMode',cdfId);
