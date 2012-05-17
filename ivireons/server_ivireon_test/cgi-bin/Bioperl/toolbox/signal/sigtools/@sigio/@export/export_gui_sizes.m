function sz = export_gui_sizes(this,newWidth,newHeight)
%EXPORT_GUI_SIZES GUI sizes and spaces for the export dialog

%   Author(s): P. Costa
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2007/03/13 19:50:38 $

sz = dialog_gui_sizes(this);

% Get the height of the destination specific options frame (variable
% height)
if nargin == 1
    [newWidth, newHeight] = destinationSize(this.Destination);
end

% Determine the export dialog size
xp2frHght = sz.vfus*4+sz.uh; % "Export To" frame height
figHght = sz.button(2)+sz.button(4)+sz.vfus+newHeight+sz.vffs+xp2frHght+sz.vffs;

% Give an extra 20 pixels to linux, unix, mac because of font problems.
width = newWidth+sz.hfus*2;

if ~ispc
    width = width+20*sz.pixf;
end

if strncmpi(get(0, 'language'), 'ja', 2)
    width = width+36*sz.pixf;
end

% Make sure that the buttons fit with 5 pixel spacing and 10 pixels on the
% side of each label.
minwidth = largestuiwidth({xlate('Export'), xlate('Help'), xlate('Cancel')})*3 + ...
    5*2*sz.pixf+10*2*3*sz.pixf;

width = max(width, minwidth);

sz.fig = [500*sz.pixf 500*sz.pixf width figHght];

framewidth = sz.fig(3)-sz.hfus*2;

% Export To frame and popup
xp2frYpos = sz.fig(4)-(sz.vffs+xp2frHght);
sz.xp2fr = [sz.hfus xp2frYpos framewidth xp2frHght];
popupwidth = framewidth-sz.hfus*2;
sz.xp2popup = [sz.xp2fr(1)+sz.hfus sz.xp2fr(2)+sz.vfus*2 popupwidth sz.uh];

% Destination options frame(s)
frY = sz.button(2) + sz.button(4) + sz.vfus;
sz.xpdestopts = [sz.hfus frY framewidth newHeight];

% [EOF]
