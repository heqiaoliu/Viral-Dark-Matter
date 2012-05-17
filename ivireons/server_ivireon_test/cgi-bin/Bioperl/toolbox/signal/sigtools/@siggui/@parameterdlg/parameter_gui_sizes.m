function sz = parameter_gui_sizes(this)
%PARAMETER_GUI_SIZES GUI sizes and spaces for the export dialog

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $  $Date: 2004/04/13 00:24:48 $

sz    = dialog_gui_sizes(this);
count = length(this.Parameters);

sz.makedefault = largestuiwidth({'Save as Default'})+16*sz.pixf;
sz.restore     = largestuiwidth({'Restore Original Defaults'})+16*sz.pixf;

% Set up the fig position using the # of parameters
sz.fig    = [300 500 sz.hfus*4+sz.uuhs+sz.makedefault+sz.restore ...
    85+(sz.uuvs+sz.uh)*count/sz.pixf] * sz.pixf;
% if isunix, sz.fig(3) = sz.fig(3)+30*sz.pixf; end

frY       = sz.button(2) + sz.button(4) + sz.vfus;
sz.frame  = [sz.hfus frY sz.fig(3)-2*sz.hfus sz.fig(4)-frY - 2*sz.vfus];

% [EOF]
