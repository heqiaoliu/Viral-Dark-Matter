function setcoincidentgrid(hallax)
%SETCOINCIDENTGRID Set coincident grids for two axes.
%
%   SETCOINCIDENTGRID(HAXES) creates coincident grids for the
%   two Y-axes specified by the two element vector of axes handles
%   HAXES.

%   Author(s): P. Costa
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.3.4.3 $  $Date: 2009/01/05 17:59:52 $

% Determine which axis is "left" this is the one with the locked axis.
fixedIndex = find(strcmpi(get(hallax, 'yaxisLocation'), 'left'));
if length(fixedIndex) ~= 1
    error(generatemsgid('GUIErr'),'SETCOINCIDENTGRID requires one axis be left aligned and one be right aligned.');
end

hFixed    = hallax(fixedIndex);
hNotFixed = hallax(3-fixedIndex);

addlistener(hFixed, 'YTick', 'PostSet', @(hAx, ed) synchronizeAxes(hFixed, hNotFixed));

synchronizeAxes(hFixed, hNotFixed);

% -------------------------------------------------------------------------
function synchronizeAxes(hFixed, hNotFixed)

if ~ishghandle(hNotFixed)
    return
end

% Get the YLim and YRange of each axis.
fixedLim    = getYLim(hFixed);
notFixedLim = getYLim(hNotFixed);

fixedRange    = fixedLim(2)-fixedLim(1);
notFixedRange = notFixedLim(2)-notFixedLim(1);

% Get the ticks of the "fixed" axis.
fixedTick = get(hFixed, 'YTick');

% Remove INFs and NaNs from the ticks.
fixedTick(isnan(fixedTick)) = [];
fixedTick(isinf(fixedTick)) = [];

notFixedTick = zeros(length(fixedTick), 1);

for indx = 1:length(fixedTick)

    % Determine what the ticks on the "nonfixed" axis must be to match
    % those on the fixed axis.
    notFixedTick(indx) = notFixedLim(2) - ...
        notFixedRange*(fixedLim(2)-fixedTick(indx))/fixedRange;
end

% Set the non fixed axis' ticks to match the grid.
set(hNotFixed, 'YTick', notFixedTick);

% -------------------------------------------------------------------------
function ylim = getYLim(hax)

ylim = get(hax, 'YLim');

% Make sure there are no INF or NANS in the YLim because this will break
% the algorithm.
if any(isnan(ylim)) || any(isinf(ylim))
    set(hax, 'YLimMode', 'auto');
    ylim = get(hax, 'YLim');
end

% [EOF]
