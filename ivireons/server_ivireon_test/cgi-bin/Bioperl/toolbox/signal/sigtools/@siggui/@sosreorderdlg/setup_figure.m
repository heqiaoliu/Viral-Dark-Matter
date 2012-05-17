function setup_figure(this)
%SETUP_FIGURE   Setup the dialog's figure.

%   Author(s): J. Schickler
%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/05/23 08:17:03 $

sz = gui_sizes(this);
cbs = dialog_cbs(this);

if ispc,
    pos = [200 200 560 380]*sz.pixf;
else
    pos = [200 200 620 368]*sz.pixf;
end

this.FigureHandle = figure('menubar', 'none', ...
    'Position', pos, ...
    'HandleVisibility', 'Off', ...
    'Visible', 'Off', ...
    'NumberTitle', 'Off', ...
    'Resize', 'Off', ...
    'Color', get(0, 'defaultuicontrolbackgroundcolor'), ...
    'Name', fdatoolmessage('SOSReorderDlgTitle'), ...
    'CloseRequestFcn', cbs.cancel);

% [EOF]
