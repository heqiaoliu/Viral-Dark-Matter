function h = createFigureDefaultToolbar(fig,deploy)
%CREATEFIGUREDEFAULTTOOLBAR Create default toolbar.
%
%  CREATEFIGUREDEFAULTTOOLBAR(F) creates the default figure toolbar on figure F.
%
%  If the figure handle F is not specified, 
%  CREATEFIGUREDEFAULTTOOLBAR operates on the current figure(GCF).
%
%  CREATEFIGUREDEFAULTTOOLBAR(F,true) creates the default toolbar 
%  on figure F for a deployment-only figure
%
%  If the deploy is not specified, CREATEFIGUREDEFAULTTOOLBAR operates in normal mode.
%
%  H = CREATEFIGUREDEFAULTTOOLBAR(...) returns the handle to the new figure child.

%  Copyright 2009 The MathWorks, Inc.

if nargin==1, deploy = false; end

h = uitoolbar(fig,allOptions,'Tag','FigureToolBar');

%--------------%
uitoolfactory(h,'Standard.NewFigure');
uitoolfactory(h,'Standard.FileOpen');
uitoolfactory(h,'Standard.SaveFigure');
uitoolfactory(h,'Standard.PrintFigure');
%--------------%
u = uitoolfactory(h,'Standard.EditPlot');
if deploy,
  set(u,'Visible','off');
else
  set(u,'Separator','on');
end
%--------------%
u = uitoolfactory(h,'Exploration.ZoomIn');
set(u,'Separator','on');
uitoolfactory(h,'Exploration.ZoomOut');
uitoolfactory(h,'Exploration.Pan');
uitoolfactory(h,'Exploration.Rotate');
%--------------%
uitoolfactory(h,'Exploration.DataCursor');
if deploy,
   set(u,'Separator','on');
end
u = uitoolfactory(h,'Exploration.Brushing');
if deploy,
   set(u,'Visible','off');
end
u = uitoolfactory(h,'DataManager.Linking');
if deploy,
   set(u,'Visible','off');
else
    set(u,'Separator','on');
end
%--------------%
u = uitoolfactory(h,'Annotation.InsertColorbar');
set(u,'Separator','on');
uitoolfactory(h,'Annotation.InsertLegend');
%--------------%
u = uitoolfactory(h,'Plottools.PlottoolsOff');
if deploy,
  set(u,'Visible','off');
else
  set(u,'Separator','on');
end
u = uitoolfactory(h,'Plottools.PlottoolsOn');
if deploy, set(u,'Visible','off'); end


function s = allOptions
s = struct('Serializable',  'off',...
    'HandleVisibility',   'off');

