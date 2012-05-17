function [iopen,iclose] = iconsTogglePanel(bg,fg)
% Create a pair of arrow icons for toggle panels.
%
% Returns RGB arrays for each icon, based on interpolation between the
% specified foreground (fg) and background (bg) colors.  Each color must be
% specified as a 3-element vector of RGB values in the range [0,1].

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $   $Date: 2010/03/31 18:39:18 $ 

if nargin<2
    fg = [1 1 1]; % white
end
if nargin<1
    bg = [0 0 0]; % black
end

x = [4 4 4 4 4 4 4;
    2 4 4 4 4 4 2;
    0 4 4 4 4 4 0;
    0 2 4 4 4 2 0;
    0 0 4 4 4 0 0;
    0 0 2 4 2 0 0;
    0 0 0 4 0 0 0 ] / 4;
iopen = ...
    dialogmgr.createIconFromColorFraction(x,bg,fg);

% Roller shade closed icon
x = [4 2 0 0 0 0 0;
    4 4 4 2 0 0 0;
    4 4 4 4 4 2 0;
    4 4 4 4 4 4 4;
    4 4 4 4 4 2 0;
    4 4 4 2 0 0 0;
    4 2 0 0 0 0 0 ] / 4;
iclose = ...
    dialogmgr.createIconFromColorFraction(x,bg,fg);

