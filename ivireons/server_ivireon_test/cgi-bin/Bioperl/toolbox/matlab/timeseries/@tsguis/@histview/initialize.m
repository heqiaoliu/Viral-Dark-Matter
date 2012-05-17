function initialize(this,Axes)
%  INITIALIZE  Initializes @freqview objects.

%  Author(s):  
%  Copyright 1986-2006 The MathWorks, Inc.
%  $Revision: 1.1.6.6 $ $Date: 2006/06/27 23:10:33 $


% Get axes in which responses are plotted

[Ny,Nu] = size(Axes);
Curves = [];
Watermarks = [];
for ct = Ny*Nu:-1:1
  Curves(ct,1) = line('XData', NaN, 'YData', NaN, ...
		    'Parent',Axes(ct),'Visible','off');
  SelectionPatch(ct,1) = patch([NaN;NaN;NaN;NaN],[NaN;NaN;NaN;NaN],...
      [1 1 0.7],'Parent',Axes(ct),'Uicontextmenu',uicontextmenu('Parent',...
      ancestor(Axes(ct),'figure')),'HandleVisibility','off');
  Watermarks(ct,1) = line('XData', NaN, 'YData', NaN, ...
            'Parent',Axes(ct),'Visible','off','Linewidth',3,...
            'Color',[.9 .9 .9],'HandleVisibility','off');
end
this.Curves = handle(reshape(Curves,[Ny Nu]));
this.WatermarkCurves = handle(reshape(Watermarks,[Ny Nu]));
this.SelectionPatch = handle(reshape(SelectionPatch,[Ny Nu]));