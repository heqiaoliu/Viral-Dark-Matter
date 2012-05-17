function [version,release,increment] = getLibraryVersion()
%cdflib.getLibraryVersion Return library version and release information
%   [version,release,increment] = cdflib.getLibraryVersion() returns the 
%   library version number, release number, and increment number.
%
%   This function corresponds to the CDF library C API routine 
%   CDFgetLibraryVersion.  
%
%   Example:
%       [version,release,increment] = cdflib.getLibraryVersion;
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.getVersion

% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2010/05/13 17:40:58 $

[version,release,increment] = cdflibmex('getLibraryVersion');
