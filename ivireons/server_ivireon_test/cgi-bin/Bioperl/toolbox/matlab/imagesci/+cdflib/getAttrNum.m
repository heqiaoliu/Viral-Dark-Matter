function attrNum = getAttrNum(cdfId,name)
%cdflib.getAttrNum Return attribute number
%   attrNum = cdflib.getAttrNum(cdfId,name) returns the attribute number 
%   associated with the attribute name.  
%
%   This function corresponds to the CDF library C API routine 
%   CDFgetAttrNum.  
%
%   Example:
%       cdfid = cdflib.open('example.cdf');
%       attrNum = cdflib.getAttrNum(cdfid,'SampleAttribute');
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.createAttr, cdflib.getAttrname

% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2010/05/13 17:40:46 $

attrNum = cdflibmex('getAttrNum',cdfId,name);
