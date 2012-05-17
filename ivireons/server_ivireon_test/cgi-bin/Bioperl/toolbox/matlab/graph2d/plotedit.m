function varargout = plotedit(varargin)
%PLOTEDIT  Tools for editing and annotating plots
%   PLOTEDIT ON   starts plot edit mode for the current figure.
%   PLOTEDIT OFF  ends plot edit mode for the current figure.
%   PLOTEDIT  with no arguments toggles the plot edit mode for
%      the current figure.
%
%   PLOTEDIT(FIG)  toggles the plot edit mode for figure FIG.
%   PLOTEDIT(FIG,'STATE')  specifies the PLOTEDIT STATE for
%      the figure FIG.
%   PLOTEDIT('STATE')  specifies the PLOTEDIT STATE for
%      the current figure.
%
%      STATE can be one of the strings:
%          ON - starts plot edit mode
%          OFF - ends plot edit mode
%          SHOWTOOLSMENU - displays the Tools menu (the default)
%          HIDETOOLSMENU - removes the Tools menu from the menubar
%
%   When PLOTEDIT is ON, use the Tools menu to add and
%   modify objects, or select the annotation toolbar buttons
%   to add annotations such as text, line and arrows.
%   Click and drag objects to move or resize them.
%
%   To edit object properties, right click or double click on
%   the object.
%
%   Shift-click to select multiple objects.
%
%   See also PROPEDIT.

%   Internal interfaces for toolbox-plotedit compatibility
%
%   plotedit(FIG,'hidetoolsmenu')
%      makes the standard figure 'Tools' menu Visible off
%   plotedit(FIG,'showtoolsmenu')
%      makes the standard figure 'Tools' menu Visible on
%   h = plotedit(FIG,'gethandles')
%      returns a list of the hidden plot editor objects which
%      should be excluded from GUIDE's object browser.
%   h = plotedit(FIG,'gettoolbuttons')
%      returns a list plot editing and annotation buttons in
%      the toolbar.  Used by UISUSPEND and UIRESTORE.
%   h = plotedit(FIG,'locktoolbarvisibility')
%      freezes the current state of the toolbar.
%   plotedit(FIG,'setsystemeditmenus')
%      restores the system Edit menu.
%   plotedit(FIG,'setploteditmenus')
%      restores the plotedit Edit menu.
%   plotedit(FIG,'plotedittoolbar',action)
%      applies the action to the plot edit toolbar.
%
%   these are used by UISUSPEND/UIRESTORE
%   a = plotedit(FIG,'getenabletools')
%      returns the enable state of the plot editing tools
%   plotedit(FIG,'setenabletools','off')
%      disables the plot editing tools under Tools menu
%      and disables the Tools menu callback which updates
%      the status of the tools menu, and disables the plot
%      editing tools in the Toolbar
%   plotedit(FIG,'setenabletools','on')
%      enables the Tools menu and the items underneath it
%      and enables the plot editing buttons in the Toolbar
%
%   To hide the figure toolbar, set the figure 'ToolBar'
%   property (hidden) to 'none'.
%      set(fig,'ToolBar','none');
%
%   plotedit({'subfcn',...}) fevals the subfunction and passes
%   it the rest of the inputs.
%
%   plotedit(FIG,'on','pointer',POINTER) if the current pointer is a watch
%   sets the pointer to return to when exiting plotedit mode to
%   POINTER. If not specified use the default pointer.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.53.4.36 $  $Date: 2010/03/31 18:23:49 $
%   j. H. Roh  10/20/97

