function doAutoScrollShift(dp,shiftPix)
% Shift docked dialogs except the one currently being dragged by shiftPix
%
% This is done during AutoScroll, where a dialog has been dragged to the
% upper or lower panel limit, after which the remaining panels
% automatically scroll up/down past this dialog.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:39:40 $

% Shift cache of original panel positions
m = dp.MouseOverDialog;
m(2:3) = m(2:3) + shiftPix; % dialog_ystart, mouse_ystart
dp.MouseOverDialog = m;

% shift all docked dialogs EXCEPT this one
visDlgs = dp.DockedDialogs;
Nvis = numel(visDlgs);
thisID = dp.MouseOverDialogDlg.DialogContent.ID;
for i = 1:Nvis
    dlg_i = visDlgs(i);
    if dlg_i.DialogContent.ID ~= thisID
        h_i = dlg_i.DialogBorder.Panel;
        p = get(h_i,'pos');
        p(2) = p(2) + shiftPix; % change y-coord
        set(h_i,'pos',p);
    end
end

% Update scroll bar value
setScrollBarValue(dp);

