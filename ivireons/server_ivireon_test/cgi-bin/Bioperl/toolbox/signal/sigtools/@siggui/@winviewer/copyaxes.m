function hFig = copyaxes(this, varargin)
%COPYAXES   Copy the axes.

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/01/20 15:36:23 $


hAxes = sigutils.copyAxes(this.Parent, ...
    @(hOld, hNew) lclCopyAxes(this, hNew), varargin{:});

hFig = ancestor(hAxes(1), 'figure');

% -------------------------------------------------------------------------
function hax = lclCopyAxes(this, hFigNew)

isf = strcmpi(get(this, 'FreqDomain'), 'On');
ist = strcmpi(get(this, 'TimeDomain'), 'On');

if ~isf && ~ist,
    hax = [];
    return;
end

h = get(this, 'Handles');

if ist && isf
    
    hax(1) = copyobj(h.axes.td, hFigNew);
    hax(2) = copyobj(h.axes.fd, hFigNew);
    
    set(hax(1), 'Position', [0.13 0.11 0.33466 0.815]);
    set(hax(2), 'Position', [0.57 0.11 0.33466 0.815]);
    
elseif ist
    
    hax = copyobj(h.axes.td, hFigNew);
    
    set(hax, 'Position', [0.1300 0.1100 0.7750 0.8150]);
else
    
    hax = copyobj(h.axes.fd, hFigNew);

    set(hax, 'Position', [0.1300 0.1100 0.7750 0.8150]);
end

hleg = findobj(this.FigureHandle, 'Tag', 'legend');
if ~isempty(hleg)
    hlegnew = copyobj(hleg, hFigNew);
    oldpos = get(hlegnew, 'position');
    set(hlegnew, 'Position', [.71 .85 oldpos(3:4)]);
end

% [EOF]
