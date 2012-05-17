function varargout = daexplr(varargin)
%DAEXPLR Launches the Design Automation Model Explorer.
%   The Model Explorer is a unified explorer tool for Simulink,
%   Stateflow, SimMechanics, and related products.

%   Copyright 2004-2010 The MathWorks, Inc.

mlock;

MsgIncorrectArgCount = 'Wrong number of arguments specified to daexplr';
MsgIncorrectArgType  = 'Wrong type of arguments specified to daexplr';
MsgIncorrectRootType = 'Root Object must be a hierarchical DAStudio.Object';

%% parse input arguments
root     = slroot;
whattodo = [];
node     = [];
legacy   = false;

switch nargin
    case 0
        % use defaults

    case 1
        if islogical(varargin{1})
            legacy = varargin{1};
        else
            root   = varargin{1};
        end
        
    case 2
        whattodo = varargin{1};
        node     = varargin{2};
        
    case 3
        root     = varargin{1};
        whattodo = varargin{2};
        node     = varargin{3};
        
    otherwise
        error('DAStudio:DAExplore:IncorrectArgCount', MsgIncorrectArgCount);
end

%% error checking
if isempty(root) || ~root.isa('DAStudio.Object') || ~root.isHierarchical
    error('DAStudio:DAExplore:MsgIncorrectRootType', MsgIncorrectRootType);
end

if ~isempty(whattodo) && ~ischar(whattodo)
    error('DAStudio:DAExplore:IncorrectArgType', MsgIncorrectArgType);
end

if ~isempty(node) && ~(isnumeric(node) || node.isa('DAStudio.Object'))
    error('DAStudio:DAExplore:IncorrectArgType', MsgIncorrectArgType);
end

%% open the Simulink & Stateflow Model Explorer
me        = [];
daRoot    = DAStudio.Root;
explorers = daRoot.find('-isa', 'DAStudio.Explorer');
for i=1:length(explorers)
    if root == explorers(i).getRoot
        me = explorers(i);
        break;
    end
end

if isempty(me)
    me = DAStudio.Explorer(root, 'DAStudio Model Explorer', false);
    configure(me, legacy);
end

me.show;

%% navigate to a node (if requested)
if ~isempty(whattodo)
    if strcmpi(whattodo,'view') == 1
        if ~ishandle(node)
            sfr = sfroot;
            node = sfr.find('id', node);
        end
        me.view(node);
    end
end

if nargout == 1
    varargout{1} = me;
end


% Configure the ME instance to be the Simulink & Stateflow Model Explorer
function configure(me, legacy)

% add tree view toolbar actions
am = DAStudio.ActionManager;

% TODO: Add it as default actions now but once we have mechanism to sync actions in
% menus (w/o icons) to actions w/ icons, we will remove these default
% actions from .cpp.
maskAction = am.createDefaultAction(me, 'VIEW_TREESHOWMASKEDSUBSYSTEMS');
pathToIcon = fullfile(matlabroot, 'toolbox', 'shared', 'dastudio','resources', 'showmaskmask_comp.png');
maskAction.icon = pathToIcon;
maskAction.toolTip = DAStudio.message('Shared:DAS:ShowHideMasked');

linkAction = am.createDefaultAction(me, 'VIEW_TREESHOWLINKEDSUBSYSTEMS');
pathToIcon = fullfile(matlabroot, 'toolbox', 'shared', 'dastudio','resources','showlinkmask_comp.png');
linkAction.icon = pathToIcon;
linkAction.toolTip = DAStudio.message('Shared:DAS:ShowHideLinked');

me.addTreeAction(linkAction);
me.addTreeAction(maskAction);
%me.addTreeAction(am.createDefaultAction(me, 'VIEW_CURRENTANDBELOW'));

if legacy
    me.addCustomPropsGroup('Fixed-Point Properties',...
        {   ...
        'OutDataTypeStr';...
        'SaturateOnOverflow';...
        'Rounding';...
        'DataType';...
        'FixptType.Bias';...
        'FixptType.FractionalSlope';...
        'FixptType.RadixPoint';...
        'FixptType.Lock';...
        'FixptType.BaseType';...
        }                    );
else
    % install views from preferences first then factory
    vm = DAStudio.MEViewManager(); 
    vm.install(me, true);
    % install views submenu in 'View' menu bar of model explorer
    sub = am.createPopupMenu(me);
    % Show Details menu item of Current View menu.
    action = am.createAction(me, 'Text', DAStudio.message('Shared:DAS:ShowDetails'));
    action.Tag = 'views_show_details';
    action.toggleAction = 'on';
    if vm.IsCollapsed
        action.on = 'off';
    else
        action.on = 'on';
    end
    action = addCallbackData(action, {'customizeView', vm});
    action.callback = ['MEViewManager_action_cb(' num2str(action.id) ')'];
    action = addMenuActionData(action, vm);
    sub.addMenuItem(action);
    sub.addSeparator();
    % Manage Views... menu item of Current View menu.
    action = am.createAction(me, 'Text', DAStudio.message('Shared:DAS:ManageViews'));
    action.Tag = 'views_manage_views';
    action.callback = ['MEViewManager_action_cb(' num2str(action.id) ')'];
    action = addCallbackData(action, {'manageView', vm});
    sub.addMenuItem(action);
    am.addSubMenuItem(me, 'View', sub, ...
                      DAStudio.message('Shared:DAS:ColumnView'), ...
                      'Row Filter', false);
    vm.load;
end

%
%
function action = addMenuActionData(action, vm)
p = schema.prop(action, 'Listener', 'handle');
p.Visible = 'off';
ac = DAStudio.ActionManager;
contextAction = ac.createDefaultAction(vm.Explorer, 'VIEW_SHOWDETAILSOFCURRENTVIEW');
cls = classhandle(vm);
propListened = findprop(cls, 'IsCollapsed');
action.Listener = handle.listener(vm, propListened, 'PropertyPostSet', ...
                                  {@updateMenuItem, vm, action, contextAction});
 
%
%
function updateMenuItem(~, ~, vm, action, contextAction)
if vm.IsCollapsed
   if ~strcmp(action.on, 'off')
        action.on = 'off';
   end
   if ~isempty(contextAction)
        if ~strcmp(contextAction.on, 'off')
            contextAction.on = 'off';
        end
   end
else
   if ~strcmp(action.on, 'on')
        action.on = 'on';
   end  
   if ~isempty(contextAction)
       if ~strcmp(contextAction.on, 'on')
           contextAction.on = 'on';
       end
   end
end

    
