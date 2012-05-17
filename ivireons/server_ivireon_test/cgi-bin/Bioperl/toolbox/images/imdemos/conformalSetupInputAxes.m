function ax = conformalSetupInputAxes(ax)
% conformatlSetupInputAxes Set up axes in the input/'w' plane.
%
% Supports conformal transformation demo, ipexconformal.m
% ("Exploring a Conformal Mapping").

% Copyright 2005-2009 The MathWorks, Inc. 
% $Revision: 1.1.6.1 $  $Date: 2009/11/09 16:24:49 $

set(ax, 'DataAspectRatio',[1 1 1],...
		'XLimMode','manual',...
        'YLimMode','manual',...
		'PlotBoxAspectRatioMode', 'manual');
set(ax,'XLim',[-1.5 1.5]);
set(ax,'YLim',[-1.0 1.0]);
set(ax,'Xlabel',text('String','Re(w)'));
set(ax,'Ylabel',text('String','Im(w)'));
set(ax,'Title',text('String','Input Plane'));
