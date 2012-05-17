function maxEntry = getAttrMaxEntry(cdfId,attrNum)
%cdflib.getAttrMaxEntry Return last entry number of CDF variable attribute
%   maxEntry = cdflib.getAttrMaxEntry(cdfId,attrNum) returns the last entry
%   number of the variable attribute specified by attrNum in the CDF 
%   specified by cdfId.
%
%   This function corresponds to the CDF library C API routine 
%   CDFgetAttrMaxzEntry.  
%
%   Example:
%       cdfid = cdflib.open('example.cdf');
%       attrnum = cdflib.getAttrNum(cdfid,'Description');
%       maxEntry = cdflib.getAttrMaxEntry(cdfid,attrnum);
%       for j = 0:maxEntry
%           entry = cdflib.getAttrEntry(cdfid,attrnum,j);
%       end
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.getAttrMaxgEntry.

% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2010/05/13 17:40:43 $

maxEntry = cdflibmex('getAttrMaxEntry',cdfId,attrNum);
