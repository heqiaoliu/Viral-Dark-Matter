function Shift = slidelims(this,CurrentAxes,xy,Scale,Step,Data)
% Translates axis limits during move or resize operations.
%
%   SLIDELIMS translates the axes limits if the point(s) DATA 
%   fall outside the current axes limits.  If SCALE='linear',
%   the limits are translated by STEP to the left or right.
%   if SCALE='log', the limits are translated by log(STEP) 
%   in log scale.

%   Author(s): P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:15:43 $

% Localize working axes in axes group
PlotAxes = getaxes(this,'2d');
[ir,ic] = find(reshape(CurrentAxes==PlotAxes,size(PlotAxes)));

% Check if data is out of range
DataMin = min(Data);  
DataMax = max(Data);
if strcmp(xy,'x')
   AutoLims = strcmp(this.XLimMode{ic},'auto');
   Lims = get(CurrentAxes,'XLim');
else
   AutoLims = strcmp(this.YLimMode{ir},'auto');
   Lims = get(CurrentAxes,'YLim');
end
if AutoLims && DataMin<Lims(1)
   Shift = -1;
elseif AutoLims && DataMax>Lims(2)
   Shift = 1;
else
   Shift = 0;
end

% Adjust limits if necessary
if Shift~=0
   if strcmp(Scale,'linear')
      Range = Lims(2)-Lims(1);
      % Enforce min and max displacements
      Step = max(0.25*Range,min(Step,0.75*Range));
      Lims = Lims + Shift * Step;
      % Make sure limits include all data (cf design constraints)
      gap = 0.05*Range;
      Lims(1) = min(Lims(1),DataMin-gap);
      Lims(2) = max(Lims(2),DataMax+gap);
   else
      if Lims(1)>0
         Range = Lims(2)/Lims(1);
         Step = max(Range^0.25,min(Step,Range^0.75));
      else
         Range = 10;
      end
      Lims = Lims * Step^Shift;
      % Make sure limits include all data
      gap = Range^0.05;
      Lims(1) = min(Lims(1),DataMin/gap);
      Lims(2) = max(Lims(2),DataMax*gap);
   end
   % Protected set (no listener triggered nor XlimMode update)
   if strcmp(xy,'x')
      this.setxlim(Lims,ic,'basic')
   else
      this.setylim(Lims,ir,'basic')
   end
end
