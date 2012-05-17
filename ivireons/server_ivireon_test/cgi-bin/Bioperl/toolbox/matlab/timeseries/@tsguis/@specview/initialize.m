function initialize(this,Axes)
%  INITIALIZE  Initializes @freqview objects.

%  Author(s):  
%  Copyright 1986-2006 The MathWorks, Inc.
%  $Revision: 1.1.6.6 $ $Date: 2006/06/27 23:11:16 $


% Get axes in which responses are plotted
[s1,s2] = size(Axes); 

% Create curves
Curves = zeros([s1 s2]);
Watermarks = [];
for ct=1:s1*s2
   Curves(ct) = line('XData', NaN, 'YData', NaN, ...
      'Parent', Axes(ct,1), 'Visible', 'off');
   SelectionPatch(ct,1) = patch([NaN;NaN;NaN;NaN],[NaN;NaN;NaN;NaN],...
      [1 1 0.7],'Parent',Axes(ct),'Uicontextmenu',uicontextmenu('Parent',...
      ancestor(Axes(ct),'Figure')),'HandleVisibility','off');
   Watermarks(ct,1) = line('XData', NaN, 'YData', NaN, ...
            'Parent',Axes(ct),'Visible','off','Linewidth',3,...
            'Color',[.9 .9 .9],'HandleVisibility','off');
end
this.Curves = handle(reshape(Curves,[s1 s2]));
this.WatermarkCurves = handle(reshape(Watermarks,[s1 s2]));
this.SelectionPatch = handle(reshape(SelectionPatch,[s1 s2]));
