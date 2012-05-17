function Lhandle = drawconnectarrow(PointA, PointB, AxisHandle, varargin)
% ------------------------------------------------------------------------%
% Function: drawconnectarrow
% Purpose: Draws connector line with arrow at end
% Arguments: varargin = [], draws arrow from PointA to PointB
%                     = 'xy', draws elbow line in x direction first
%                     = 'yx', draws elbow line in y direction first
% ------------------------------------------------------------------------%

%   Author(s): C. Buhr
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.10.2 $ $Date: 2006/01/26 01:48:18 $


xa = PointA(1);
ya = PointA(2);
xb = PointB(1);
yb = PointB(2);

origunits = get(AxisHandle,'units');
set(AxisHandle,'Units','pixels');
AxPos = get(AxisHandle,'Position');
set(AxisHandle,'Units',origunits);

%AxPos = get(AxisHandle, 'Position');
% ar = AxPos(3)/AxPos(4);  % Aspect Ratio

Xlims = get(AxisHandle, 'Xlim');
Ylims = get(AxisHandle, 'Ylim');
ar = (Xlims(2)-Xlims(1))/(Ylims(2)-Ylims(1))/AxPos(4)*AxPos(3);  % Aspect Ratio

AL = 0.05; %Arrow Length
AW = 0.05; %Arrow Width


arrowpx = [-AL 0 -AL -AL];
arrowpy = [ AW 0 -AW  AW]*.5;

if nargin == 3 || (xa == xb) || (ya == yb)
    atheta = atan2(yb-ya,xb-xa);
    arrownx = (arrowpx*cos(atheta)-arrowpy*sin(atheta))/ar;
    arrowny = arrowpx*sin(atheta)+arrowpy*cos(atheta);
    Lhandle = [line([xa,xb], [ya,yb],'Color','k','Parent', AxisHandle); ...
        patch(arrownx+xb, arrowny+yb, 'k', 'Parent', AxisHandle)];
else
    if varargin{1} == 'xy'
        atheta = sign(yb-ya)*pi/2;
        arrownx = (arrowpx*cos(atheta)-arrowpy*sin(atheta))/ar;
        arrowny = arrowpx*sin(atheta)+arrowpy*cos(atheta);
        Lhandle = [line([xa,xb,xb],[ya,ya,yb],'Color','k', 'Parent', AxisHandle); ...
            patch(arrownx+xb, arrowny+yb, 'k', 'Parent', AxisHandle)];
    else
        atheta = (xb<xa)*pi;
        arrownx = (arrowpx*cos(atheta)-arrowpy*sin(atheta))/ar;
        arrowny = arrowpx*sin(atheta)+arrowpy*cos(atheta);
        Lhandle = [line([xa,xa,xb],[ya,yb,yb],'Color','k', 'Parent', AxisHandle); ...
            patch(arrownx+xb, arrowny+yb, 'k', 'Parent', AxisHandle)];
    end
end