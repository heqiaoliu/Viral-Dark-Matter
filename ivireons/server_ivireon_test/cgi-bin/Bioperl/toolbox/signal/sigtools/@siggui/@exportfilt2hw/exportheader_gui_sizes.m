function sz = exportheader_gui_sizes(hEH)
%EXPORTHEADER_GUI_SIZES GUI sizes and spacing for the export2hardware dialog

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2004/12/26 22:21:12 $

sz = dialog_gui_sizes(hEH);

x = 10*sz.pixf;

sz.datatype      = [x sz.button(2)+sz.button(4)+sz.vfus*2 [293 125]*sz.pixf];
sz.variableframe = [x sz.datatype(2)+sz.datatype(4) + sz.vffs/2 [458 130]*sz.pixf];

sz.exportmode    = [sz.variableframe(1) ...
        sz.variableframe(2) + sz.variableframe(4)+sz.vffs/2 ...
        sz.variableframe(3) ...
        47*sz.pixf];

sz.fig = [[400 400]* sz.pixf ...
        sz.variableframe(1) + sz.variableframe(3) + x ...
        sz.exportmode(2)+sz.exportmode(4)+sz.vffs/2];

sz.targetselect  = [sz.datatype(1)+sz.datatype(3)+sz.ffs ...
        sz.datatype(2) ...
        sz.fig(3) - (sz.datatype(1)+sz.datatype(3)+sz.ffs+x) ...
        sz.datatype(4)];

% [EOF]
