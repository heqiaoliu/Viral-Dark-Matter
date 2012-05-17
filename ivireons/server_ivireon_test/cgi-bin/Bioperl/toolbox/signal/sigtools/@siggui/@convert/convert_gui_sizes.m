function sz = convert_gui_sizes(hConvert)
%CONVERT_GUI_SIZES Get the sizes and spacing for the Convert Dialog

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 23:20:14 $

sz = gui_sizes(hConvert);

sz.fig     = [600 500 205 180]*sz.pixf;

frHeight   = 116 * sz.pixf;
frWidth    = 183 * sz.pixf;
frYpos     = sz.fig(4) - sz.vffs - frHeight;
frXpos     = (sz.fig(3) - frWidth) / 2;

sz.frame   = [frXpos frYpos frWidth frHeight];

width      = 160*sz.pixf; 
xPosOffset = (sz.frame(3) - width) / 2; % Center in X 
x          = sz.frame(1) + xPosOffset;
y          = sz.frame(2) + sz.uuvs;    
height     = sz.frame(4) - sz.uuvs*2;

sz.listbox = [x y width height];

% [EOF]
