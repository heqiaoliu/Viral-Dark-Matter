function plotline(this,W,H)
%PLOTLINE   Set up the axes and plot the line.

%   Author(s): P. Pacheco
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/06/06 17:07:00 $

hFig = this.FigureHandle; 

% Plot the spectrum and set ylabel.
h = get(this, 'Handles');
h.line = freqplotter(h.axes, W, H);

ylbl = get(this, 'MagnitudeDisplay');
hylbl = ylabel(h.axes, ylbl);

% Install the context menu for changing units of the Y-axis.
if ~ishandlefield(this, 'magcsmenu'),
    h.magcsmenu = contextmenu(getparameter(this, getmagdisplaytag(this)), hylbl);
end
set(this, 'Handles', h);  % Store handles to new HG objects created.

% Store the handle to the object for QE/debugging purposes.
%sigsetappdata(hFig,'siggui','powerresp','handle',this);

% [EOF]
