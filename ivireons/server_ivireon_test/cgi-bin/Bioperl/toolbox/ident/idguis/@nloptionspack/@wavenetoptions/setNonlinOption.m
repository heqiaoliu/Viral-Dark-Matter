function setNonlinOption(this,PropName,PropVal)
% set nonlinear options field PropName's value to PropValue.

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:32:15 $

if strcmpi(PropName,'FinestCell') 
    if ischar(PropVal) && ~strcmpi(PropVal,'auto')
        PropVal = str2double(PropVal);
    end
end

this.Object.Options.(PropName) = PropVal;
