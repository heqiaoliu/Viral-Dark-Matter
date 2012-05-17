function result = sf_de_manager(method, objId, dataId)
%   Copyright 1997-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.15 $  $Date: 2010/05/20 03:36:18 $

persistent cache;
result = [];

% DE manager only works for Stateflow charts
if nargin==2 && isempty(sf('find', objId, 'chart.id', objId))
    return;
end

if isempty(cache)
    cache = cell(0, 3);
    mlock;
end

switch method
  case 'open', [cache, result] = open(cache,objId);
  case 'close',          cache = close(cache,objId);
  case 'refresh_title',          refresh_title(cache,objId);        
  case 'refresh_all_titles',     refresh_all_titles(cache);        
  case 'view',                   [cache,result]=view(cache,objId,dataId);
  case 'show_main_dialog',  [cache,result] = show_main_dialog(cache,objId);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [cache,me] = view(cache, objId, dataId)
[cache,me] = open(cache,objId);

r = slroot;
h = r.idToHandle(dataId);
me.view(h);

return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [cache,me] = show_main_dialog(cache, objId)

[cache,me] = open(cache,objId);
 
ime = DAStudio.imExplorer(me);
h = idToHandle(sfroot,objId);

% After discussing with Ahmed this is the best we came up with.
% Created geck 489610 requesting a better, more robust solution.
ime.selectTreeViewNode(h);
ime.selectListViewNode(0);
ed = DAStudio.EventDispatcher;
ed.broadcastEvent('ListChangedEvent');

%ime.hideDialogView;
%ime.showDialogView;

%h.dialog;

return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [cache, me] = open(cache,objId)

me = de_manager_cache_find_entry(cache, objId);
if isempty(me)
    [me, listener] = create_de_manager(objId);
    cache(end+1,:) = {objId, me, listener};
else
    me.show;
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cache = close(cache,objId)
[me, listener, index] = de_manager_cache_find_entry(cache, objId);
if ~isempty(me)
    if ishandle(listener)
        delete(listener);
    end
    
    if ishandle(me)
        delete(me);
    end
    
    cache(index,:) = [];
end

return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function refresh_title(cache,objId)
me = de_manager_cache_find_entry(cache, objId);
if ~isempty(me)
    set_title(me,objId);
end

return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function refresh_all_titles(cache)

len = size(cache, 1);
for i = 1:len
    id = cache(i,1);
    me = cache(i,2);
    set_title(me,id);
end

return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [me, listener, index] = de_manager_cache_find_entry(cache, objId)

me = [];
listener = [];
index = 0;

len = size(cache, 1);
for i = 1:len
    if cache{i, 1} == objId
        index = i;
        me = cache{i, 2};
        listener = cache{i, 3};
        break;
    end
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function post_closed_call_back(eSrc, eData, objId)

sf_de_manager('close', objId);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [e, l] = create_de_manager(objId)

persistent iconPath;

if isempty(iconPath)
    iconPath = fullfile(matlabroot, 'toolbox', 'shared', 'dastudio', 'resources');
end

sfObj = idToHandle(sfroot, objId);

e = DAStudio.Explorer(sfObj, message('Title'), false);
preferPos = get_position;
e.position = preferPos;
set_title(e,objId);
e.Icon = fullfile(iconPath, 'ModelExplorer.png');
e.setTreeTitle('');
e.allowWholeRowDblClick = true;
e.showContentsOf(false); %remove the "show contents of" header for the child list middle pane

% Listeners
l = handle.listener(e, 'MEPostClosed', {@post_closed_call_back, objId});

ime = DAStudio.imExplorer(e);
ime.hideTreeView();
ime.showDialogView;

% Clear default menus
am = DAStudio.ActionManager;
am.initializeClient(e);

%default action strings are in
%src/dastudio/include/ModelExplorerMenuItemIDs.h
i.addData = am.createDefaultAction(e,'ADD_DATA');
i.addInputTrigger = am.createDefaultAction(e,'ADD_TRIGGER');
i.addFunctionCallOutput = am.createDefaultAction(e,'ADD_FUNCTIONCALL');

