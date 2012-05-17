function sz = xp_gui_sizes(h)
%XP_GUI_SIZES SIGIO.ABSTRACTDESWVARS GUI Sizes.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/04/11 18:44:33 $

% Get the generic gui sizes
sz = gui_sizes(h);

% Default frame width and height
sz.fw = 150*sz.pixf; 
sz.fh = getfrheight(h);

% Variable Names frame position (without Overwrite checkbox)
sz.VarNamesPos = [sz.ffs sz.ffs sz.fw sz.fh];

% Export As frame position
sz.XpAsFrpos = [sz.ffs sz.ffs+(sz.vffs)+sz.fh sz.fw 4*sz.vfus+sz.uh];

% [EOF]
