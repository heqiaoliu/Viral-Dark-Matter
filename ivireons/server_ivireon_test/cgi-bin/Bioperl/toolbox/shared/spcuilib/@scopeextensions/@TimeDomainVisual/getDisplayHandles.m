function displayHandles = getDisplayHandles(this)
%GETDISPLAYHANDLES Get the displayHandles.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/05/20 03:08:04 $

% In HG2 mode, some of the elements of this array may be objects instead of
% handles. So casting those as doubles will return the corresponding
% handles.

lineProps = getPropValue(this, 'LineProperties');

hLines = this.Lines;

% Make sure that we honor the visible setting in the line proeprties
% property.
removeIndex = [];
for indx = 1:min(numel(this.Lines), numel(lineProps))
    if strcmp(lineProps(indx).Visible, 'off')
        removeIndex = [removeIndex indx]; %#ok<AGROW>
    end
end

hLines(removeIndex) = [];

displayHandles = [double(this.Axes) this.Legend double(hLines) ...
    this.InsideXTicks this.InsideYTicks ...
    double(this.TimeOffsetLabel) double(this.TimeOffsetReadout)];
displayHandles = displayHandles(ishghandle(displayHandles));

% [EOF]
