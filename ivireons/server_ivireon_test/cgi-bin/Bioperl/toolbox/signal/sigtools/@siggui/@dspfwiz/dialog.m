function dialog(this)
%DIALOG   Launch a dialog for the DSPFWIZ panel.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/19 21:46:15 $

if ~isrendered(this)

    sz = gui_sizes(this);
    
    % Create a figure for the export dialog.
    hFig = figure( ...
        'Visible', 'Off', ...
        'Resize', 'Off', ...
        'Tag',    'siggui.dspfwiz', ...
        'Menubar', 'none', ...
        'HandleVisibility', 'callback', ...
        'Integerhandle', 'off', ...
        'Color', get(0, 'defaultuicontrolbackgroundcolor'), ...
        'NumberTitle', 'off', ...
        'Position', [300 300 456 208]*sz.pixf);

    % Render the object to the figure.
    render(this, hFig, [5 5 450 200]*sz.pixf);

    % Center the figure on the screen.
    movegui(hFig, 'center');
    
    % Create listeners on the filter to update the dialog title and on this
    % object being destroyed so that we can clean up the dialog.
    l = [handle.listener(this, this.findprop('Filter'), 'PropertyPostSet', ...
        @(hp, ed) updateName(this)); ...
        handle.listener(this, 'ObjectBeingDestroyed', @(h, ed) delete(hFig));];
    setappdata(hFig, 'FilterListener', l);
    
    updateName(this);
end

set(this, 'Visible', 'On');
set(this.FigureHandle, 'Visible', 'On');

% -------------------------------------------------------------------------
function updateName(this)

hFig = get(this, 'FigureHandle');

set(hFig, 'Name', sprintf('Export to Simulink (%s, order = %d)', ...
    this.Filter.FilterStructure, order(this.Filter)));

% [EOF]
