function sz = export_gui_sizes(hXP)
%EXPORT_GUI_SIZES GUI sizes and spaces for the export dialog

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/11/21 15:31:00 $

sz    = dialog_gui_sizes(hXP);
count = get(hXP, 'VariableCount');

% Set up the fig position using the # of variables
sz.fig    = [500 500 205 190+(sz.uuvs+sz.uh)*count] * sz.pixf;

if isempty(hXP.Objects),
    sz.fig(4) = sz.fig(4)-sz.vfus*4-sz.uh;
end

framewidth = sz.fig(3)-sz.hfus*2;
popupwidth = framewidth-sz.hfus*2;

sz.tframe = [sz.hfus sz.fig(4)-sz.vfus*7-sz.uh framewidth sz.vfus*4+sz.uh];
sz.tpopup = [sz.tframe(1)+sz.hfus sz.tframe(2)+sz.vfus*2 popupwidth sz.uh];

if isempty(hXP.Objects),
    sz.aframe = sz.tframe;
    sz.apopup = sz.tpopup;
else
    sz.aframe = [sz.hfus sz.tframe(2)-sz.uh-sz.vfus*7 framewidth sz.vfus*4+sz.uh];
    sz.apopup = [sz.aframe(1)+sz.hfus sz.aframe(2)+sz.vfus*2 popupwidth sz.uh];
end

frY       = sz.button(2) + sz.button(4) + sz.vfus;
frH       = sz.aframe(2)-frY - sz.vfus*3;

sz.nframe = [sz.hfus frY sz.aframe(3) frH];
sz.nlabel = [sz.hfus*2 frY+frH-sz.uh-sz.hfus sz.aframe(3)/2-sz.hfus sz.uh];
sz.nedit  = [sz.aframe(3)/2 + sz.hfus frY+frH-sz.uh-sz.hfus sz.aframe(3)/2-sz.hfus sz.uh];
sz.checkbox = [sz.nframe(1:3) + [sz.hfus sz.vfus -sz.hfus*2] sz.uh];

% [EOF]
