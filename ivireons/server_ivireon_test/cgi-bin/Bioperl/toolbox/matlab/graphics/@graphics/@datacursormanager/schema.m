function schema

% Copyright 2003-2009 The MathWorks, Inc.

% Class
pk = findpackage('graphics');
cls = schema.class(pk,'datacursormanager');

% Enumeration
if (isempty(findtype('DataCursorDisplayStyle')))
  schema.EnumType('DataCursorDisplayStyle',{'datatip','window'});
end

% Public Properties
p = schema.prop(cls,'Enable','on/off');
p.FactoryValue = 'off';

p = schema.prop(cls,'SnapToDataVertex','on/off');
p.FactoryValue = 'on';
p.SetFunction = @localSetSnapToDataVertex;

p = schema.prop(cls,'DisplayStyle','DataCursorDisplayStyle');
p.FactoryValue = 'datatip';
p.SetFunction = @localSetDisplayStyle;

p = schema.prop(cls,'UpdateFcn','MATLAB callback');
p.AccessFlags.AbortSet = 'off';

% Public Read Only
p = schema.prop(cls,'Figure','MATLAB array');
p.AccessFlags.PublicSet = 'off';

p = schema.prop(cls,'ExternalListeners','MATLAB array');
p.Visible = 'off';

% Private Properties

p = schema.prop(cls,'EnableAxesStacking','MATLAB array'); %true/false
set(p,'FactoryValue',false); 
set(p,'Visible','off');

p = schema.prop(cls,'EnableZStacking','MATLAB array'); %true/false
set(p,'FactoryValue',true);
set(p,'Visible','off');
p = schema.prop(cls,'ZStackMinimum','MATLAB array'); 
set(p,'FactoryValue',1);
p.Visible = 'off';
p = schema.prop(cls,'HiddenUpdateFcn','MATLAB array');
p.Visible = 'off';
p = schema.prop(cls,'DataCursors','handle vector'); 
p.Visible = 'off';
p = schema.prop(cls,'UIState','MATLAB array');
p.Visible = 'off';
p = schema.prop(cls,'CurrentDataCursor','handle');
p.Visible = 'off';
p = schema.prop(cls,'OriginalRenderer','string');
p.Visible = 'off';
p = schema.prop(cls,'OriginalRendererMode','string');
p.Visible = 'off';
p = schema.prop(cls,'UIContextMenu','MATLAB array');
p.Visible = 'off';
p = schema.prop(cls,'PanelHandle','handle');
p.Visible = 'off';
p = schema.prop(cls,'PanelTextHandle','handle');
p.Visible = 'off';
p = schema.prop(cls,'PanelDatatipHandle','handle');
p.Visible = 'off';
p = schema.prop(cls,'DefaultExportVarName','string');
p.Visible = 'off';
set(p,'FactoryValue','cursor_info');
p = schema.prop(cls,'DefaultPanelPosition','MATLAB array');
p.Visible = 'off';
p = schema.prop(cls,'NewDataCursorOnClick','MATLAB array'); % logical
p.Visible = 'off';
p.FactoryValue = false;

% ...for debugging
p = schema.prop(cls,'Debug','double');
p.FactoryValue = false;
p.Visible = 'off';

% Events
schema.event(cls,'UpdateDataCursor');
hEvent = schema.event(cls,'MouseMotion');
hEvent = schema.event(cls,'ButtonDown');

%-----------------------------------------------%
function [snapon] = localSetSnapToDataVertex(hThis,snapon)
% Update state of all data cursors

h = get(hThis,'DataCursors');
if strcmpi(snapon,'on')   
   set(h,'Interpolate','off');
else
   set(h,'Interpolate','on');
end

%-----------------------------------------------%
function [display_style] = localSetDisplayStyle(hThis,display_style)
% Update state of all data cursors

h = get(hThis,'DataCursors');
if strcmpi(display_style,'window')   
   set(h,'ViewStyle','marker');
   if ~isempty(h)
       set(hThis,'Enable','on');
   end
else
   set(h,'ViewStyle','datatip');
end

