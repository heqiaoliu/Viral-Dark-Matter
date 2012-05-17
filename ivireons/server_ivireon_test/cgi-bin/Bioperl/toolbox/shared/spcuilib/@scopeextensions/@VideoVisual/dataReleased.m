function dataReleased(this, ev)
%DATARELEASED  React to the data source being uninstalled.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/12/04 23:20:02 $

if ~ev.Data
    hUIMgr = this.Application.getGUI;
    hDims = hUIMgr.findchild({'StatusBar','StdOpts','scopeextensions.VideoVisual Dims'});

    % If we have no data, restore the default, which is Intensity 0x0.
    emptyDataString = '';
    
    if isRendered(hDims)
        hDims.WidgetHandle.Text = emptyDataString;
    else
        hDims.WidgetProperties = {'Text', emptyDataString};
    end

    sp_api = iptgetapi(this.ScrollPanel);
    mag = sp_api.getMagnification();
    sp_api.replaceImage(zeros(1, 1, 'uint8'));
    sp_api.setMagnification(mag);
    set(this.Image, 'Visible', 'off');
end

% [EOF]
