function sz = fsdialog_gui_sizes(hFs)
%FSDIALOG_GUI_SIZES Returns the spacing for the FsDialog

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 23:25:23 $

sz = dialog_gui_sizes(hFs);

sz.figpos = [300 300 220 110]*sz.pixf;
sz.specifier = [30 90]*sz.pixf;

% [EOF]
