function initialize(this,Axes)
%INITIALIZE  Initialization for @StepSteadyStateView class

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:19:44 $

[s1,s2,s3] = size(Axes);  % Ny-by-Nu
Points = zeros([s1 s2]);

for ct=1:prod([s1 s2])  
   %% Plot characteristic points
   Points(ct) = line(NaN,NaN,5,...
      'Parent',Axes(ct),...
      'XlimInclude','off',...
      'YlimInclude','off',...
      'Visible','off',...
      'Marker','o',...
      'MarkerSize',6);
end

this.Points = handle(Points);
this.PointTips = cell([s1 s2]);