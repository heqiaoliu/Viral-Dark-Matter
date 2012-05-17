function retval = datacursormode(varargin)
%DATACURSORMODE Interactively create data cursors on plot
%   DATACURSORMODE ON turns on cursor mode.
%   DATACURSORMODE OFF turns off cursor mode
%   DATACURSORMODE by itself toggles the state.
%   DATACURSORMODE(FIG,...) works on specified figure handle.
%
%   H = DATACURSORMODE(FIG)
%        Returns the figure's data cursor mode object for 
%        customization. The following properties can be 
%        modified using set/get:
%
%        Figure <handle>
%        Specifies associated figure handle. This property
%        supports GET only.
%
%        Enable  'on'|'off'
%        Specifies whether this figure mode is currently 
%        enabled on the figure.
%  
%        SnapToDataVertex 'on'|'off'
%        Specified whether data cursors snap to nearest data
%        value or appear at mouse position.
%
%        DisplayStyle 'datatip' | 'window'
%        'datatip' displays cursor information as a text box 
%        and marker and 'window' displays cursor information 
%        in a floating window within the figure.
%
%        UpdateFcn <function_handle>
%        Set this callback to customize the text that appears 
%        in the data cursor. The input function handle should
%        reference a function with two implicit arguments (similar
%        to handle callbacks):
%        
%             function [output_txt] = myfunction(obj,event_obj)
%             % OBJ        handle to object generating the 
%             %            callback (empty in this release).
%             % EVENT_OBJ  handle to event object
%             % OUTPUT_TXT data cursor text string (string or
%             %            cell array of strings).
%         
%             The event object has the following read only 
%             properties:
%             Target    The handle of the object the data cursor
%                       is referencing.
%             Position  An array specifying x,y,(z) location of 
%                       cursor.
%
%   INFO = getCursorInfo(H)
%       Calling the function GETCURSORINFO on the data cursor
%       mode object, H, will return a vector structures (one for 
%       each data cursor). Each structure contains the fields:
%             Target    The handle of the object the data cursor
%                       is referencing (i.e. the object that was
%                       clicked on).
%             Position  An array specifying x,y,(z) location of
%                       cursor.
%
%   EXAMPLE 1:
%
%   surf(peaks);
%   datacursormode on
%   % mouse click on plot
%
%
%   EXAMPLE 2:
%
%   surf(peaks);
%   h = datacursormode;
%   set(h,'DisplayStyle','datatip','SnapToData','off');
%   % mouse click on plot
%   s = getCursorInfo(h);
%
%   EXAMPLE 3: (copy into a file)
%       
%   function demo
%   % Customize datatip string to display 'Amplitude' and
%   % 'Time'. 
%   fig = figure;
%   plot(rand(1,10));
%   h = datacursormode(fig);
%   set(h,'UpdateFcn',@myupdatefcn,'SnapToDataVertex','on');
%   datacursormode on
%   % mouse click on plot
%
%   function [txt] = myupdatefcn(obj,event_obj)
%   % Display 'Time' and 'Amplitude'
%   pos = get(event_obj,'Position');
%   txt = {['Time: ',num2str(pos(1))],['Amplitude: ',num2str(pos(2))]};
%
%   See also GINPUT.

%   Copyright 2003-2010 The MathWorks, Inc.

% UNDOCUMENTED FUNCTIONALITY
% The following features may change in a future release. 
%
% DATACURSORMODE(fig,'enableandcreate')
%    Turns on mode and fires button down function as if user clicked
%    at current mouse location. 
%
%
% The following object events are thrown by the data cursor 
% mode object:
%   'MouseMotion' Fires when mode is enabled and mouse is moving.
%   'ButtonDown'  Fires when mode is enabled and mouse is pressed.

if feature('HGUsingMATLABClasses')
    if nargout == 0
        datacursormodeHGUsingMATLABClasses(varargin{:});
    else
        retval = datacursormodeHGUsingMATLABClasses(varargin{:});
    end
    return;
end

action = []; % 'toggle' | 'on' | 'off'

fig = [];
if nargin==0
  fig = gcf;
  action = 'toggle';

elseif nargin==1
  arg1 = varargin{1};
  if ischar(arg1)
     action = arg1;
     fig = gcf;
  elseif isa(handle(arg1),'hg.figure')
     fig = arg1;
     if nargout==1
         action = 'retval';
     else
         action = 'toggle';
     end
  end
 
