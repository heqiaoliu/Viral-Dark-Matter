function resize(hXP)
%RESIZE Resize the export dialog
%   RESIZE(hDlg) Resize the export dialog according to the number of variables
%   that the dialog is going to be exporting

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/11/21 15:31:01 $

% This can be a private method

hFig = get(hXP,'FigureHandle');
h    = get(hXP,'Handles');
sz   = export_gui_sizes(hXP);

setunits(hXP, 'Pixels');

% Use the new figure position.
figPos        = get(hFig,'Position');
figPos([3 4]) = sz.fig(3:4);
set(hFig,'Position', figPos);

% Change the size of the frame and label
frPos     = get(h.frame(1), 'Position');
lblPos    = get(h.frame(2), 'Position');
lblPos(2) = lblPos(2) + (sz.tframe(2)-frPos(2));
set(h.frame(1), 'Position', sz.tframe);
set(h.frame(2), 'Position', lblPos);

if isfield(h, 'aframe'),
    frPos     = get(h.aframe(1), 'Position');
    lblPos    = get(h.aframe(2), 'Position');
    lblPos(2) = lblPos(2) + (sz.aframe(2)-frPos(2));
    set(h.aframe(1), 'Position', sz.aframe);
    set(h.aframe(2), 'Position', lblPos);
    
    set(h.apopup, 'Position', sz.apopup);
end

% Change the size of the frame and label
frPos     = get(h.vframe(1), 'Position');
lblPos    = get(h.vframe(2), 'Position');
lblPos(2) = lblPos(2) + (sz.nframe(4)-frPos(4));
set(h.vframe(1), 'Position', sz.nframe);
set(h.vframe(2), 'Position', lblPos);

% Change the size of the popup
set(h.popup, 'Position', sz.tpopup);

% [EOF]
