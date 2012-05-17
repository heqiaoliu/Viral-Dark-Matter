function hax = copyaxes(this, varargin)
%COPYAXES Copy the axes to a new figure

%   Author(s): J. Schickler
%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2009/07/14 04:03:40 $ 

% Check if there are any markers on the source figure and set up the figure
% to copy those.
hFigOld = ancestor(this.Parent, 'figure');

hax = sigutils.copyAxes(hFigOld, @(hOld, hNew) lclCopyAxes(this, hNew), varargin{:});

% -------------------------------------------------------------------------
function hax = lclCopyAxes(this, hFigNew)

% Make sure that the bottom axes is copied first.
hax = copyobj([gettopaxes(this) getbottomaxes(this)], hFigNew);

% Work around for g211899, label visible state not being copied correctly.
if length(hax) > 1
    set(get(hax(2), 'XLabel'), 'Visible','off');
end

set(hax, 'OuterPosition', [0 0 1 1]);

h = get(this, 'Handles');
if isfield(h, 'legend') && ishghandle(h.legend)
    hax(end+1) = copyobj(h.legend, hFigNew);
    oldAxPos = getpixelposition(gettopaxes(this));
    newAxPos = getpixelposition(hax(1));
    oldLePos = getpixelposition(h.legend);
    
    oldPos = getpixelposition(hax(end));
    
    % Reposition the legend so that it is in the same relative position
    % as it was in the old figure.
    setpixelposition(hax(end), [ ...
        (oldLePos(1)-oldAxPos(1))/oldAxPos(3)*newAxPos(3)+newAxPos(1) ...
        (oldLePos(2)-oldAxPos(2))/oldAxPos(4)*newAxPos(4)+newAxPos(2) ...
        oldPos(3:4)])
end

% [EOF]