elseif nargin==2
  fig = varargin{1};
  action = varargin{2};
end

fig = handle(fig);

if isempty(fig) || ~ishghandle(fig,'figure')
  error('MATLAB:datacursormode:InvalidFigureHandle', 'Invalid figure handle')
end

% Get the data cursor tool object
hMode = localGetMode(fig);
hTool = localGetObj(hMode);

% Take appropriate action
switch(action)
    case 'on'
        activateuimode(fig,'Exploration.Datacursor');
    case 'off'
        if isactiveuimode(fig,'Exploration.Datacursor')
            activateuimode(fig,'');
        end
    case 'toggle'
        curr = get(hMode,'Enable');
        if strcmp(curr,'on') && isactiveuimode(fig,'Exploration.Datacursor')
            activateuimode(fig,'');
        else
           activateuimode(fig,'Exploration.Datacursor');
        end
        if nargout==1
            retval = hTool;
        end
        
    % Undocumented syntax    
    case 'enableandcreate'
        set(hManager,'CurrentMode',hMode);
        activateuimode(fig,'Exploration.Datacursor');
        modeFcn = get(hMode,'WindowButtonDownFcn');
        feval(modeFcn,[],[],hTool);
        
    case 'ison'
        retval = get(hTool,'Enable');
        
    case 'retval'
        retval = hTool;
        
    case 'none'
        % do nothing
end

%-----------------------------------------------%
function [hTool] = localGetObj(hMode)

hTool = hMode.ModeStateData.DataCursorTool;
hFig = hMode.FigureHandle;
    
% Create tool object
if isempty(hTool) || ~(ishandle(hTool))
    hTool = graphics.datacursormanager(hFig);
    hTool.UIContextMenu = hMode.UIContextMenu;
    hMode.ModeStateData.DataCursorTool = hTool;
    hMode.ModeStateData.ConsistencyCheck = 0;
end

%-----------------------------------------------%
function [hMode] = localGetMode(hFig)

hMode = getuimode(hFig,'Exploration.Datacursor');
if isempty(hMode)
    % Create the datacursormanager object
    hMode = uimode(hFig,'Exploration.Datacursor');
    hMode.ModeStateData.DataCursorTool = [];
    hTool = localGetObj(hMode);
    hMode.ModeStateData.DataCursorTool = hTool;
    % add listeners
    l(1) = handle.listener(hTool,...
        findprop(hTool,'Enable'),...
        'PropertyPostSet',...
        {@localSetEnable,hTool,hMode});
    l(end+1) = handle.listener(hTool,...
        findprop(hTool,'DisplayStyle'),...
        'PropertyPostSet',...
        {@localSetDisplayStyle,hTool,hMode});
    addlistener(hTool,l);
    hMode.ModeStateData.DataToolListener = l;
    %Set mode properties
    set(hMode,'WindowButtonMotionFcn',{@localWindowMotionFcn,hTool});
    set(hMode,'WindowButtonDownFcn',{@localWindowButtonDownFcn,hTool,hMode});
    set(hMode,'KeyPressFcn',{@localKeyPressFcn,hTool});
    set(hMode,'ModeStartFcn',{@localSetUIOn,hMode});
    set(hMode,'ModeStopFcn',{@localSetUIOff,hMode});
    set(hMode,'ButtonDownFilter',@localUseButtonDownFcnCallback);
end

%-----------------------------------------------%
function res = localUseButtonDownFcnCallback(hClickedObj,emptyData) %#ok<INUSD>
res = false;
hTargetParent = handle(get(hClickedObj,'Parent'));

% Ignore if object is a data cursor (parent group object)
% Delegate the button down to the datacursor
if isa(hTargetParent,'graphics.datatip')
    res = true;
end

% If the user clicked on the figure panel, delegate the button down
if strcmp(get(hClickedObj,'Tag'),'figpanel: title bar')
    res = true;
end

%-----------------------------------------------%
function localSetDisplayStyle(obj,evd,hTool,hMode) %#ok
  
dispstyle = get(hTool,'DisplayStyle');

if get(hTool,'Debug')
  disp(dispstyle)
end

