function hline = freqplotter(ax, W, H, xunits, xscale, lco, lso)
%FREQPLOTTER Plot the frequency data
%   AX - Handle to an axes
%   W - frequency info
%   H - Y info
%   xunits (Hz, kHz, etc)
%   xscale (log vs linear)

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.6.4.5 $  $Date: 2007/12/14 15:15:51 $

error(nargchk(3,7,nargin,'struct'));
if nargin < 4, xunits = 'rad/sample'; end
if nargin < 5, xscale = 'linear'; end
if nargin < 6, lco    = [1:length(W)]; end
if nargin < 7, lso    = repmat({'-'}, 1, length(W)); end

hline = [];

wmin = inf;
wmax = -inf;

np = get(ax, 'NextPlot'); set(ax, 'NextPlot', 'Add');
for indx = 1:length(H),
    hline = [hline; line(W{indx}, H{indx}, ...
        'Parent', ax, ...
        'Color', getcolorfromindex(ax, lco(indx)), ...
        'LineStyle', lso{indx})];
    wmin = min(wmin, min(W{indx}));
    wmax = max(wmax, max(W{indx}));
end

set(ax, ...
    'XLim', [wmin wmax], ...
    'XScale', xscale, ...
    'NextPlot', np);
xlabel(ax, getfreqlbl(xunits));

% [EOF]
