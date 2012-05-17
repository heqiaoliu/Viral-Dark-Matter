function multipathaxes_reset(h)
%MULTIPATHAXES_RESET  Reset axes object.

%   Copyright 1996-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/01/05 17:45:28 $

if ishghandle(h.AxesHandle)
    delete(h.AxesHandle);
end

h.AxesHandle = axes(...
    'parent', h.ParentHandle, ...
    'tag', h.Tag, ...
    'units', 'pixels', ...
    'position', h.Position, ...
    'fontsize', 10, ...
    'NextPlot', 'add', ...
    'Visible', 'off');

grid(h.AxesHandle, 'on');

title(h.AxesHandle, h.Title);
xlabel(h.AxesHandle, h.XLabel);
ylabel(h.AxesHandle, h.YLabel);

h.PlotHandles = [];
h.AuxObjHandles = [];

h.FirstPlot = true;