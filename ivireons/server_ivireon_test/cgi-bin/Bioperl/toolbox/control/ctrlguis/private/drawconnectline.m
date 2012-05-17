function Lhandle = drawconnectline(PointA, PointB, AxisHandle, varargin)
% ------------------------------------------------------------------------%
% Function: drawConnectLine
% Purpose: Draws connector line with arrow at end
% Arguments: varargin = [], draws arrow from PointA to PointB
%                     = 'xy', draws elbow line in x direction first
%                     = 'yx', draws elbow line in y direction first
% ------------------------------------------------------------------------%

%   Author(s): C. Buhr
%   Copyright 1986-2004 The MathWorks, Inc. 
%   $Revision: 1.1.10.1 $ $Date: 2005/11/15 00:54:42 $


xa = PointA(1);
ya = PointA(2);
xb = PointB(1);
yb = PointB(2);

if nargin == 3 || (xa == xb) || (ya == yb)
    Lhandle = line([xa,xb], [ya,yb],'color', 'k','Parent', AxisHandle);
else
    if varargin{1} == 'xy'
        Lhandle = [line([xa,xb,xb],[ya,ya,yb],'Color','k','Parent', AxisHandle)];
    else
        Lhandle = [line([xa,xa,xb],[ya,yb,yb],'Color','k','Parent', AxisHandle)];
    end
end