pointer = [];
switch nargin
    case 0
        % plotedit
        fig = gcf;
        action = 'toggle';
    case 1
        if iscell(varargin{1})
            % switchyard to subfunctions or private functions
            args = varargin{1};
            if nargout > 0
                [varargout{1:nargout}] = feval(args{:});
            else
                feval(args{:});
            end
            return;
        elseif ischar(varargin{1})
            % plotedit [on | off ]
            fig = gcf;
            action = varargin{1};
        else
            % plotedit(fig)
            if any(ishghandle(varargin{1}, 'figure'))
                fig = varargin{1};
            else
                fig = gcf;
            end
            action = 'toggle';
        end
    case 2
        if any(ishghandle(varargin{1}, 'figure'))
            fig = varargin{1};
        else
            fig = gcf;
        end
        action = varargin{2};
    case {3 4}
        if any(ishghandle(varargin{1}, 'figure'))
            fig= varargin{1};
        else
            fig = gcf;
        end
        action = varargin{2};
        parameter = varargin{3}; % silent: don't switch button
        switch parameter
            case 'pointer'
                pointer = varargin{4};
        end
end

% For legacy reasons, exit early if the action is "promoteoverlay" (this is
% R13-era code.
if strcmpi(action,'promoteoverlay')
    return;
end

% If the mode has never been constructed and the action is "off",
% short-circuit:
if strcmpi(action,'off') && ~hasuimode(fig,'Standard.EditPlot')
    return;
end

% If the mode has never been constructed and the action is "isactive",
% return false and short-circuit:
if strcmpi(action,'isactive') && ~hasuimode(fig,'Standard.EditPlot')
    varargout{1} = 0;
    return;
end

hMode = localGetMode(fig);

switch lower(action)
    case 'on'
        if strcmpi(hMode.Enable,'off')
            % Activate the mode
            activateuimode(fig,'Standard.EditPlot');
            % If the pointer is sent as an additional input argument,
            % augment the mode to take care of this behind the scenes
            if ~isempty(pointer)
                hMode.FigureState.Pointer = pointer;
            end
        end
    case 'off'
        if strcmpi(hMode.Enable,'off') % already off
            return;
        end
        activateuimode(fig,'');
    case 'toggle'
        if strcmpi(hMode.Enable,'off')
            activateuimode(fig,'Standard.EditPlot');
        else
            activateuimode(fig,'');
        end
    case 'cut'
        if hMode.ModeStateData.PlotSelectMode.ModeStateData.CutCopyPossible
            scribeccp(fig, 'cut');
        end
    case 'copy'
        if hMode.ModeStateData.PlotSelectMode.ModeStateData.CutCopyPossible                    
            scribeccp(fig, 'copy');
        end
    case 'paste'
        % If a paste is not possible, assume we are pasting into the
        % figure. This is for ^C^V shortcuts to execute properly.
        if ~hMode.ModeStateData.PlotSelectMode.ModeStateData.PastePossible
            selectobject(fig,'replace');
        end
        if hMode.ModeStateData.PlotSelectMode.ModeStateData.PastePossible
            scribeccp(fig, 'paste');
        end
    case 'clear'
        scribeccp(fig, 'clear');
    case 'delete'
        if hMode.ModeStateData.PlotSelectMode.ModeStateData.DeletePossible
            scribeccp(fig, 'delete');
        end
    case 'selectall'
        localSelectAll(hMode);
    case 'hidetoolsmenu'
        set(findobj(allchild(fig),'flat','Type','uimenu','Tag','figMenuTools'),...
            'visible','off');
    case 'showtoolsmenu'
        set(findobj(allchild(fig),'flat','Type','uimenu','Tag','figMenuTools'),...
            'visible','on');
    case 'plotedittoolbar'
        if nargin < 3
            parameter = 'toggle';
        end
        plotedittoolbar(fig,parameter);
    case 'setenabletools'
        if nargin==3
            setappdata(fig,'ScribePloteditEnable',parameter);
            % disable toolbar
            toolButtons = plotedit(fig,'gettoolbuttons');
            set(toolButtons,'Enable',parameter);
            % disable Tools menu
            % happens within the Tools menu callback, by polling the
            % ScribePloteditEnable state
        end
    case 'getenabletools'
        ploteditEnable = getappdata(fig,'ScribePloteditEnable');
        if isempty(ploteditEnable)
            varargout{1} = 'on';    % default
        else
            varargout{1} = ploteditEnable;
        end
    case 'setsystemeditmenus'
        localModifyFigMenus(fig,'off');
    case 'setploteditmenus'
        localModifyFigMenus(fig,'on');
    case 'gettoolbuttons'
        % Call subfunctions that return the toolbar buttons and insert menu items.
        h = getScribeToolbarButtons(fig);
        hinsertmenuitems = getScribeMenuItems(fig);
        if nargout>0
            varargout{1} = [h;hinsertmenuitems];
        end
    case 'locktoolbarvisibility'
        toolbarShowing = ~isempty(localFindall(fig,'Tag','FigureToolBar'));
        if toolbarShowing
            set(fig,'Toolbar','figure');
        else
            set(fig,'Toolbar','none');
        end
    case 'isactive'
        switch hMode.Enable
            case 'on'
                varargout{1} = 1;
            case 'off'
                varargout{1} = 0;
        end
    case 'getmode'
        varargout{1} = hMode;
end

%-----------------------------------------------------------------------%
function hMode = localGetMode(hFig)
% Sets up and returns the mode object

hMode = getuimode(hFig,'Standard.EditPlot');
if isempty(hMode)
    %Construct the mode object and set properties
    hMode = uimode(hFig,'Standard.EditPlot');
    % Set the start and stop functions of the mode to do bookkeeping with
    % the figure state.
    set(hMode,'ModeStartFcn',{@localModeStartFcn,hMode});
    set(hMode,'ModeStopFcn',{@localModeStopFcn,hMode});
    % This mode is defined as a composite mode containing "Plot Select
    % Mode" (default), "Object Create Mode" and "Pin Mode"
    hPlotSelect = plotSelectMode(hMode);
    set(hMode,'DefaultUIMode','Standard.PlotSelect');
    hMode.ModeStateData.PlotSelectMode = hPlotSelect;
    hCreateMode = scribeCreateMode(hMode);
    hMode.ModeStateData.CreateMode = hCreateMode;
    hPinMode = scribePinMode(hMode);
    hMode.ModeStateData.PinMode = hPinMode;
end

%-----------------------------------------------------------------------%
function localModeStartFcn(hMode)
% Set up the figure environment:
fig = hMode.FigureHandle;
      
% Set app data for reverse compatibility reasons
setappdata(fig,'scribeActive','on');
% if there is not already a scribeaxes for this figure, create one
graph2dhelper('findScribeLayer',fig);

scribetogg = uigettool(fig,'Standard.EditPlot');
if ~isempty(scribetogg) && ~strcmpi(get(scribetogg,'beingdeleted'),'on')
    set(scribetogg,'state','on');
end
update_edit_menu(fig, false);

%-----------------------------------------------------------------------%
function localModeStopFcn(hMode)
% Restore the figure environment:
fig = hMode.FigureHandle;

scribeaxes = handle(getappdata(fig,'Scribe_ScribeOverlay'));
% no action is needed if scribeaxes doesn't exist or is not a valid
% scribe axes.
if ~isempty(scribeaxes) && isa(scribeaxes,'scribe.scribeaxes')
    % Remove appdata for reverse compatibility.
    if isappdata(fig,'scribeActive')
        rmappdata(fig,'scribeActive');
    end
    scribetogg = uigettool(fig,'Standard.EditPlot');
    if ~isempty(scribetogg) && ~strcmpi(get(scribetogg,'beingdeleted'),'on')
        set(scribetogg,'state','off');
    end
    % turn off other toggles
    % This should be returned by a private function which talks to
    % the plot edit toolbar
    update_edit_menu(fig, false);
end

%-----------------------------------------------%
function update_scribecontextmenu_cb(varargin) %#ok<DEFNU>
% This method exists for reverse compatibility purposes. It is a no-op.

%-----------------------------------------------%
function scribe_cut_cb(varargin) %#ok<DEFNU>
% This method exists for reverse compatibility purposes. It is a no-op.

%-----------------------------------------------%
function scribe_copy_cb(varargin) %#ok<DEFNU>
% This method exists for reverse compatibility purposes. It is a no-op.

%-----------------------------------------------%
function scribe_paste_cb(varargin) %#ok<DEFNU>
% This method exists for reverse compatibility purposes. It is a no-op.

%-----------------------------------------------%
function scribe_delete_cb(varargin) %#ok<DEFNU>
% This method exists for reverse compatibility purposes. It is a no-op.

%-----------------------------------------------%
function setcb(varargin) %#ok<DEFNU>
% This method exists for reverse compatibility purposes. It is a no-op.

%-----------------------------------------------%
function update_edit_menu(hfig,allfigs)

if nargin == 1, allfigs = true; end

if (allfigs)
    hfig = handle(localFindall(0, 'type', 'figure'));
end

for i=1:length(hfig)
    edit = localFindall(allchild(hfig(i)),'flat','type','uimenu','tag','figMenuEdit');
    if isempty(edit), continue; end
    kids = allchild(edit);
    cut = localFindall(kids,'flat','Tag','figMenuEditCut');
    copy = localFindall(kids,'flat','Tag','figMenuEditCopy');
    paste = localFindall(kids,'flat','Tag','figMenuEditPaste');
    clear = localFindall(kids,'flat','Tag','figMenuEditClear');
    delete = localFindall(kids,'flat','Tag','figMenuEditDelete');
    selectall = localFindall(kids,'flat','Tag','figMenuEditSelectAll');
    if ~isappdata(hfig(i), 'scribeActive')
        onoff = 'off';
        set([cut; copy; paste; clear; delete; selectall],'enable',onoff);
    else
        hMode = localGetMode(hfig(i));
        hPlotSelect = hMode.ModeStateData.PlotSelectMode;
        % Query the mode to see what actions are possible
        if hPlotSelect.ModeStateData.CutCopyPossible
            cccenable = 'on';
        else
            cccenable = 'off';
        end
        if hPlotSelect.ModeStateData.DeletePossible
            delenable = 'on';
        else
            delenable = 'off';
        end
        set([cut; copy],'enable',cccenable);
        set(delete,'enable',delenable);

        % paste enable/disable
        penable = 'off';
        sbufferclear = 'off';
        if ~isempty(getappdata(0,'ScribeCopyBuffer'))
            sbufferclear = 'on';
            penable = 'on';
        end
        set(paste,'enable',penable);
        set(clear,'enable',sbufferclear);
        set(selectall,'enable','on');
    end
end

%-----------------------------------------------------------------------%
function localSelectAll(hMode)

fig = hMode.FigureHandle;
scribeax = handle(graph2dhelper('findScribeLayer',fig));
if (any(ishghandle(scribeax)) && ~strcmpi(get(scribeax,'BeingDeleted'),'on')) ||...
        (isobject(scribeax) && isvalid(scribeax))
  shapes = get(scribeax,'Children');
  ax = findobj(get(fig,'Children'),'flat','type','axes');
  if ~isempty(ax)
    axNonData = true(1,length(ax));
    for k=length(ax):-1:1
      axNonData(k) = isappdata(ax(k),'NonDataObject');
    end
    ax(axNonData) = [];
  end
  if ~isempty(shapes)
      selectobject([shapes;ax],'replace');
  else
      selectobject(ax,'replace');
  end
end

%-----------------------------------------------------------------------%
function ObjList=localFindall(HandleList,varargin)
Temp=get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');
try
  ObjList=findobj(HandleList,varargin{:});
catch e %#ok<NASGU>
  ObjList=-1;
end
set(0,'ShowHiddenHandles',Temp);
if isequal(ObjList,-1),
  error('MATLAB:findall:InvalidParameter','Invalid Parameter-value pairs passed to findall.');
end