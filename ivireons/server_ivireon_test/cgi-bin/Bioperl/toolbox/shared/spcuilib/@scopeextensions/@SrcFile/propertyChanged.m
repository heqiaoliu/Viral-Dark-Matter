function propertyChanged(this, eventData)
%PROPERTYCHANGED property change event handler

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/23 19:06:39 $

hProp     = get(eventData, 'AffectedObject');
Value = get(hProp, 'Value');

switch hProp.Name
    case 'LastConnectFileOpened'
        this.LastConnectFileOpened = Value;
end

% [EOF]
