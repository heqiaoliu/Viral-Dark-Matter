function resizeXRangeIndicators(ntx)
% Adjust the x-position of the Under indicator
% Nothing else is needed here

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $     $Date: 2010/03/31 18:21:48 $

hUnder = ntx.hXRangeIndicators(1);

% Get x-extend from main axes position
haxPosPix = get(ntx.hHistAxis,'pos');
x2_ax = haxPosPix(1)+haxPosPix(3)-1; % last x-pixel in main axis
Nx=40; Ny=30;
hUnderAx = get(hUnder,'parent');
set(hUnderAx,'pos',[x2_ax-Nx+1 2 Nx Ny]);
