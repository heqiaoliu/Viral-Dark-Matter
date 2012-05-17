function sz = dfiltwfsdlg_gui_sizes(hObj)
%DFILTWFSDLG_GUI_SIZES GUI Sizes and spacing for the DFILTWFSDLG

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.4 $  $Date: 2004/12/26 22:21:00 $

sz = gui_sizes(hObj);

if strncmpi(get(0, 'language'), 'ja', 2)
    w = 280;
else
    w = 250;
end

sz.fig = [300 500 w 200] * sz.pixf;
if isunix, sz.fig(3) = 300 * sz.pixf; end

height = sz.uh+sz.vfus*3.5;
fwidth = sz.fig(3)-2*sz.ffs;
sz.mframe = [sz.ffs sz.fig(4)-height-sz.vffs fwidth height];
sz.popup  = [sz.mframe(1)+sz.mframe(3)/3 sz.mframe(2)+2*sz.vfus sz.mframe(3)*2/3-sz.hfus sz.uh];
sz.mlabel = [sz.mframe(1)+sz.hfus sz.popup(2)-sz.lblTweak 0 sz.uh];

height = sz.uh*4 + sz.vfus*2 + sz.uuvs;
sz.sframe = [sz.ffs sz.mframe(2)-height-sz.vffs fwidth height];
sz.fsspec = [sz.sframe(1)+sz.hfus*3 sz.sframe(2)+sz.vfus+sz.bh ...
    sz.sframe(3)-5*sz.hfus sz.sframe(4)-2*sz.vfus-sz.bh/2];
sz.button = [sz.sframe(1)+sz.hfus sz.sframe(2)+sz.vfus];

% [EOF]