switch(dispstyle)
   case 'window'
      % Remove all data cursors except for the 
      % one that has focus.
      hList = get(hTool,'DataCursors');
      hDatatip = get(hTool,'CurrentDataCursor');           
      if ~isempty(hList)  
         for n = 1:length(hList)
            if ~isequal(hList(n),hDatatip)  
               removeDataCursor(hTool,hList(n)); 
            end
         end 
 
         %  Remove datatip's text box
         htmp = get(hDatatip,'TextBoxHandle');
         set(htmp,'Visible','off');
      
         % Listen to datatip string and feed to panel
         h = handle.listener(hDatatip,...
             'UpdateCursor',...
             {@localUpdatePanel,hTool});
         hDatatip.addlistener(h);
                  
         h = handle.listener(hDatatip,...
             'ObjectBeingDestroyed',...
             {@localUpdatePanel,hTool});
         addlistener(hDatatip,h);
      end
      
      % If mode is on, turn on window 
      if strcmpi(get(hTool,'Enable'),'on')
            localPanelUIOn(hMode,hTool);

            % Hide text box on datatip with focus
            if ~isempty(hDatatip) 
               h = get(hDatatip,'TextBoxHandle');
               set(h,'Visible','off');
            end
         
            % Update string in panel
            localUpdatePanel([],[],hTool);
      end
          
   case 'datatip'  
       % Remove window
       localPanelUIOff(hTool);
       
       % Restore datatip's text box
       hDataCursor = get(hTool,'DataCursors');
       h = get(hDataCursor,'TextBoxHandle');
       set(h,'Visible','on');
end
    

%-----------------------------------------------%
function localSetEnable(obj,evd,hTool,hMode) %#ok
% Turn on/off UI to maintain consitency between the object and mode.

if get(hTool,'Debug')
  disp('localSetEnable')
end
fig = get(hTool,'Figure');
onoff = get(hTool,'Enable');
if strcmpi(onoff,'on')
    if ~hMode.ModeStateData.ConsistencyCheck;
        activateuimode(fig,'Exploration.Datacursor');
    end
else
    if ~hMode.ModeStateData.ConsistencyCheck;
        activateuimode(fig,'');
    end
end

%-----------------------------------------------%
function localSetUIOn(hMode)

fig = get(hMode,'FigureHandle');
hTool = hMode.ModeStateData.DataCursorTool;
setptr(fig,'datacursor');

% Turn on UI state 
set(uigettool(fig,'Exploration.DataCursor'),'State','on');   
set(findall(fig,'Tag','figMenuDatatip'),'Checked','on');

if strcmpi(get(hTool,'DisplayStyle'),'window')
   localPanelUIOn(hMode,hTool);
end
hMode.ModeStateData.ConsistencyCheck = 1;
set(hTool,'Enable','on');
hMode.ModeStateData.ConsistencyCheck = 0;
if isempty(hMode.UIContextMenu) || ~ishghandle(hMode.UIContextMenu)
    hMode.UIContextMenu = createUIContextMenu(hTool);
    hTool.UIContextMenu = hMode.UIContextMenu;
end

%-----------------------------------------------%
function localSetUIOff(hMode)
% Turn off UI state

fig = get(hMode,'FigureHandle');
hTool = hMode.ModeStateData.DataCursorTool;
set(uigettool(fig,'Exploration.DataCursor'),'State','off');   
set(findall(fig,'Tag','figMenuDatatip'),'Checked','off');

localPanelUIOff(hTool);
% Remove all data cursors if in window mode
if(strcmpi(get(hTool,'DisplayStyle'),'window'))
  removeAllDataCursors(hTool);
end
hMode.ModeStateData.ConsistencyCheck = 1;
set(hTool,'Enable','off');
hMode.ModeStateData.ConsistencyCheck = 0;

%-----------------------------------------------%
function localPanelUIOn(hMode,hTool)

if get(hTool,'Debug')
  disp('localPanelUIOn')
end

fig = get(hTool,'Figure');

DEFAULT_STR = 'Mouse Click on Plotted Data...';
TITLE = ' '; % eventually make the title show plot name property

hFrame = get(hTool,'PanelHandle');
pText = get(hTool,'PanelTextHandle');

