function dataSourceChanged(this)
%DATASOURCECHANGED React to a new data source being installed.
%   React to a new data source being installed into the scope application.

%   Author(s): J. Schickler
%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.13 $  $Date: 2010/05/20 03:08:11 $

this.ScalingChangedListener.Enabled = 'off';
% Keep the colormap in sync so that it has the latest data information.

source = this.Application.DataSource;

% If the source is invalid, simply return.
if ~validateSource(this, source)
    return;
end

nInputs = getNumInputs(source);
maxDims = getMaxDimensions(source);

dataType = getDataTypes(source, 1);
isRGB = false;
if nInputs == 3
    isRGB = true;
    maxDims = [maxDims(1,:) 3];
    
elseif nInputs == 1
    if numel(maxDims) > 2 && maxDims(3) == 3        
        isRGB = true;
    end
end

frameRows = max(1, maxDims(1));
frameCols = max(1, maxDims(2));

% XXX How do we handle colormap?

% Adjust image limits and axis limits appropriately
%
% Be sure to "blank out" the image
% Must put in an actual image size, so that subsequent truesize
% function will operate correctly.  (Cannot set to empty image.)
%
% In case empty matrix passed in, need to override axis limits

this.DataType      = dataType;
this.isIntensity   = ~isRGB;

% Use replaceImage API function to update the scrollpanel.  Grab the
% current magnification in case it has changed.  replaceImage does not
% maintain the magnification when the size of the image changes.
sp_api = iptgetapi(this.ScrollPanel);
sp_api.replaceImage(zeros(frameRows, frameCols, 'uint8'), ...
    'ColorMap', this.ColorMap.Map, 'PreserveView', true);


updateColorMap(this);

this.OldDimensions = maxDims;
this.MaxDimensions = maxDims;

this.ColorMap.update;
this.ColorMap.updateScaling; % Need to reapply settings because of replaceImage
this.VideoInfo.update;

% Status: 1:size, 2:rate, 3:num
hUIMgr = getGUI(this.Application);
hDims = hUIMgr.findchild({'StatusBar','StdOpts','scopeextensions.VideoVisual Dims'});

sizeStr = sprintf('%dx%d', maxDims(1), maxDims(2));
if isRGB, s='RGB'; else s='I'; end
sizeStr = sprintf('%s:%s', s, sizeStr);
if isRendered(hDims)
    hDims.WidgetHandle.Text = sizeStr;
    hDims.WidgetHandle.Width = ...
        max(hDims.WidgetHandle.Width, largestuiwidth({sizeStr})+2);
else
    hDims.WidgetProperties = {'Text', sizeStr};
end

this.ScalingChangedListener.Enabled = 'on';

% [EOF]
