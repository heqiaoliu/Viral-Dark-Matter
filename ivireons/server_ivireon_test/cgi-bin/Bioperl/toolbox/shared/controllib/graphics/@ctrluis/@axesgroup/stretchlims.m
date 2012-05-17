function Stretch = strechlims(this,CurrentAxes,xy,SymFlag,Data)
% Streches axis limits during move or resize operations.
%
%   STRETCHLIMS expands the axes limits if the point(s) DATA 
%   fall outside the current axes limits.  If SymFlag=true,
%   the limits are stretched by the same amount in both 
%   directions.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:15:44 $

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
if AutoLims && DataMin<=Lims(1)
   Stretch = -1;
elseif AutoLims && DataMax>=Lims(2)
   Stretch = 1;
else
   Stretch = 0;
end

% Adjust limits if necessary
if Stretch~=0
   HalfRange = (Lims(2)-Lims(1))/2;
   if SymFlag
      Lims = Lims + [-HalfRange,HalfRange];
   elseif Stretch<0
      Lims(1) = Lims(1)-HalfRange;
   else
      Lims(2) = Lims(2)+HalfRange;
   end
   % Protected set (no listener triggered nor XlimMode update)
   if strcmp(xy,'x')
      this.setxlim(Lims,ic,'basic')
   else
      this.setylim(Lims,ir,'basic')
   end
end