% Create new panel if necessary
if isempty(hFrame) || ~ishghandle(hFrame)
   origToolbarMode = get(fig,'Toolbar');
   origToolbar = findall(fig,'Tag','FigureToolBar');
  
   % Make sure the toolbar does not go away if the Toolbar 
   % mode is 'auto' and the toolbar is already active.
   if strcmp(origToolbarMode,'auto') && ~isempty(origToolbar)
       set(fig,'Toolbar','figure');
   end
   
   % Create data panel
   hFrame = hTool.figpanel('parent',fig,'title',TITLE,'mode',hMode);   
   set(hFrame,'Visible','off');
   pos = get(hTool,'DefaultPanelPosition');
   if ~isempty(pos)
      fp = get(hFrame,'Position');
      set(hFrame,'Position',[pos(1), pos(2), fp(3), fp(4)]);   
   end

   %Make sure the string fits in the bounds of the window:
   if isempty(pText) || ~ishghandle(pText)
       textPar = graph2dhelper('findScribeLayer',fig);
       pText = text('Visible','off','String',{DEFAULT_STR;char(10)},'Units',get(hFrame,'Units'),'FontSize',...
           get(0,'DefaultUIControlFontSize'),'FontName',get(0,'DefaultUIControlFontName'),'HandleVisibility','off',...
           'Parent',textPar);
   else
       set(pText,'String',{DEFAULT_STR;char(10)});
   end
   tSize = get(pText,'Extent');
   pSize = get(hFrame,'Position');
   ind = find(pSize(3:4) < tSize(3:4));
   pSize(ind+2) = tSize(ind+2);
   set(hFrame,'Position',pSize);

   hTool.figpanel(hFrame,'String',DEFAULT_STR);
   hTool.figpanel(hFrame,'CloseFcn',{@localFrameCloseFcn,fig,hTool,origToolbarMode});
   hTool.figpanel(hFrame,'UIContextMenu',get(hTool,'UIContextMenu'));
   set(hFrame,'Visible','on');
   set(hTool,'PanelHandle',hFrame);
   set(hTool,'PanelTextHandle',pText);
end

% Permit dragging for any prior data cursors
set(get(hTool,'DataCursors'),'Draggable','on');

%-----------------------------------------------%
function localFrameCloseFcn(obj,evd,fig,hTool,origToolbarMode) %#ok

% Store panel position to get sticky behavior
hFrame = get(hTool,'PanelHandle');
pos = get(hFrame,'Position');
set(hTool,'DefaultPanelPosition',pos);

% Panel was deleted, so exit mode
activateuimode(fig,'');
set(fig,'Toolbar',origToolbarMode);

%-----------------------------------------------%
function localPanelUIOff(hTool)

% Remove data panel 
hFrame = get(hTool,'PanelHandle');
if ~isempty(hFrame) && ishghandle(hFrame)
  % Store panel position
  pos = get(hFrame,'Position');
  set(hTool,'DefaultPanelPosition',pos);
  delete(hFrame);
end

pText = get(hTool,'PanelTextHandle');
if ~isempty(pText) && ishghandle(pText)
    delete(pText);
end

%-----------------------------------------------%
function localKeyPressFcn(fig,evd,hTool)

% Exit early if invalid event data
if isempty(hTool) || ~ishandle(hTool) || ...
   ~isstruct(evd) || ~isfield(evd,'Key') || ...
   ~isfield(evd,'Character')
    return;
end
keypressed = evd.Key;

consumekey = false;

% Parse key press
movedir = [];
switch keypressed
    case 'leftarrow'
        movedir = 'left';   
    case 'rightarrow'       
        movedir = 'right';    
    case 'uparrow'
        movedir = 'up';       
    case 'downarrow'
        movedir = 'down';    
    case 'alt'
        consumekey = true;
end

% Move/delete datacursor
hDataCursor = get(hTool,'CurrentDataCursor');
if ~isempty(hDataCursor) && ishghandle(hDataCursor)
    if ~isempty(movedir)
        move(hDataCursor,movedir);            consumekey = true;        
    elseif strcmp(keypressed,'delete')
        removeDataCursor(hTool,hDataCursor);  consumekey = true;
    end
end
            
% Pass key to command window if ignored here. This maintains
% old style figure behavior
if ~consumekey 
    graph2dhelper('forwardToCommandWindow',fig,evd);
end

