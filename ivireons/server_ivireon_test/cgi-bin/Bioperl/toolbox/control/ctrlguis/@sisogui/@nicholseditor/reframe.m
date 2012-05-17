function MovePtr = reframe(Editor,PlotAxes,Mode,X,Y)
% Reframes plot to include specified data.
%
%   REFRAME adjusts the (auto) axes limits to include 
%   the specified data X,Y.  The MODE string is either
%   'x', 'y', or 'xy'.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2005/12/22 17:43:16 $
Axes = Editor.Axes;

% Phase axis
if any(Mode=='x')
   if strcmp(Axes.XUnits,'deg')
      ShiftX = Axes.slidelims(PlotAxes,'x','linear',90,X);
      if ShiftX
         PlotAxes.XtickMode = 'auto';
         PlotAxes.XTick = phaseticks(PlotAxes.XTick,PlotAxes.Xlim);
      end
   else
      ShiftX = Axes.slidelims(PlotAxes,'x','linear',pi/2,X);
   end
else
   ShiftX = 0;
end

% Mag axis
if any(Mode=='y')
   ShiftY = Axes.slidelims(PlotAxes,'y','linear',20,Y);
else
   ShiftY = 0;
end

MovePtr = ShiftX || ShiftY;
if MovePtr
   % Notify peers of limit change
   Axes.send('PostLimitChanged')
end
