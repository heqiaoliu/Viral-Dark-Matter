function thisrender(this)
%RENDER The Render method for the Dialog

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.3 $  $Date: 2004/04/13 00:22:51 $

setup_figure(this);
    
% Make sure that hFig falls within our minimum size limits
checkfigure(this);

render_buttons(this);

% RENDER_CONTROLS must be overloaded
render_controls(this);

% Create the reset transaction
resetoperations(this);

attachlisteners(this);

% -------------------------------------------------
function checkfigure(this)
%CHECKFIGURE Verify that the figure is acceptable for a dialog

hFig = get(this,'FigureHandle');

% Make sure that the figure matches the UDD object settings
set(hFig,'WindowStyle', this.WindowStyle);

sz = dialog_gui_sizes(this);

% Set the minimum limits
minWidth  = sz.minwidth;
minHeight = sz.minheight;

% Cache the old units and set them to pixels
origUnits = get(hFig,'Units');
set(hFig,'Units','Pixels');

% Get the old position
pos = get(hFig,'Position');

% Check if any of the positions are too small
if pos(3) < minWidth,  pos(3) = minWidth; end
if pos(4) < minHeight, pos(4) = minHeight; end

% Create the new position
set(hFig,'Position',pos);

% Restore the old units
set(hFig,'Units',origUnits);


% [EOF]