%-----------------------------------------------%
function localWindowButtonDownFcn(fig,evd,hTool,hMode) %#ok

if isempty(hTool) || ~ishandle(hTool)
    return;
end

if ~ishghandle(hMode.UIContextMenu)
    %We lost our context menu, likely due to a clf
    hMode.UIContextMenu = localCreateUIContextMenu(hTool);
    hTool.UIContextMenu = hMode.UIContextMenu;
end

fig = get(hTool,'Figure');

% Right click is for reserved context menu.
sel_type = get(fig,'SelectionType');
if ~strcmp(sel_type,'normal')
  return;
end

% Determine the object that we clicked on.
% We can't use get(fig,'CurrentObject') since that returns
% empty if the user has the handle visibility set to off.
hTarget = hittest(fig);

% Cast to handle type
hTarget = handle(hTarget);

doignore = false;

% Ignore if not a subclass of hg.GObject
if isempty(hTarget) || ~ishghandle(hTarget) || ~isa(hTarget,'hg.GObject')
  doignore = true;
end

% Ignore if not a child of an axes
hAxes = handle(ancestor(hTarget,'hg.axes'));
if ~doignore && (isempty(hAxes) || isequal(hAxes,hTarget)) 
  doignore = true;
end

% Ignore children of scribe objects
if ~doignore && isappdata(hTarget,'ScribeGroup')
    doignore = true;
end

% Ignore legend and colorbar
htag = get(hTarget,'tag');
if ~doignore && strcmp(htag,'legend') && strcmp(htag,'Colorbar')
    doignore = true;
end

% Ignore children of legend and colorbar
parent = get(hTarget,'parent');
if ~isempty(parent)
    ptag = get(parent,'tag');
    if ~doignore && strcmp(ptag,'legend') && strcmp(ptag,'Colorbar')
        doignore = true;
    end
end

% Ignore scribe objects
if ~doignore && isprop(hTarget,'shapeType')
    doignore = true;
end

% Get behavior object 
% ToDo: Hide behavior object details within datatip class
hBehavior = hggetbehavior(hTarget,'DataCursor','-peek');
isTarget = false;
while ~isempty(hBehavior) && ~isTarget
    if isempty(hBehavior.StartCreateFcn)
        isTarget = true;
    else
        hTargetNext = handle(hgfeval(hBehavior.StartCreateFcn));
        hBehavior = hggetbehavior(hTarget,'DataCursor','-peek');
        if isequal(hTargetNext,hTarget)
            isTarget = true;
        else
            hTarget = hTargetNext;
        end
    end
end

has_behavior_obj = false;
if ~doignore && ~isempty(hBehavior) && ishandle(hBehavior)
    has_behavior_obj = true;
    if ~get(hBehavior,'Enable')
         doignore = true;
    end
end

% Ignore text objects, rectangles, and uicontrols that don't have 
% behavior objects.
% ToDo: A better way is to delegate to the datatip via some method 
% to see if this object is supported
if (isa(hTarget,'rectangle') || ...
    isa(hTarget,'text') || ...
    isa(hTarget,'uicontrol')) ...
        && ~has_behavior_obj
    doignore = true;
end

% Create new datatip if user clicks on 'alt' key
doNewDatatip = false;
if strcmp(get(fig,'CurrentModifier'),'alt')
    doNewDatatip = true;
end

if ~doignore 
  % HG needs double-handles to avoid seg-v
  set(fig,'CurrentObject',double(hTarget)); 
  disp_style = get(hTool,'DisplayStyle');
  if strcmp(disp_style,'datatip')
     localWindowButtonDownFcnDatatip(fig,hTool,hTarget,doNewDatatip);
  else
     localWindowButtonDownFcnPanel(fig,hTool,hTarget);
  end
end

% send event
sendMouseEvent(hTool,'ButtonDown',hTarget);

%-----------------------------------------------%
function localWindowButtonDownFcnPanel(fig,hTool,hTarget)
% Create a datatip without the text box and place the 
% string into a small panel within the figure

% Get necessary handles
hDatatip = get(hTool,'CurrentDataCursor');

