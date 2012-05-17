function name_listener(hDlg, eventData)
%LABEL_LISTENER Listener to the label property

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2008/05/31 23:28:12 $

name = get(hDlg, 'Label');
sz   = gui_sizes(hDlg);

% Determine the proper width of the label
h   = get(hDlg, 'Handles');
width = largestuiwidth({name});

% h.frame(1) is the frame.
origUnits = get(h.frame(1), 'Units');
set(h.frame(1), 'Units', 'Pixels');
posF = get(h.frame(1), 'Position');
set(h.frame(1), 'Units', origUnits);

% Make sure that the width doesn't exceed the frame
if width > posF(3) - sz.hfus;
    width = posF(3) - sz.hfus;
end

% h.frame(2) is the label
origUnits = get(h.frame(2), 'Units');
set(h.frame(2), 'Units', 'Pixels');
pos = get(h.frame(2), 'Position');
pos(3) = width;

visState = get(hDlg, 'Visible');
if isempty(name),
    visState = 'Off';
end

% Set the new name and position
set(h.frame(2), ...
    'Position', pos, ...
    'string', name, ...
    'Units', origUnits);

% [EOF]
