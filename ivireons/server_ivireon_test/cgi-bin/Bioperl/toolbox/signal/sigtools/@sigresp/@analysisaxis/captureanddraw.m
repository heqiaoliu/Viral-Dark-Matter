function captureanddraw(this, limits)
%CAPTUREANDDRAW   Capture the zoom state and redraw.
%   CAPTUREANDDRAW(THIS, LIMITS) Capture the zoomstate, redraw and set the
%   zoom state back.  LIMITS can be 'x', 'y', 'both', or 'none'.  It is
%   'both' by default.  When it is 'x' it will zoom back in on the x-axis,
%   when it is 'y' it will zoom back in on the y-axis.

%   Author(s): J. Schickler
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2007/11/17 22:44:49 $

if nargin < 2, limits = 'both'; end

% Cache the current positions.
h = get(this, 'Handles');
for indx = 1:length(h.axes)
    xlim{indx} = get(h.axes(indx), 'XLim'); %#ok
    ylim{indx} = get(h.axes(indx), 'YLim'); %#ok
end

% Redraw the plot.  This will reset the zoom state and cache the "smart
% zoom" state as the zoom out point.
draw(this);

% Reget the handles in case any axes were replaced (unlikely).
h = get(this, 'Handles');
for indx = 1:length(h.axes)

    switch lower(limits)
        case 'x'
            set(h.axes(indx), 'XLim', xlim{indx});
        case 'y'
            set(h.axes(indx), 'YLim', ylim{indx});
        case 'both'
            set(h.axes(indx), 'XLim', xlim{indx}, 'YLim', ylim{indx});
        case 'none'
            % NO OP
        otherwise
            error(generatemsgid('InvalidInput'), '''%s'' is not a valid limit.', limits);
    end
end

% [EOF]
