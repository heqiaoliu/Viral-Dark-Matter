function generic_listeners(this)
% Installs generic listeners for @viewer class.

%  Author(s): Kamesh Subbarao
%  Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.5.4.1 $  $Date: 2008/12/29 01:47:20 $

% Preferences
CLS = this.Preferences;
GenProps = [CLS.findprop('Grid');...
      CLS.findprop('TitleFontSize');...
      CLS.findprop('TitleFontWeight');...
      CLS.findprop('TitleFontAngle');...
      CLS.findprop('XYLabelsFontSize');...
      CLS.findprop('XYLabelsFontWeight');...
      CLS.findprop('XYLabelsFontAngle');...
      CLS.findprop('AxesFontSize');...
      CLS.findprop('AxesFontWeight');...
      CLS.findprop('AxesFontAngle');...
      CLS.findprop('IOLabelsFontSize');...
      CLS.findprop('IOLabelsFontWeight');...
      CLS.findprop('IOLabelsFontAngle');...
      CLS.findprop('AxesForegroundColor')];
L1 = handle.listener(CLS, GenProps, 'PropertyPostSet', {@LocalGenPrefsApply this});

% Configuration
% RE: Only refresh layout when figure becomes visible
%     (each plot already has a listener to redraw its contents)

L2 = handle.listener(this,'ConfigurationChanged',@layout);
set(L2, 'CallbackTarget', this);

L3 = addlistener(this.Figure,'Visible','PostSet',@(es,ed) layout(this));

% PreSet listener for Views
L4 = handle.listener(this,this.findprop('Views'),'PropertyPreSet',{@LocalSetViews this});

% Store Listeners
this.Listeners.deleteListeners;
this.Listeners.addListeners(L1);
this.Listeners.addListeners(L2);
this.Listeners.addListeners(L3);
this.Listeners.addListeners(L4);



%%%%%%%%%%%%%%%%%%%%%
% LOCALGENPREFSAPPLY%
%%%%%%%%%%%%%%%%%%%%%
function LocalGenPrefsApply(eventsrc,eventdata,this)
%
AllViews = cat(1,this.PlotCells{:});
for v = find(AllViews,'-isa','wrfc.plot')'
   switch eventsrc.Name
   case 'Grid'
      v.AxesGrid.Grid  = eventdata.NewValue;
   case 'TitleFontSize'
      v.AxesGrid.TitleStyle.FontSize  = eventdata.NewValue;
   case 'TitleFontWeight'
      v.AxesGrid.TitleStyle.FontWeight = eventdata.NewValue;
   case 'TitleFontAngle'
      v.AxesGrid.TitleStyle.FontAngle  = eventdata.NewValue;
   case 'XYLabelsFontSize'
      v.AxesGrid.XLabelStyle.FontSize  = eventdata.NewValue;
      v.AxesGrid.YLabelStyle.FontSize  = eventdata.NewValue;
   case 'XYLabelsFontWeight'
      v.AxesGrid.XLabelStyle.FontWeight  = eventdata.NewValue;
      v.AxesGrid.YLabelStyle.FontWeight  = eventdata.NewValue;
   case 'XYLabelsFontAngle'
      v.AxesGrid.XLabelStyle.FontAngle  = eventdata.NewValue;
      v.AxesGrid.YLabelStyle.FontAngle  = eventdata.NewValue;
   case 'AxesFontSize'
      v.AxesGrid.AxesStyle.FontSize  = eventdata.NewValue;
   case 'AxesFontWeight'
      v.AxesGrid.AxesStyle.FontWeight  = eventdata.NewValue;
   case 'AxesFontAngle'
      v.AxesGrid.AxesStyle.FontAngle  = eventdata.NewValue;
   case 'IOLabelsFontSize'
      v.AxesGrid.ColumnLabelStyle.FontSize  = eventdata.NewValue;
      v.AxesGrid.RowLabelStyle.FontSize     = eventdata.NewValue;
   case 'IOLabelsFontWeight'
      v.AxesGrid.ColumnLabelStyle.FontWeight  = eventdata.NewValue;
      v.AxesGrid.RowLabelStyle.FontWeight     = eventdata.NewValue;
   case 'IOLabelsFontAngle'
      v.AxesGrid.ColumnLabelStyle.FontAngle  = eventdata.NewValue;
      v.AxesGrid.RowLabelStyle.FontAngle     = eventdata.NewValue;
   case 'AxesForegroundColor'
      v.AxesGrid.AxesStyle.XColor  = eventdata.NewValue;
      v.AxesGrid.AxesStyle.YColor  = eventdata.NewValue;
   end
end


%%%%%%%%%%%%%%%%%
% LocalSetViews %
%%%%%%%%%%%%%%%%%
function LocalSetViews(eventsrc,eventdata,this)
% Updates PlotCells property (view stacks for each plot area)
OldViews = this.Views;
NewViews = eventdata.NewValue;
PlotCells = this.PlotCells;

% Views that carry over bring their view stack with them.
% RE: Ensures that hiding a particular view does not affect the other views
[SharedViews,ia,ib] = intersect(OldViews,NewViews);
SharedCells = PlotCells(ia);
PlotCells(ia) = {handle(zeros(0,1))};
PlotCells(ib) = SharedCells;

% Hide views that don't carry over
OldViews(ia) = [];
set(OldViews(ishandle(OldViews)),'Visible','off')

% Update view stack for each plot cell
for ct=1:length(PlotCells)
   % Clear cell's view stack if it does not contain the specified new view
   if ~ishandle(NewViews(ct))  % plot type = none
      PlotCells{ct} = handle(zeros(0,1));
   elseif ~any(PlotCells{ct}==NewViews(ct))
      PlotCells{ct} = NewViews(ct);
   end
   % Remove any other new view from cell's view stack (a view cannot appear
   % in multiple stacks)
   [junk,ia] = intersect(PlotCells{ct},[NewViews(1:ct-1);NewViews(ct+1:end)]);
   PlotCells{ct}(ia,:) = [];
end
this.PlotCells = PlotCells;