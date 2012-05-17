function updatelimits(hObj, varargin)
%UPDATELIMITS Update the limits of the axes

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2009/01/05 18:00:58 $

[xlim, ylim] = calculatelimits(hObj, varargin{:});

h  = get(hObj, 'Handles');

if ~(isfield(h, 'unitcircle') && ishghandle(h.unitcircle)),
    theta = linspace(0,2*pi,200);
    h.unitcircle = line(cos(theta),sin(theta),'LineStyle', ':', ...
        'Parent', h.axes, 'Tag', 'unitcircle');
end

xdata = get(h.unitcircle, 'xdata');
ydata = get(h.unitcircle, 'ydata');
if length(xdata) > 70
    xdata(end-5:end) = [];
    ydata(end-5:end) = [];
end

set(h.unitcircle, ...
    'xdata', [xdata NaN xlim NaN  0   0], ...
    'ydata', [ydata NaN 0    0    NaN ylim], ...
    'hittest', 'off', 'visible', hObj.Visible);
set(h.axes,  'xlim', xlim, 'ylim', ylim);
% 'xlimmode', 'manual', 'ylimmode', 'manual',
set(hObj, 'Handles', h);

% ------------------------------------------------------------
function [xlim, ylim] = calculatelimits(hObj, hPZ)

h = get(hObj, 'Handles');

% Convert the coordinates to x and y
if nargin < 2 || isempty(hPZ),
    xs = real([get(hObj, 'Zeros'); get(hObj, 'Poles')]);
    ys = imag([get(hObj, 'Zeros'); get(hObj, 'Poles')]);
else
    xs = real(double(hPZ, 'conj'));
    ys = imag(double(hPZ, 'conj'));
end

% Get the x and y limits.
xlim = [min(xs) max(xs)];
ylim = [min(ys) max(ys)];

if isempty(xlim), xlim = [-1 1]; end
if isempty(ylim), ylim = [-1 1]; end

if xlim(1) > -1, xlim(1) = -1; end
if xlim(2) < 1,  xlim(2) = 1;  end
if ylim(1) > -1, ylim(1) = -1; end
if ylim(2) < 1,  ylim(2) = 1;  end

% Find the ratio of the axes width and height.
units = get(h.axes,'Units'); set(h.axes,'Units','Pixels')
apos = get(h.axes,'Position'); set(h.axes,'Units',units)

nratio = apos(3)/apos(4);
cratio = diff(xlim)/diff(ylim);

% Calculate the new limits based on the ratio of the axes dimensions and
% the ratio of the xdistance and ydistance.  This is a little faster than
% HG and we dont have to worry about any weird HG issues.
if cratio < nratio,
    
    d = .05*diff(ylim);
    ylim = ylim - [d -d];
    
    m = nratio*diff(ylim)/diff(xlim);
    
    xlim = xlim*m;
else
    d = .05*diff(xlim);
    xlim = xlim - [d -d];
    
    m = nratio*diff(ylim)/diff(xlim);
    
    ylim = ylim/m;
end

% [EOF]
