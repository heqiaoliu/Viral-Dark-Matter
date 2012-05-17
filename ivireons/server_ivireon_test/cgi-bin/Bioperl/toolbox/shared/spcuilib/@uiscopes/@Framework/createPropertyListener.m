function hListener = createPropertyListener(this, callbackFcn)
%CREATEPROPERTYLISTENER Create a listener on all the properties.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/11/18 02:14:48 $

% Get all of the Configurations.
hc = get(this.ExtDriver.ExtensionDb.allChild, 'Config');
if iscell(hc)
    hc = [hc{:}];
end

% Get all of the Property Databases
hp = get(hc, 'PropertyDb');
if iscell(hp)
    hp = [hp{:}];
end

% Create a single listener on all the property databases.
hListener = handle.listener(hp, 'PropertyChanged', callbackFcn);

% [EOF]
