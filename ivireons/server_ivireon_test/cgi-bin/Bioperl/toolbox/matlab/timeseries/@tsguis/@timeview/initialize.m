function initialize(this,Axes)
%INITIALIZE  Initializes @timeview graphics.

%  Author(s): James Owen
%  Copyright 2004-2005 The MathWorks, Inc.
%  $Revision: 1.1.6.6 $ $Date: 2005/11/27 22:43:41 $

% Create empty curves (Axes = HG axes to which curves are plotted)
% Overloaded to add SelectionCurves. Add in the correct stacking order.
[Ny,Nu] = size(Axes);
Curves = [];
Watermarks = [];
for ct = Ny*Nu:-1:1
  Watermarks(ct,1) = line('XData', NaN, 'YData', NaN, ...
            'Parent',Axes(ct),'Visible','off','Linewidth',3,...
            'Color',[.9 .9 .9],'HandleVisibility','off');

 
end
for ct = Ny*Nu:-1:1 
  SelectionPatch(ct,1) = patch([NaN;NaN;NaN;NaN],[NaN;NaN;NaN;NaN],...
      [1 1 0.7],'Parent',Axes(ct),'Uicontextmenu',uicontextmenu(...
      'Parent',ancestor(Axes(ct),'figure')),'HandleVisibility','off');
end
for ct = Ny*Nu:-1:1
  Curves(ct,1) = line('XData', NaN, 'YData', NaN, ...
		    'Parent',Axes(ct),'Visible','off','uiContextMenu',...
            get(ancestor(Axes(ct),'axes'),'uicontextMenu'));
end

for ct = Ny*Nu:-1:1
  % Set the callback to write the current position to the uicontext userdata
  % so that line context menus have data on the context menu position
  selectContextMenu = uicontextmenu('Callback', ...
      @(es,ed) set(es,'Userdata',get(ancestor(Axes(ct),'axes'),'CurrentPoint')),'Parent',...
      ancestor(Axes(ct),'figure'));
  SelectionCurves(ct,1) = line('XData', NaN, 'YData', NaN, ...
		    'Parent',Axes(ct), 'Visible', 'off','Uicontextmenu',...
            selectContextMenu,'HandleVisibility','off','Color',[1 0 0],'Linewidth',2);   
end

this.Curves = handle(reshape(Curves,[Ny Nu]));
this.WatermarkCurves = handle(reshape(Watermarks,[Ny Nu]));
this.SelectionCurves = handle(reshape(SelectionCurves,[Ny Nu]));
this.SelectionPatch = handle(reshape(SelectionPatch,[Ny Nu]));