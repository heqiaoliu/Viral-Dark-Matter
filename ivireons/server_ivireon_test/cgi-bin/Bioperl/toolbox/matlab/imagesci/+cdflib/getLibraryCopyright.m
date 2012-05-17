function copyright = getLibraryCopyright()
%cdflib.getLibraryCopyright Return copyright notice
%   copyright = cdflib.getLibraryCopyright() returns the copyright notice of
%   the CDF library being used.
%
%   This function corresponds to the CDF library C API routine 
%   CDFgetLibraryCopyright.  
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.getCopyright.

% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2010/05/13 17:40:57 $

copyright = cdflibmex('getLibraryCopyright');
