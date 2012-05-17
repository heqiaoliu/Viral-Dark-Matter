function ax = conformalSetupOutputAxes(ax)
% conformalSetupOutputAxes Set up axes in the output/'z' plane.
%
% Supports conformal transformation demo, ipexconformal.m
% ("Exploring a Conformal Mapping").

% Copyright 2005-2009 The MathWorks, Inc. 
% $Revision: 1.1.6.1 $  $Date: 2009/11/09 16:24:50 $

set(ax, 'DataAspectRatio',[1 1 1],...
		'XLimMode','manual',...
        'YLimMode','manual',...
		'PlotBoxAspectRatioMode', 'manual');
set(ax,'XLim',[-2.5 2.5]);
set(ax,'YLim',[-2.5 2.5]);
set(ax,'Xlabel',text('String','Re(z)'));
set(ax,'Ylabel',text('String','Im(z)'));
set(ax,'Title',text('String','Output Plane'));
