function h=scribeaxes(varargin)
%SCRIBEAXES creates the annotation overlay axes object
%  H=scribe.SCRIBEAXES creates an annotation scribeaxes instance
%
%  See also PLOTEDIT

%   Copyright 1984-2009 The MathWorks, Inc.

[fig,varargin,nargs] = graph2dhelper('hgcheck','figure',varargin{:});
if isempty(fig)
    fig = gcf;
end

% If there is already a scribe axes in the figure (a possible side-effect
% from an odd deserialization order), return it:
h = handle(findall(fig,'Type','axes','Tag','scribeOverlay'));
if ~isempty(h)
    return;
end

h = scribe.scribeaxes('Parent',fig,'Tag','scribeOverlay','Interruptible','off');

set(h,'Units','normalized',...
    'Position',[0,0,1,1], ...
    'Visible','off', ...
    'HandleVisibility','off', ...
    'XLimMode','manual', ...
    'YLimMode','manual', ...
    'ZLimMode','manual', ...
    'ZLim',[-1 1],...
    'NextPlot','add',...
    'Climmode','manual',...
    'Alimmode','manual',...
    'HitTest','off'); 

hasbehavior(double(h),'zoom',false);
hasbehavior(double(h),'rotate',false);
hBehavior = hggetbehavior(double(h),'Print');
set(hBehavior,'PrePrintCallback',@printCallback);
set(hBehavior,'PostPrintCallback',@printCallback);

setappdata(double(h),'ScribeGroup',h);
setappdata(double(h),'scribeobject','on');
setappdata(fig,'Scribe_ScribeOverlay',double(h));

l = handle.listener(h,h.findprop('SelectedObjects'),...
    'PropertyPostSet',@changedSelectedObjects);
h.PropertyListeners = l;

u=get(h,'units');
set(h,'units','pixels');
h.LastPos = get(h,'Position');
set(h,'units',u);

% resize listener
if ~isprop(h,'ScribeAxesResizeListeners')
  rl = schema.prop(h,'ScribeAxesResizeListeners','MATLAB array');
  rl.AccessFlags.Serialize = 'off';
  rl.Visible = 'off';
end
cls = classhandle(h);
figh = handle(fig);
alis = handle.listener(figh, 'ResizeEvent',{@changedAxesReposProps, h});
set(h,'ScribeAxesResizeListeners',alis);

% units pre and post listeners
if ~isprop(h,'ScribeAxesUnitsListeners')
  ul = schema.prop(h,'ScribeAxesUnitsListeners','MATLAB array');
  ul.AccessFlags.Serialize = 'off'; 
  ul.Visible = 'off';
end
cls = classhandle(h);
ulis.preset = handle.listener(double(h),cls.findprop('Units'),'PropertyPreSet',{@changingScribeAxesUnits});
ulis.postset = handle.listener(double(h),cls.findprop('Units'),'PropertyPostSet',{@changedScribeAxesUnits});
set(h,'ScribeAxesUnitsListeners',ulis);

% destroyed listener
if ~isprop(h,'ScribeAxesDestroyedListeners')
  dl = schema.prop(h,'ScribeAxesDestroyedListeners','MATLAB array');
  dl.AccessFlags.Serialize = 'off'; 
  dl.Visible = 'off';
end
cls = classhandle(h);
dlis = handle.listener(double(h),'ObjectBeingDestroyed', {@axesDeleted, h, fig});
set(h,'ScribeAxesDestroyedListeners',dlis);


% Shapes pre-get listener
if ~isprop(h,'ScribeAxesPreGetListeners')
  dl = schema.prop(h,'ScribeAxesPreGetListeners','MATLAB array');
  dl.AccessFlags.Serialize = 'off'; 
  dl.Visible = 'off';
end
cls = classhandle(h);
prop = findprop(h,'Shapes');
dlis = handle.listener(h,prop,'PropertyPreGet', {@shapesPreGet, h});
set(h,'ScribeAxesPreGetListeners',dlis);


% figure child added listener
if ~isprop(handle(fig),'ScribeOverlayFigListeners')
    fl = schema.prop(handle(fig),'ScribeOverlayFigListeners','MATLAB array');
    fl.AccessFlags.Serialize = 'off';
    fl.Visible = 'off';
end
flis.childadded = handle.listener(fig, 'ObjectChildAdded', {@figChildAdded, h, fig});
flis.figdeleted = handle.listener(fig,'ObjectBeingDestroyed',@figDeleted);
set(handle(fig),'ScribeOverlayFigListeners',flis);

if ~isappdata(fig,'scribegui_snaptogrid')
    setappdata(fig,'scribegui_snaptogrid','off');
end

if nargout>0
    varargout{1}=h;
end

%-------------------------------------------------------------------------%
function localRestackAxes(hProp, eventData, h, fig)

