function b = enablemask(hObj)
%ENABLEMASK Returns true if the mask points to grpdelay

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/08/28 19:21:15 $

if ~frequencyresp_enablemask(hObj) || ...
    ~strcmpi(hObj.Filters.Filter.MaskInfo.response, 'groupdelay'),
    
    b = false;
else
    b = true;
end