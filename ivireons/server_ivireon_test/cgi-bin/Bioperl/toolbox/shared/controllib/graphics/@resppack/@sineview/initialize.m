function initialize(this,Axes)
%INITIALIZE  Initializes @SineView graphics.

%  Author(s): Erman Korkut 13-Mar-2009
%  Revised  :
%  Copyright 1986-2009 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:25:05 $

% Create empty curves (Axes = HG axes to which curves are plotted)
[Ny,Nu] = size(Axes);
Curves = [];
for ct = Ny*Nu:-1:1
  Curves(ct,1) = line('XData', NaN, 'YData', NaN, ...
		    'Parent',  Axes(ct), 'Visible', 'off');
  SSCurves(ct,1) = line('XData', NaN, 'YData', NaN, ...
		    'Parent',  Axes(ct), 'Visible', 'off');
end
this.Curves = handle(reshape(Curves,[Ny Nu]));
this.SSCurves = handle(reshape(SSCurves,[Ny Nu]));