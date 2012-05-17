function name = getName(cdfId)
%cdflib.getName Return file name of specified CDF
%   name = cdflib.getName(cdfId) returns the file name of the specified CDF.
%
%   This function corresponds to the CDF library C API routine 
%   CDFgetName.
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.inquire.

% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2010/05/13 17:41:00 $

name = cdflibmex('getName',cdfId);
