function MovePtr = reframe(Editor,PlotAxes,Mode,X,Y)
% Reframes plot to include specified data.
%
%   REFRAME adjusts the (auto) axes limits to include 
%   the specified data X,Y.  The MODE string is either
%   'x', 'y', or 'xy'.


%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2005/12/22 17:42:21 $
Axes = Editor.Axes;

% Frequency axis
if any(Mode=='x')
   if strcmp(Axes.XScale,'log')
      ShiftX = Axes.slidelims(PlotAxes,'x','log',10,X);
   else
      ShiftX = Axes.slidelims(PlotAxes,'x','log',2,X);
   end
else
   ShiftX = 0;
end
   
% Mag or phase axes
if any(Mode=='y')
   hgaxes = getaxes(Axes,'2d');
   if PlotAxes==hgaxes(1)
      % Working in mag axes
      if strcmp(Axes.YUnits{1},'dB')
         ShiftY = Axes.slidelims(PlotAxes,'y','linear',20,Y);
      else
         ShiftY = Axes.slidelims(PlotAxes,'y','log',2,Y);
      end
   else
      % Working in phase axes
      if strcmp(Axes.YUnits{2},'deg')
         ShiftY = Axes.slidelims(PlotAxes,'y','linear',90,Y);
         if ShiftY
            PlotAxes.YtickMode = 'auto';
            PlotAxes.YTick = phaseticks(PlotAxes.YTick,PlotAxes.Ylim);
         end
      else
         ShiftY = Axes.slidelims(PlotAxes,'y','linear',pi/2,Y);
      end
   end
else
   ShiftY = 0;
end

MovePtr = ShiftX || ShiftY;
if MovePtr
   % Notify peers of limit change
   Axes.send('PostLimitChanged')
end
