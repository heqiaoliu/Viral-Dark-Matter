function changedPinnedObjData(hThis)
% This method is called if the object that the pin is attached to changes.
% In this case, delete the pin.

%   Copyright 2006 The MathWorks, Inc.

delete(hThis);