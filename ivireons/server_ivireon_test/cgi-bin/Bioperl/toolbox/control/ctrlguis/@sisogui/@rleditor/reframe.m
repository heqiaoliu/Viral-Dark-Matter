function MovePtr = reframe(Editor,PlotAxes,Mode,X,Y)
% Reframes plot to include specified data.
%
%   REFRAME adjusts the (auto) axes limits to include 
%   the specified data X,Y.  The MODE string is either
%   'x', 'y', or 'xy'.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2005/12/22 17:43:42 $
Axes = Editor.Axes;
% X axis
if any(Mode=='x')
   StretchX = Axes.stretchlims(PlotAxes,'x',false,X);
else
   StretchX = 0;
end
   
% Y axis
if any(Mode=='y')
   StretchY = Axes.stretchlims(PlotAxes,'y',true,Y);
else
   StretchY = 0;
end

MovePtr = StretchX || StretchY;
if MovePtr
   % Notify peers of limit change
   Axes.send('PostLimitChanged')
end