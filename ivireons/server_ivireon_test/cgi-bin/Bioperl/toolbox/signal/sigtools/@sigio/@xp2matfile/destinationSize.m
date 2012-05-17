function [width height] = destinationSize(this)
%DESTINATIONSIZE 

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/03/13 19:50:44 $

sz = xp_gui_sizes(this);
optFrHght = getfrheight(this);

height = optFrHght;
if isprop(this, 'ExportAs') && isdynpropenab(this,'ExportAs'),
    height = optFrHght+sz.vffs+sz.XpAsFrpos(4);
end

% Width is the width of the labels + 100 pixels for the edit boxes, plus 40
% pixels for the spacing.
width = largestuiwidth([this.DefaultLabels(:)' this.VariableLabels(:)']) + ...
    100*sz.pixf +40*sz.pixf;

% [EOF]
