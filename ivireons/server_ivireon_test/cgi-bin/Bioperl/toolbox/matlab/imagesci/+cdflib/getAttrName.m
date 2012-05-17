function name = getAttrName(cdfId,attrNum)
%cdflib.getAttrName Return name attached to attribute
%   name = cdflib.getAttrName(cdfId,attrNum) returns the name of the attribute
%   identified by attrNum in the CDF identified by cdfId.
%
%   This function corresponds to the CDF library C API routine 
%   CDFgetAttrName.  
%
%   Example:  Retrieve the name of the first attribute.
%       cdfid = cdflib.open('example.cdf');
%       attrName = cdflib.getAttrName(cdfid,0);
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.createAttr.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2010/05/13 17:40:45 $

name = cdflibmex('getAttrName',cdfId,attrNum);
