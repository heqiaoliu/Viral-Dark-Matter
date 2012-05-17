function hAxes = copyAxes(hSource, copyFcn, hFigNew)
%COPYAXES Copy the axes and retain data markers.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/09 19:35:50 $

% Allow callers to specify lines/axes.
hFigOld = ancestor(hSource, 'figure');

if nargin < 3
    hFigNew = figure('NumberTitle', 'Off', 'Visible', 'Off');
end

% If we are not given a function, just copy all the axes.
if nargin < 2
    copyFcn = @(hSource, hFigNew) lclCopyAxes(hSource, hFigNew);
end

% If there are data markers, set up for the copy.
hasMarkers = isappdata(hFigOld, 'DataCursorManager');
if hasMarkers
    hDCM = getappdata(hFigOld, 'DataCursorManager');
    hDCM.setupDatatipsForCopy;
end

% Copy the axes using the passed function.
hAxes = copyFcn(hFigOld, hFigNew);

% Copy markers.
if hasMarkers
    hDCM.clearDatatipCopyInformation;
    hDCM2 = graphics.datacursormanager(hFigNew);
    targetList = findall(hAxes, '-depth', 1);
    hDCM2.copyDatatipInformation(targetList);
end

% -------------------------------------------------------------------------
function hAxes = lclCopyAxes(hSource, hFigNew)

if ishghandle(hSource, 'figure')
    hAxesOld = findobj(hSource, 'type', 'axes');
else
    hAxesOld = ancestor(hSource, 'axes');
end

hAxes = copyobj(hAxesOld, hFigNew);

% [EOF]
