function Views = addViews(this,plottypes)
%ADDVIEW   Adds one or several views to @viewer instance.
%
%   ADDVIEW(VIEWER,PLOTTYPE) adds a view of type PLOTTYPE 
%   (a string).
%
%   ADDVIEW(VIEWER,{PLOT1,PLOT2,...}) adds views of types  
%   PLOT1, PLOT2, ...

%   Author(s): Kamesh Subbarao 
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2007/12/14 14:29:18 $

if ischar(plottypes)
   plottypes = {plottypes};
end

% Create the Views
AvailablePlotTypes = {this.AvailableViews.Alias};
Nplots = length(plottypes);
Views = handle(-ones(Nplots,1)); % REVISIT
for ctV = 1:Nplots
   indp  = find(strcmpi(plottypes{ctV},AvailablePlotTypes));
   if length(indp)~=1
       ctrlMsgUtils.error('Control:viewer:addview1',plottypes{ctV})
   end
   Views(ctV,1) = feval(this.AvailableViews(indp).CreateFcn{:});
end
