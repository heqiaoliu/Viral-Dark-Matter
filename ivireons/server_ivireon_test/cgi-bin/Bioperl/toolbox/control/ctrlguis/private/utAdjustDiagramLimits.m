function [NewXLim,NewYLim] = utAdjustDiagramLimits(XLim,YLim,Ar,axW,axH)
% Helper function used to adjust axis limits of block diagram plots for
% fixed sisotool configurations.
%
% XLim = X limits for desired aspect ratio
% YLim = Y limits for desired aspect ratio
% Ar = aspect ratio of height/widtht
% axW = current axes width
% axH = current axes height
% NewXLim = X limits to fill current axes width subject to aspect ratio
% NewYLim = Y limits to fill current axes height subject to aspect ratio

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2006/01/26 01:48:19 $

ylimd = YLim(2)-YLim(1);
xlimd = XLim(2)-XLim(1);

if axH/axW > Ar;
    % width is limiting factor
    NewXLim = XLim;
    magfactor = axH/(Ar*axW);
    ylimh = (ylimd*magfactor-ylimd)/2;
    NewYLim = YLim + [-1,1]*ylimh;
    
else
    %height is limiting factor
    NewYLim = YLim;
    magfactor = axW/(axH/Ar);
    xlimw = (xlimd*magfactor-xlimd)/2;
    NewXLim = XLim + [-1,1]*xlimw;
end