i.Cut  = am.createDefaultAction(e,'EDIT_CUT');
i.Copy = am.createDefaultAction(e,'EDIT_COPY');
i.Paste = am.createDefaultAction(e,'EDIT_PASTE');
i.Delete = am.createDefaultAction(e,'EDIT_DELETE');

i.gotoBlockUI = am.createAction(e,...
    'Text', message('BlockEditorText'),...
    'ToolTip', message('BlockEditorToolTip'),...
    'Callback', goto_block_call_back(objId),...
    'Icon', fullfile(iconPath, 'up.png'),...
    'StatusTip', message('BlockEditorStatusTip'));

blockDialogIcon = fullfile(iconPath, 'data_ports_manager.gif');

i.showBlockDialog = am.createAction(e,...
    'Text',message('BlockDialogText'),...
    'ToolTip',message('BlockDialogToolTip'),...
    'Callback',show_block_dialog_call_back(objId),...
    'Icon',blockDialogIcon,...
    'StatusTip',message('BlockDialogStatusTip'));

i.promptUnappChg = am.createDefaultAction(e, 'TOOLS_PROMPT_DLG_REPLACE');

% ----------- Menubars ---------------
EditMenuBar = am.createPopupMenu(e);
EditMenuBar.addMenuItem(i.Cut);
EditMenuBar.addMenuItem(i.Copy);
EditMenuBar.addMenuItem(i.Paste);
EditMenuBar.addMenuItem(i.Delete);
am.addSubMenu(e, EditMenuBar, 'Edit')

AddMenuBar = am.createPopupMenu(e);
AddMenuBar.addMenuItem(i.addData);
AddMenuBar.addMenuItem(i.addInputTrigger);
AddMenuBar.addMenuItem(i.addFunctionCallOutput);
am.addSubMenu(e, AddMenuBar, 'Add');

ToolsMenuBar = am.createPopupMenu(e);
ToolsMenuBar.addMenuItem(i.gotoBlockUI);
ToolsMenuBar.addMenuItem(i.showBlockDialog);
ToolsMenuBar.addSeparator;
ToolsMenuBar.addMenuItem(i.promptUnappChg);
am.addSubMenu(e, ToolsMenuBar, 'Tools');

% ----------- Toolbars ---------------
toolBar = am.createToolBar(e);
toolBar.addAction(i.addData);
toolBar.addAction(i.addInputTrigger);
toolBar.addAction(i.addFunctionCallOutput);
toolBar.addSeparator;

toolBar.addAction(i.Cut);
toolBar.addAction(i.Copy);
toolBar.addAction(i.Paste);
toolBar.addAction(i.Delete);
toolBar.addSeparator;

toolBar.addAction(i.gotoBlockUI);
toolBar.addAction(i.showBlockDialog);

%Force Root dialog to redraw now that Actions is populated
%e.getDialog.refresh;
e.show;

% Order is important:  
% This must be done after we show the dialog otherwise it won't work.
ime.setListViewWidth(preferPos(3) * 0.25);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function set_title(e,objId)

objFullName = sf('FullNameOf', objId, '.');
e.Title = sprintf('%s (%s)', message('Title'), objFullName);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function callback = goto_block_call_back(objId)

callback = sprintf('sf(''Open'', %d);', objId);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function callback = show_block_dialog_call_back(objId)

callback = sprintf('sf(''Private'',''sf_de_manager'',''show_main_dialog'', %d);', objId);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function position = get_position

w = 680; h = 600;
screenSize = get(0, 'ScreenSize');
pX = max(1, (screenSize(3) - w) / 2);
pY = max(1, (screenSize(4) - h) / 2);

position = [pX, pY, w, h];
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s = message(id,varargin)

s = DAStudio.message(['Stateflow:demanager:' id],varargin{:});
