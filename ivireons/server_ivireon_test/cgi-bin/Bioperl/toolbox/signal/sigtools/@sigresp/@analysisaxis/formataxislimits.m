function formataxislimits(this)
%FORMATAXISLIMITS   

%   Author(s): J. Schickler
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/06/27 23:40:55 $

h = get(this, 'Handles');

ydata = get(h.line, 'YData');

if isempty(ydata)
    return;
end

% Compute global Y-axis limits over potentially
% multiple filter magnitude responses
%
yMin =  Inf;  % min global y-limit
yMax = -Inf;  % max global y-limit
if ~iscell(ydata)
    ydata = {ydata};
end
for indx = 1:length(ydata) % Loop over the filter responses.
    thisResponse = ydata{indx};

    yMin = min(yMin, min(thisResponse));
    yMax = max(yMax, max(thisResponse));
end

% Make sure that the yMin and yMax aren't within a small range.
% This can happen in the GRPDELAY case for linear phase filters.
if yMax-yMin < eps^(1/4)
    yMin = yMin-.5;
    yMax = yMax+.5;
else
    MarginTop = 0.05;  % 5% margin of dyn range at top
    MarginBot = 0.05;  % ditto

    dr = yMax-yMin;
    
    yMin = yMin-dr*MarginBot;
    yMax = yMax+dr*MarginTop;
end

% If the response doesn't work well with the zoom, just use [0 1].
if yMin == Inf
    yMin = 0;
end

if yMax == -Inf
    yMax = 1;
end

set(h.axes, 'YLim',[yMin yMax]);

% [EOF]
