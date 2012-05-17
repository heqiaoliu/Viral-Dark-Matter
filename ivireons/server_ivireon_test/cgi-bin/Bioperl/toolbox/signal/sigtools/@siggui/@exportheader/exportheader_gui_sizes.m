function sz = exportheader_gui_sizes(hEH)
%EXPORTHEADER_GUI_SIZES GUI sizes for the export header dialog

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2004/12/26 22:21:16 $

sz = dialog_gui_sizes(hEH);

sz.datatype      = [10 (sz.button(2)+sz.button(4)+sz.vfus*2)/sz.pixf 418 112]*sz.pixf;
sz.variableframe = [10 (sz.datatype(2)+sz.datatype(4)+sz.vfus*2)/sz.pixf 418 121]*sz.pixf;

sz.fig = [[400 400 438]* sz.pixf sz.variableframe(2)+sz.variableframe(4)+sz.vfus];

% [EOF]
