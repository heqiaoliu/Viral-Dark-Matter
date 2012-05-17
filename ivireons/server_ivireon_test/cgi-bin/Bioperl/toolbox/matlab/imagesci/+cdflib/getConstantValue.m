function cval = getConstantValue(constantName)
%cdflib.getConstantValue Return numeric value corresponding to CDF constant
%   value = cdflib.getConstantValue(constantName) returns the value as 
%   defined by the CDF library corresponding to constantName.  
%
%   Example:  value = cdflib.getConstantValue('NOVARY');
%
%   Please read the file cdfcopyright.txt for more information.
% 
%   See also cdflib, cdflib.getConstantNames

% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2010/05/13 17:40:54 $

cval = cdflibmex('getConstantValue',upper(constantName));
