function setup_figure(hFs)
%SETUP_FIGURE Setup the figure for the fsdialog

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 23:25:41 $

sz = fsdialog_gui_sizes(hFs);
bgc = get(0,'defaultuicontrolbackgroundcolor');

% Create a dialog
hFig = dialog('Name', 'Frequency Specifications', ...
    'Position', sz.figpos, ...
    'Visible', 'Off', ...
    'Color', bgc);

set(hFs, 'FigureHandle', hFig);

% [EOF]
