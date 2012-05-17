function propertyChanged(this, eventData)
%PROPERTYCHANGED Update the zoom state when a property changes.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/11/18 01:41:24 $

if ischar(eventData)
    pName = eventData;
    value = get(this.findProp(pName), 'Value');
else
    hProp = get(eventData, 'AffectedObject');
    value = get(hProp, 'Value');
    pName = hProp.Name;
end

switch pName
    case 'Magnification'
        if ~strcmpi(this.Mode, 'fittoview')
            hVideo = this.Application.Visual;
            
            % Set the magnification of the scroll panel.
            hAPI = iptgetapi(hVideo.ScrollPanel);
            hAPI.setMagnification(value);
        end
    case 'FitToView'
        if value == true
            set(this, 'Mode', 'FitToView');
        elseif value == false && strcmpi(this.Mode, 'fittoview')
            
            % Only go to Mode 'off' when we are on fit to view.  Do not
            % turn off an existing zoom mode.
            set(this, 'Mode', 'off');
        end
end

% [EOF]
