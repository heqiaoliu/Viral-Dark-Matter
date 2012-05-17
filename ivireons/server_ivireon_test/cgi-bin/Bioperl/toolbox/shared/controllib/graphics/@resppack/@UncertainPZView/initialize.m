function initialize(this,Axes)
%INITIALIZE  Initialization for @UncertainPZView class

%  Author(s): Craig Buhr
%  Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/05/10 17:37:31 $

% Create empty curves
[Ny,Nu] = size(Axes);

% Create empty curves
UncertainPoleCurves = zeros(Ny*Nu,1); 
UncertainZeroCurves = zeros(Ny*Nu,1);
for ct = 1:Ny*Nu
   UncertainPoleCurves(ct,1) = line('XData', [], 'YData', [], ...
      'Parent',  Axes(ct), 'Visible', 'off','Tag','PZ_Pole',...
      'Marker','x','MarkerSize',7,'LineStyle','none');
   UncertainZeroCurves(ct,1) = line('XData', [], 'YData', [], ...
      'Parent',  Axes(ct), 'Visible', 'off','Tag','PZ_Zero',...
      'Marker','o','LineStyle','none');
end
this.UncertainPoleCurves = reshape(handle(UncertainPoleCurves),[Ny Nu]);
this.UncertainZeroCurves = reshape(handle(UncertainZeroCurves),[Ny Nu]);
