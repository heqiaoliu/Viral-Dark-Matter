function dlgstruct = getDialogSchema(this,arg)  %#ok
%GetDialogSchema Construct "explorer" dialog to display
%   hierarchy of UIMgr and HG objects.

% Copyright 2004-2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2010/05/20 03:07:44 $

treeView         = getTreeView;
treeView.RowSpan = [1 1];
treeView.ColSpan = [1 1];

% Compute details of selected tree node
details         = getDetails(this);
details.RowSpan = [2 2];
details.ColSpan = [1 1];

actionButtons         = getActionButtons(this);
actionButtons.RowSpan = [3 3];
actionButtons.ColSpan = [1 1];

% Final dialog
%
dlgstruct.RowStretch  = [1 0 0];
dlgstruct.ColStretch  = 1;
dlgstruct.LayoutGrid  = [3 1];
dlgstruct.Items       = {treeView,details,actionButtons}; %cellAddrFmt, opt
dlgstruct.DisplayIcon = fullfile('toolbox','shared','dastudio','resources','MatlabIcon.png');
dlgstruct.DialogTitle = 'Extension Manager Explorer';
dlgstruct.StandaloneButtonSet = {''};

% ---------------------------------------
function treeView = getTreeView

% Get the library.  This is a singleton object so we do not need to store
% its handle in the explorer.
hLibrary = extmgr.RegisterLib;

% Tree viewer
% Use the '%dialog' flag to get the dialog handle instead of relying the
% stored handle in the 'Dialog' property.  This is done so that 
treeView.Name          = 'Select item in hierarchy';  % summary info
treeView.Type          = 'tree';
treeView.Tag           = 'treeView';
treeView.TreeItems     = getTreeNode(hLibrary);
treeView.UserData      = 'my_data';
treeView.ObjectMethod  = 'callbacks';
treeView.MethodArgs    = {'select', '%dialog'};
treeView.ArgDataTypes  = {'string', 'handle'};
treeView.Tunable       = 1;
% treeView.Value         = this.CurrentNode;
% Need Mode=1 so address is selectable (seems to be refreshing
% immediately and thus resets any selection attempt)
treeView.Mode          = 1;

% ---------------------------------------
function actionButtons = getActionButtons(this)

% Buttons and button panel
%
wblank.Type        = 'text';
wblank.Tag         = 'blank';
wblank.Name        = '';
wblank.RowSpan     = [1 2];
wblank.ColSpan     = [1 1];
wblank.MinimumSize = [100 20];

wresources.Type    = 'pushbutton';
wresources.Name    = 'Load';
wresources.Tag     = 'pushLoadResources';
wresources.RowSpan = [1 1];
wresources.ColSpan = [2 2];
wresources.ObjectMethod = 'callbacks';
wresources.MethodArgs   = {'load', '%dialog'};
wresources.ArgDataTypes = {'string', 'handle'};
wresources.Alignment    = 3;  % top right
wresources.Enabled      = false;

if isa(this.CurrentObject, 'extmgr.Register') &&  ...
        isempty(this.CurrentObject.PropertyDb) || ...
        isa(this.CurrentObject, 'extmgr.RegisterDb')
    wresources.Enabled = true;
end

wload.Type = 'pushbutton';
wload.Name = 'New';
wload.Tag  = 'pushLoad';
wload.RowSpan = [2 2];
wload.ColSpan = [2 2];
wload.ObjectMethod = 'callbacks';
wload.MethodArgs   = {'new', '%dialog'};
wload.ArgDataTypes = {'string', 'handle'};
wload.Alignment    = 3;  % top right

wrefresh.Type         = 'pushbutton';
wrefresh.Name         = 'Refresh';
wrefresh.Tag          = 'pushRefresh';
wrefresh.RowSpan      = [1 1];
wrefresh.ColSpan      = [3 3];
wrefresh.ObjectMethod = 'callbacks';
wrefresh.MethodArgs   = {'refresh', '%dialog'};
wrefresh.ArgDataTypes = {'string', 'handle'};
wrefresh.Alignment    = 3;  % top right

wclose.Type         = 'pushbutton';
wclose.Name         = 'Close';
wclose.Tag          = 'pushClose';
wclose.RowSpan      = [2 2];
wclose.ColSpan      = [3 3];
wclose.ObjectMethod = 'callbacks';
wclose.MethodArgs   = {'close', '%dialog'};
wclose.ArgDataTypes = {'string', 'handle'};
wclose.Alignment    = 3;  % top right

actionButtons.Type       = 'panel';
actionButtons.Name       = 'buttonPanel';
actionButtons.Tag        = 'buttonpanel';
actionButtons.LayoutGrid = [2 3];  % define space for children
actionButtons.Items      = {wblank, wresources, wload, wrefresh, wclose};
actionButtons.RowStretch = [0 1];
actionButtons.ColStretch = [1 0 0]; % only the space can grow horiz

% ---------------------------------------
function grp = getDetails(this)
%GetDetails Construct details portion of dialog

% Get the handle to the current object to populate the details.
[hNode] = get(this,'CurrentObject');
if isempty(hNode)
    hNode = hLibrary;
end

nodeInfo = getNodeInfo(hNode);

allW = cell(1, 16);  % all widgets for this group

for indx=1:size(nodeInfo.Widgets,1)
    [allW{2*indx-1:2*indx}] = getInfoPair(nodeInfo.Widgets{indx, 1}, ...
        nodeInfo.Widgets{indx, 2}, indx);
end

for indx = size(nodeInfo.Widgets,1)+1:8
    [allW{2*indx-1:2*indx}] = getInfoPair('', '', indx);
end

% Construct Group widget
%
grp.Tag = 'details';
grp.Type = 'group';
grp.Name = 'Details'; %groupName;
grp.Items = allW;  % all widgets
grp.LayoutGrid = [8 2]; % internal to group
grp.RowStretch = [0 0 0 0 0 0 0 1];
grp.ColStretch = [0 1];

% -------------------------------------------------------------------------
function [label value] = getInfoPair(nameStr, valueStr, row)

% Construct text widgets for next description and key
% Store interleaved widgets,
%  [description1, key1, description2, key2, ...]

% Note: if property "Name" string is empty (i.e., this entry
%   is just being used for display padding), suppress the
%   colon - this looks nicer.
%

if isempty(nameStr)
    sepStr = '';
    vis    = 0;
else
    sepStr = ':';
    vis    = true;
end

label.Type      = 'text';
label.Tag       = sprintf('Name%d', row);
label.Name      = [nameStr sepStr];
% label.Alignment = 6;
label.Bold      = 1;
label.RowSpan   = [row row];
label.ColSpan   = [1 1];
label.Visible   = vis;

value.Type      = 'text';
value.Tag       = sprintf('Value%d', row);
value.Name      = valueStr;
% value.Alignment = 4;
value.Bold      = 0;
value.RowSpan   = [row row];
value.ColSpan   = [2 2];
value.Visible   = vis;

% [EOF]
