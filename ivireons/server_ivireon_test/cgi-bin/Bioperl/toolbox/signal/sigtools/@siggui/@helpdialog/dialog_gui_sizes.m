function sz = dialog_gui_sizes(this)
%DIALOG_GUI_SIZES GUI Sizes and Spaces for the Help Dialog

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.3.4.3 $  $Date: 2009/01/05 18:00:52 $

% In R13 replace with:
% super::gui_sizes(this);

sz = gui_sizes(this);

sz.minwidth  = 240*sz.pixf;
sz.minheight = 50 *sz.pixf;
sz.button    = [0 2*sz.vfus 0 sz.bh]; 

if isrendered(this) && ishghandle(this.FigureHandle),
    y = sz.button(2)+sz.button(4)+sz.vfus;
    figpos = figuresize(this);
    sz.controls = [sz.hfus y figpos(1)-2*sz.hfus figpos(2)-y-sz.vfus];
else
    sz.controls = [];
end

% [EOF]
