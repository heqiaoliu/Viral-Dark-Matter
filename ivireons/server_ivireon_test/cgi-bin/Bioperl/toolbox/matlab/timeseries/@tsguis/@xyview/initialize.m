function initialize(this,Axes)
%  INITIALIZE  Initializes @freqview objects.

%  Author(s):  
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.6.3 $ $Date: 2005/06/27 23:06:18 $


% Get axes in which responses are plotted
[s1,s2] = size(Axes); 
Axes = reshape(Axes,[s1*s2 1]);

% Create curves
Curves = zeros([s1 s2]);
SelectionCurves = zeros([s1 s2]);
for ct=1:s1*s2
   selectContextMenu = uicontextmenu('Parent',...
                            ancestor(Axes(ct),'figure')); 
   Curves(ct) = line('XData',NaN,'YData',NaN, ...
      'Parent',Axes(ct,1), 'Visible', 'off','Marker','x','Linestyle','None');
   SelectionCurves(ct) = line('XData', NaN, 'YData', NaN, ...
		    'Parent',  Axes(ct), 'Visible', 'off','UicontextMenu',...
            selectContextMenu,'HandleVisibility','off');
end
this.Curves = handle(Curves);
this.SelectionCurves = handle(SelectionCurves);