% Create a new datatip if necessary
if isempty(hDatatip) || ~ishghandle(hDatatip)
   
   % Wipe out any stale data cursors
   removeAllDataCursors(hTool);
   
   % Create a new datatip
   hDatatip = createDatatip(hTool,hTarget);
   set(hDatatip,'UIContextMenu',get(hTool,'UIContextMenu'));
   set(hDatatip,'HandleVisibility','off');
   
   % Turn off datatip text box in panel mode
   hText =  get(hDatatip,'TextBoxHandle');
   set(hText,'Visible','off');
         
   % Listen to datatip string and feed to panel
   h = handle.listener(hDatatip,...
       'UpdateCursor',...
       {@localUpdatePanel,hTool});
   addlistener(hDatatip,h);
   % Listen to datatip existence and feed to panel
   h = handle.listener(hDatatip,...
       'ObjectBeingDestroyed',...
       {@localUpdatePanel,hTool});
   addlistener(hDatatip,h);
end

% Update datatip state, position, and string
if ~isempty(hDatatip) && ishghandle(hDatatip) && ~isempty(hTarget) && ishghandle(hTarget)
   set(hDatatip,'Host',hTarget);
   set(hDatatip,'ViewStyle','marker');
      
   % Update datatip
   update(hDatatip);
   
   % Make sure the marker is visible based on the "Visible" property of the
   % host.
   hMarker = get(hDatatip,'MarkerHandle');
   set(hMarker,'Visible',get(hTarget,'Visible'));   
   
   % Update panel
   localUpdatePanel([],[],hTool);
   
   % start dragging
   startDrag(hDatatip,fig);
end

%-----------------------------------------------%
function localUpdateUIContextMenu(varargin) %#ok
% Stub method for reverse compatibility purposes.

%-----------------------------------------------%
function localUpdatePanel(obj,evd,hTool) %#ok
% Update panel string

DEFAULT_STR = 'Mouse Click on Plotted Data...';

hDatatip = get(hTool,'CurrentDataCursor');
hPanel = get(hTool,'PanelHandle');
pText = get(hTool,'PanelTextHandle');
str = DEFAULT_STR;
title_name = ' ';

if ~isempty(hDatatip) && ishghandle(hDatatip)  && ...
        ~strcmpi(get(hDatatip,'BeingDeleted'),'on')
    str = get(hDatatip,'String');
    % Update panel's title bar based on target
    hTarget = get(hDatatip,'Host');
    
    if ~isempty(hTarget) && ishghandle(hTarget)

        title_name = ' ';

        % Use specified Display Name
        if ~isempty(findprop(hTarget,'DisplayName'))
            title_name = get(hTarget,'DisplayName');
        end
        % Use class name
        if isempty(title_name)
            title_name = get(classhandle(handle(hTarget)),'Name');
        end
    end
end

if ~isempty(hPanel) && ishghandle(hPanel)
        
        hTool.figpanel(hPanel,'String',str);
        
        %Make sure the string fits in the bounds of the window:
        if ~iscell(str)
            str = {str};
        end
        str{end+1} = char(10);
        if isempty(pText) || ~ishghandle(pText)
            pText = text('Visible','off','String',str,'Units',get(hPanel,'Units'),'FontSize',...
                get(0,'DefaultUIControlFontSize'),'FontName',get(0,'DefaultUIControlFontName'),'HandleVisibility','off');
            set(hTool,'PanelTextHandle',pText);
        else
            set(pText,'String',str);
        end
        tSize = get(pText,'Extent');
        pSize = get(hPanel,'Position');
        ind = find(pSize(3:4) < tSize(3:4));
        pSize(ind+2) = tSize(ind+2);
        set(hPanel,'Position',pSize);
                 
        % Set panel's title string
        hTool.figpanel(hPanel,'Title',upper(title_name));
end

%-----------------------------------------------%
function localWindowButtonDownFcnDatatip(fig,hTool,hTarget,docreate)
% Create datatip UI

hTargetBehavior = hggetbehavior(hTarget,'DataCursor','-peek');

hDatatip = get(hTool,'CurrentDataCursor');

% Query target's behavior object to see if we should create
% a new datatip
if ~docreate && any(ishandle(hTargetBehavior))
       docreate = get(hTargetBehavior,'CreateNewDatatip');
end

% Create a new datatip if the current datatip has draggable set to
% off. This scenario occurs with response plots.
if ~isempty(hDatatip) && ishghandle(hDatatip)
   if strcmp(get(hDatatip,'Draggable'),'off')   
       docreate = true;
   end
