function updatelims(Editor,varargin)
%UPDATELIMS  Updates axes limits.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.34.4.2 $  $Date: 2005/12/22 17:43:47 $
if strcmp(Editor.EditMode,'off') || Editor.SingularLoop
   % Editor is inactive or has no data (algebraic inner loop)
   return
end

% Sample time and editor modes
Axes = Editor.Axes;
PlotAxes = getaxes(Axes);

% Always show unit circle in discrete time
% RE: included in limits on purpose!
if Editor.LoopData.Ts
   set(Editor.HG.UnitCircle,'Visible','on')
else
   set(Editor.HG.UnitCircle,'Visible','off') 
end

% Enforce limit modes in HG axes
set(PlotAxes,'XlimMode',Axes.XlimMode{1},'YlimMode',Axes.YlimMode{1})

% Acquire limits (automatically includes other objects such as constraints 
% and compensator poles and zeros)
Xlim = get(PlotAxes,'XLim');
Ylim = get(PlotAxes,'YLim');   
if strcmpi(Axes.YlimMode,'auto')
   Ylim = max(abs(Ylim)) * [-1,1];  % enforce symmetry wrt x-axis
end

% Adjust limits if equal aspect ratio is on
if strcmpi(Editor.AxisEqual,'on')
   [Xlim,Ylim] = localAxisEqual(Xlim,Ylim,PlotAxes);
end

% Apply computed limits
set(PlotAxes,'Xlim',Xlim,'Ylim',Ylim)


%-------------------- Local Functions ---------------------------------

%%%%%%%%%%%%%%%%%%
% localAxisEqual %
%%%%%%%%%%%%%%%%%%
function [Xlim,Ylim] = localAxisEqual(Xlim,Ylim,Ax)
% Update limits to show equal aspect ratio
units = get(Ax,'Units');
if ~strcmpi(units,'pixels')
   set(Ax,'Units','pixels');
   p = get(Ax,'Position');
   set(Ax,'Units',units);
else
   p = get(Ax,'Position');
end
%---Pixel extent
px = p(3);
py = p(4);
%---Data extent
dx = abs(diff(Xlim)); 
dy = abs(diff(Ylim));
%---Effective extent
xf = dx*py;
yf = dy*px;
%---Update limits
if xf>yf
   %---Effective Xlim is larger, adjust Ylim
   dd = xf/px-dy;
   Ylim = [Ylim(1)-dd/2 Ylim(2)+dd/2];
   set(Ax,'Ylim',Ylim);
elseif yf>xf
   %---Effective Ylim is larger, adjust Xlim
   dd = yf/py-dx;
   Xlim = [Xlim(1)-dd/2 Xlim(2)+dd/2];
   set(Ax,'Xlim',Xlim);
end