%-------------------------------------------------------------------------%
function axesDeleted(hProp,eventData,h,fig)

if ishandle(fig) && ~isequal(get(fig,'beingdeleted'),'on')
    if isappdata(fig,'Scribe_ScribeOverlay')
        rmappdata(fig,'Scribe_ScribeOverlay');
    end
    plotedit(fig,'off');
    % disable figure listeners
    if isprop(handle(fig),'ScribeOverlayFigListeners')
        figlis = get(handle(fig),'ScribeOverlayFigListeners');
        figlis.enable = 'off';
        set(handle(fig),'ScribeOverlayFigListeners',figlis);
    end
end

%-------------------------------------------------------------------------%
function figChildAdded(hProp,eventData,h,fig)

if ishandle(h)
  if isequal(h.ObserveFigChildAdded,'on') && ...
    any(strcmp(get(get(eventData,'Child'),'Type'),...
                {'axes','uipanel','uicontainer'}))  
    if ~usejava('awt')
      h.methods('stackScribeLayersWithChild',[],false);
    else
      % delay the stack so that PlotBrowser events still fire properly
      cb = handle(com.mathworks.hg.util.Callback,'callbackProperties');
      set(cb,'delayedCallback',@(obj,evd) delayedStackScribeLayers(h));
      cb.postCallback;
    end
  end
end

%-------------------------------------------------------------------------%
function delayedStackScribeLayers(h)
if ishandle(h)
    h.methods('stackScribeLayersWithChild',[],true);
end

%-------------------------------------------------------------------------%
function changingScribeAxesUnits(hProp,eventData)

ax = eventData.affectedObject;
al=get(handle(ax),'ScribeAxesResizeListeners');
al.enable='off';
set(handle(ax),'ScribeAxesResizeListeners',al);

%-------------------------------------------------------------------------%
function changedScribeAxesUnits(hProp,eventData)

ax = eventData.affectedObject;
al=get(handle(ax),'ScribeAxesResizeListeners');
al.enable='on';
set(handle(ax),'ScribeAxesResizeListeners',al);

%-------------------------------------------------------------------------%
function changedAxesReposProps(hProp,eventData,scribeax)

if ishandle(scribeax)

  % mark axis as dirty since PostSetListeners do not
  invalidateaxis(double(scribeax));
end

%------------------------------------------------------------------%
function figDeleted(hProp,eventData,h,fig)

%------------------------------------------------------------------%
function changedSelectedObjects(hProp,eventData)
h=eventData.affectedObject;
selObjs = double(h.SelectedObjects);
inspect(selObjs, '-ifopen');

%-------------------------------------------------------%
%PRINTCALLBACK Pre and Post printing callback. see graphics.printbehavior
function printCallback(hSrc, callbackName)

persistent oldstate;
h = hSrc;
fig = ancestor(h,'figure');
objs = get(h,'children');
ok = false(1,length(objs));
for k=1:length(objs)
  ok(k) = isprop(objs(k),'Srect');
end
objs = objs(ok);
if ~isempty(objs) 
  if strcmp(callbackName,'PrePrintCallback')
    oldstate = {};
    for k=1:length(objs)
      oldstate = {oldstate{:}, get(get(objs(k),'Srect'),'Visible')};
      set(get(objs(k),'Srect'),'Visible','off');
      % Deal with pins:
      hPins = get(objs(k),'Pin');
      hPins = hPins(ishandle(hPins));
      if ~isempty(hPins)
          pinVis = get(hPins,'Visible');
          if ~iscell(pinVis)
              pinVis = {pinVis}; %#ok<AGROW>
          end
          oldstate = [oldstate, pinVis']; %#ok<AGROW>
          set(hPins,'Visible','off');
          pinEnable = get(hPins,'Enable');
          if ~iscell(pinEnable)
              pinEnable = {pinEnable}; %#ok<AGROW>
          end
          oldstate = [oldstate, pinEnable']; %#ok<AGROW>
          set(hPins,'Enable','off');
      end
    end
  else
      counter = 1;
    for k=1:length(objs)
      set(get(objs(k),'Srect'),{'Visible'},oldstate{counter});
      counter = counter+1;
      % Deal with pins:
      hPins = get(objs(k),'Pin');
      hPins = hPins(ishandle(hPins));
      if ~isempty(hPins)
          set(hPins,repmat({'Visible'},numel(hPins),1),oldstate(counter:counter+numel(hPins)-1));
          counter = counter+numel(hPins);
          set(hPins,repmat({'Enable'},numel(hPins),1),oldstate(counter:counter+numel(hPins)-1));
          counter = counter+numel(hPins);
      end
    end
  end
end

%--------------------------------------------------------------------%
function shapesPreGet(hSrc,eventData,h)
shapes = h.Shapes;
if ~isempty(shapes)
  shapes = shapes(ishandle(shapes));
  h.Shapes = shapes;
end