end

% Create a new datatip when appropriate
if isempty(hDatatip) ...
        || ~ishghandle(hDatatip) ...
        || get(hTool,'NewDataCursorOnClick') ...
        || docreate
    hDatatip = hTool.createDatatip(hTarget);
    %Create a copy of the context menu for the datatip:
    set(hDatatip,'UIContextMenu',get(hTool,'UIContextMenu'));
    set(hDatatip,'HandleVisibility','off');
end
  
% Update position
if any(ishghandle(hDatatip)) && any(ishghandle(hTarget)) 
  
   % Toggle OrientationMode to auto so datatip appears with best
   % orientation.
   
   origInvalidState = get(hDatatip,'Invalid');
   set(hDatatip,'Invalid',true);
   set(hDatatip,'OrientationMode','auto');
   set(hDatatip,'Invalid',origInvalidState);
  
   set(hDatatip,'Host',hTarget);
   % Be sure to toggle the "Visible" property based on the host:
   set(hDatatip,'Visible',get(hTarget,'Visible'));
   set(hDatatip,'ViewStyle','datatip');
   update(hDatatip);
   set(hDatatip,'OrientationMode','manual');
 
   % start dragging
   startDrag(hDatatip,fig);
end

%-----------------------------------------------%
function localWindowMotionFcn(fig,evd,hTool) %#ok

fig = evd.Source;
% Get current point in figure units
curr_units = hgconvertunits(fig,[0 0 evd.CurrentPoint],...
    'pixels',get(fig,'Units'),fig);
curr_units = curr_units(3:4);
if ~any(ishandle(hTool))
    return;
end

set(fig,'CurrentPoint',curr_units);
obj = handle(hittest(fig));
allHit = hittest(fig,'axes');
allAxes = findobj(allHit,'flat','Type','Axes','HandleVisibility','on');
hAx = [];

% If mouse is over an axes
for i=1:length(allAxes),
    candidate_ax=allAxes(i);

    b = hggetbehavior(candidate_ax,'DataCursor','-peek');
    if ~isempty(b) &&  ishandle(b) && ~get(b,'Enable')
        % ignore this axes

        % 'NonDataObject' is a legacy flag defined in
        % datachildren m-file.
    elseif ~isappdata(candidate_ax,'NonDataObject')
        hAx = candidate_ax;
        break;
    end
end

% If the mouse is over the panel's title bar, set the cursor to a fleur:
objTag = get(obj,'Tag');
if strcmpi(objTag,'figpanel: title bar')
    set(fig,'Pointer','fleur');
% If the mouse is over the text field, make the cursor an arrow.
elseif strcmpi(objTag,'figpanel:text field')
    setptr(fig,'arrow');
% ToDo: Clean up API for testing if obj is data cursor
elseif strcmpi(objTag,'DataTipMarker')
   set(fig,'Pointer','fleur')
elseif ~isempty(hAx) && localInBounds(hAx)
  setptr(fig,'datacursor');
else
  setptr(fig,'arrow');
end

% send event
sendMouseEvent(hTool,'MouseMotion',obj);

%-----------------------------------------------%
function targetInBounds = localInBounds(hAxes)
%Check if the user clicked within the bounds of the axes. If not, do
%nothing.
targetInBounds = true;
tol = 3e-16;
cp = get(hAxes,'CurrentPoint');
XLims = get(hAxes,'XLim');
if ((cp(1,1) - min(XLims)) < -tol || (cp(1,1) - max(XLims)) > tol) && ...
        ((cp(2,1) - min(XLims)) < -tol || (cp(2,1) - max(XLims)) > tol)
    targetInBounds = false;
end
YLims = get(hAxes,'YLim');
if ((cp(1,2) - min(YLims)) < -tol || (cp(1,2) - max(YLims)) > tol) && ...
        ((cp(2,2) - min(YLims)) < -tol || (cp(2,2) - max(YLims)) > tol)
    targetInBounds = false;
end
ZLims = get(hAxes,'ZLim');
if ((cp(1,3) - min(ZLims)) < -tol || (cp(1,3) - max(ZLims)) > tol) && ...
        ((cp(2,3) - min(ZLims)) < -tol || (cp(2,3) - max(ZLims)) > tol)
    targetInBounds = false;
end