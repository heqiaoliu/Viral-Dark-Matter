function dlgstruct = getDialogSchema(hExpl,arg) %#ok
%GetDialogSchema Construct "explorer" dialog to display
%   hierarchy of UIMgr and HG objects.

% Copyright 2004-2010 The MathWorks, Inc.
% $Revision: 1.1.6.8 $ $Date: 2010/05/20 03:08:16 $

% Recompute tree info
% Create tree nodes for display
[items,treeType] = getTreeNames(hExpl);
% Get full path string ('top/next/node')
% NOTE: could be an empty string if NO selection is made!
pNode = hExpl.dialogSelection;
% Find handle to uiitem or uigroup, and a string argument
% that creates a cell-array for the address (for user's convenience)
[hNode,cellAddr] = getChildFromPath(hExpl,pNode);
if isempty(hNode)
    hNode = hExpl.hItem;
end

% Show tree
if isempty(items)
    % No profile info
    tree.Type = 'editarea';
    tree.Enabled = false;
    tree.Value = '(Nothing to display.)';
    tree.Tag = 'tree';
    tree.RowSpan = [1 1];
    tree.ColSpan = [1 1];
else
    % Tree viewer
    %
    tree.Name          = 'Select item in hierarchy';  % summary info
    tree.Type          = 'tree';
    tree.Tag           = 'tree';
    tree.TreeItems     = items;
    tree.UserData      = 'my_data';
    tree.ObjectMethod  = 'handleButtons';
    tree.MethodArgs    = {'Select'};
    tree.ArgDataTypes  = {'string'};
    tree.Tunable       = 1;
    tree.RowSpan       = [1 1];
    tree.ColSpan       = [1 1];
    % Need Mode=1 so address is selectable (seems to be refreshing
    % immediately and thus resets any selection attempt)
    tree.Mode          = 1;
    % no need for this - dialog is explicitly refreshed
    % tree.DialogRefresh = true;
end

% Display the address of the selected item,
% using MATLAB syntax for a cell-array of strings
cellAddrFmt.Type = 'edit';
cellAddrFmt.Tag  = 'Address';
cellAddrFmt.ToolTip = sprintf('Copy for use with findchild, sync,\nand other methods requiring a text address.');
cellAddrFmt.Name = 'Address:';
cellAddrFmt.Value = cellAddr;
cellAddrFmt.RowSpan = [2 2];
cellAddrFmt.ColSpan = [1 1];
% Set these two to help combat accidental edits to the edit box
% by the user.  Setting these causes the text to update (back to
% what it used to be!) when a change is made.
cellAddrFmt.Mode = 1;
cellAddrFmt.DialogRefresh = 1;

% Compute details of selected tree node
details = getDetails(hNode);
details.RowSpan = [1 1];
details.ColSpan = [1 1];

% Options panel
opt.Type = 'togglepanel';
opt.Name = 'Selection details';
opt.LayoutGrid = [1 1];
opt.RowSpan = [3 3];
opt.ColSpan = [1 1];
opt.Items = {details};

% Buttons and button panel
%
wblank.Type           = 'text';
wblank.Name           = '';
wblank.RowSpan        = [1 1];
wblank.ColSpan        = [1 1];
wblank.MinimumSize     = [100 42];  % [w h]
wblank.Alignment      = 3;  % top right

wrefresh.Type           = 'pushbutton';
wrefresh.Name           = 'Refresh';
wrefresh.Tag            = 'pushRefresh';
wrefresh.RowSpan        = [1 1];
wrefresh.ColSpan        = [2 2];
wrefresh.ObjectMethod   = 'handleButtons';
wrefresh.MethodArgs     = {'Refresh'};
wrefresh.ArgDataTypes   = {'string'};
wrefresh.Alignment      = 3;  % top right

wclose.Type           = 'pushbutton';
wclose.Name           = 'Close';
wclose.Tag            = 'pushClose';
wclose.RowSpan        = [1 1];
wclose.ColSpan        = [3 3];
wclose.ObjectMethod   = 'handleButtons';
wclose.MethodArgs     = {'Close'};
wclose.ArgDataTypes   = {'string'};
wclose.Alignment      = 3;  % top right

wbuttonpanel.Type      = 'panel';
wbuttonpanel.Name      = 'buttonPanel';
wbuttonpanel.Tag       = 'buttonpanel';
wbuttonpanel.LayoutGrid= [1 3];  % define space for children
wbuttonpanel.RowSpan   = [4 4];  % relative to parent
wbuttonpanel.ColSpan   = [1 1];  % relative to parent
wbuttonpanel.Items     = {wblank, wrefresh, wclose};
wbuttonpanel.RowStretch = 1;
wbuttonpanel.ColStretch = [1 0 0]; % only the space can grow horiz

% Final dialog
%
dlgstruct.RowStretch = [1 0 0 0];
dlgstruct.ColStretch = 1;
dlgstruct.LayoutGrid     = [4 1];
dlgstruct.Items          = {tree,cellAddrFmt,opt,wbuttonpanel};
dlgstruct.DisplayIcon    = fullfile('toolbox','shared','dastudio','resources','MatlabIcon.png');
dlgstruct.DialogTitle    = ['Explore ' treeType ' Hierarchy'];
dlgstruct.StandaloneButtonSet = {''};

% --------------------------------------
function [s,t] = getTreeNames(h)
% Build a cell-array of nested tree nodes
% formatted for the DDG "tree" widget

if isHG(h.hItem)
    s = getTreeNames_hg(h.hItem);
    t = 'HG';
else
    s = getTreeNames_uimgr(h.hItem);
    t = 'UIMGR';
end

% --------------------------------------------------
function y = isHG(hItem)
y = ~isa(hItem,'uimgr.uiitem');

% --------------------------------------
function s = getTreeNames_hg(hParent)
% Build a cell-array of nested tree nodes
% formatted for the DDG "tree" widget
%
% Each node is just the hg widget type

s={};
hChild = hParent;
for i=1:numel(hChild)
    thisChild = hChild(i);
    % Construct node name for tree
    % Note: must be able to uniquely find this from its text string
    % And, the string must be useful to the viewer
    s{end+1} = sprintf('%d:%s', i, get(thisChild,'type')); %#ok
    
    % Flip order of children to match "creation order"
    % (HG maintains these in reverse order)
    ch = flipud(get(thisChild,'children'));
    if ~isempty(ch)
        s{end+1} = getTreeNames_hg(ch); %#ok
    end
end

% --------------------------------------
function s = getTreeNames_uimgr(hParent)
% Build a cell-array of nested tree nodes
% formatted for the DDG "tree" widget
%
% Each node is just the item/group name
%
% These entries must be able to be used as the
% hierarchical address of the uiitem or uigroup
% node ... so they should be the exact .Name
% fields of the nodes.  No changes!

s={};
hChild = hParent;
while ~isempty(hChild)
    s{end+1} = hChild.Name; %#ok
    if hChild.isGroup
        s{end+1} = getTreeNames_uimgr(hChild.down); %#ok
    end
    
    % When the current node is a figure, it has no uimgr siblings.  The
    % only tree siblings it might have are other things connected directly
    % to its parent.  In the scope case, this could be the extension
    % manager or the data connect. g455314
    if strcmpi(hChild.Type, 'uifigure')
        hChild = [];
    else
        hChild = hChild.right;  % next sibling
    end
end

% ---------------------------------------
function cAll = getDetails(this)
%GetDetails Construct details portion of dialog

% Get the datasource-specific dialog plug-in
% A vector of structs, containing fields:
%   .Title: title of next section of info section
%   .Widgets: a cell-array passed to DDG2ColText
%
%infoStruct = [GetCommonInfo(this) DetailsInfo(this)];
if isa(this,'uimgr.uiitem') || isa(this,'uimgr.uigroup')
    % uimgr
    infoStruct = GetCommonInfo_UIMGR(this);
else
    % hg
    infoStruct = GetCommonInfo_HG(this);
end

% Merge all info groups into one, contiguous group
% (Basically, ignore separate group names, unlike
%  key help which preserves group names in the dialog)
%
infoStruct = local_MergeGroups(infoStruct);
infoStruct.Title = 'Details';

% Create DDG groups from help database
%
Ngroups = numel(infoStruct);
DDG_Group = cell(1, Ngroups);  % default group
for i=1:Ngroups
    DDG_Group{1,i} = DDG2ColText(infoStruct(i).Title, ...
        infoStruct(i).Widgets, i);
end

% Collect all groups into a panel
%
cAll.Type = 'panel';
cAll.Items = DDG_Group;
cAll.LayoutGrid = [Ngroups 1];

% -----------------------------------------------------
function group = local_MergeGroups(infoStruct)
% Merge all separate groups into a single 'Video Info' group
% Ignore group names, etc

% Merge all widgets
w = {};
for i=1:numel(infoStruct)
    w = [w; infoStruct(i).Widgets]; %#ok
end
group.Title = 'UIGroup Info';
group.Widgets = w;

% -----------------------------------------------------
function common_group = GetCommonInfo_HG(this)
% Get "Common Group" of DDG help entries for UIMGR

common_group.Title = 'Common';
common_group.Widgets = { ...
    'Type',         get(this,'Type');
    'Tag',          get(this,'Tag');
    'Visible',      get(this,'Visible') };

% Provide custom information based on the HG widget
% This could be extended as needed
%
switch get(this,'type')
    case 'figure'
        ext = {'Name', get(this,'Name') };
    case 'uiflowcontainer'
        ext = {'FlowDir', get(this,'flowdir');
            'Margin',  sprintf('%d',get(this,'margin')) };
    case 'uigridcontainer'
        ext = {'GridSize', mat2str(get(this,'gridsize'));
            'Margin', sprintf('%d',get(this,'margin')) };
    case 'uimenu'
        ext = {'Label',   get(this,'label')};
    case {'uipushtool','uitoggletool'}
        % Pretty-print the dimensions of CData
        % Be sure to remove trailing "x" from sz when used
        sz = sprintf('%dx', size(get(this,'cdata')) );
        ext = {'Tooltip', get(this,'tooltip');
            'CData',   sz(1:end-1)};
    case 'image'
        % Pretty-print the dimensions of CData
        % Be sure to remove trailing "x" from sz when used
        sz = sprintf('%dx', size(get(this,'cdata')) );
        ext = {'CData',   sz(1:end-1)};
    case 'text'
        ext = {'String',  get(this,'string')};
    case 'uicontrol'
        ext = {'Style',   get(this,'style');
            'Tooltip', get(this,'tooltip') };
    otherwise
        ext = {'',''};
end

%  Must maintain same number of rows,
%  or the dialog will close-up the treeview
MaxRows = 2;  % hard-code this to maximum # rows in any "ext" cell
ExtRows = size(ext,1);
PadRows = MaxRows-ExtRows;
if PadRows ~= 0
    if PadRows < 0
        error(generatemsgid('Assert'),...
            'ASSERT: Increase MaxRows in uiexplorer to %d', ExtRows);
    end
    ext = [ext; repmat({'',''},PadRows,1)];
end

% Group it all together:
common_group.Widgets = [common_group.Widgets ; ext];

% -----------------------------------------------------
function common_group = GetCommonInfo_UIMGR(this)
% Get "Common Group" of DDG help entries for UIMGR

% Widget
if isempty(this.WidgetFcn)
    has_widget = 'no';
else
    if isempty(this.hWidget) || ~uimgr.isHandle(this.hWidget)  % isempty is handled here implicitly
        has_widget='yes (unrendered)';
    else
        has_widget='yes (rendered)';
    end
end

% Sync
if isempty(this.SyncList)
    % uses lazy instantiation
    sync = '';  % no object implies no sync
else
    sync = '';
    hSync = this.SyncList;
    N = numel(hSync.Fcn);
    if N>0
        for i=1:N
            sync = [sync hSync.DstName{i}]; %#ok
            if i<N, sync = [sync ',']; end %#ok
        end
        if N>1
            sync = sprintf('[%s]',sync);
        end
    end
end

% SelectionConstraint
if this.isGroup
    sc = this.SelectionConstraint;
else
    sc = '';
end

% placement string
pStr = num2str(this.ActualPlacement);
if this.AutoPlacement
    pType = ' (auto)';
else
    pType = ' (manual)';
end
pStr = [pStr pType];

% Separator, Visible, Enable states
SepVisEna = sprintf('%s/%s/%s', ...
    this.Separator, this.Visible, this.Enable);

common_group.Title = 'Common';
if (isa(this.up, 'uimgr.uiitem') )
common_group.Widgets = { ...
    'Name',      sprintf('%s', this.Name); ...
    'Class',        class(this); ...
    'Widget',       has_widget; ...
    'Placement',    pStr; ...
    'Sep/Vis/Ena',  SepVisEna; ...
    'SyncList',     sync; ...
    'Constraint',   sc; ...
    'StateProp',    this.StateName; ...
    'isFirstPlace', mat2str(this.isFirstPlace); ...
    'myParent',     sprintf('%s', this.up.Name);
    };
else
common_group.Widgets = { ...
    'Name',      sprintf('%s', this.Name); ...
    'Class',        class(this); ...
    'Widget',       has_widget; ...
    'Placement',    pStr; ...
    'Sep/Vis/Ena',  SepVisEna; ...
    'SyncList',     sync; ...
    'Constraint',   sc; ...
    'StateProp',    this.StateName; ...
    'isFirstPlace', mat2str(this.isFirstPlace); ...
    'myParent',     'I have no parent';
    };
end

% ---------------------------------------------------
function grp = DDG2ColText(groupName, entries, grpIdx)
%DDG2ColText Create a 2-column group of text widgets.
%   Creates a DDG group of text widgets in a 2-column
%   format.
%
%  groupName: visible name of the group widget
%  entries: Nx2 cell-array of strings to render
%           using text widgets in a 2-column format
%  grpIdx: row-coordinate to assign to group

% Construct individual text widgets for
% each key binding and description
%
numEntries = size(entries,1); % # Rows
allW=cell(1, 2*numEntries);  % all widgets for this group
for i=1:numEntries
    % Construct text widgets for next description and key
    % Store interleaved widgets,
    %  [description1, key1, description2, key2, ...]
    
    % Note: if property "Name" string is empty (i.e., this entry
    %   is just being used for display padding), suppress the
    %   colon - this looks nicer.
    %
    if isempty(entries{i,1})
        sepStr = '';
    else
        sepStr = ':';
    end
    
    % Name
    w.Type    = 'text';
    w.Name    = [entries{i,1} sepStr];
    w.Alignment = 6;  % 4: ctr right, 6: ctr left
    w.Bold    = 1;
    w.RowSpan = [i i];
    w.ColSpan = [1 1];
    allW{2*i-1} = w;
    
    % Value
    w.Type    = 'text';
    w.Name    = ['  ' entries{i,2}];
    w.Alignment = 4;
    w.Bold = 0;
    w.RowSpan = [i i];
    w.ColSpan = [2 2];
    allW{2*i} = w;
end

% Construct Group widget
%
grp.Type = 'group';
grp.Name = groupName;
grp.Items = allW;  % all widgets
grp.LayoutGrid = [numEntries 2]; % internal to group
grp.RowSpan = [grpIdx grpIdx];   % external for parent
grp.ColSpan = [1 1];

% -------------------------------------------------------
function [hChild,cellStr] = getChildFromPath(hExpl,treeNodeStr)
%getChildFromPath
%
% Take in concatenated node string of the form:
%     treeNodeStr = 'top/child/subchild/node'
% Parse using '/' as a delimiter to extract address hierarchy
% Return child handle obtained from hierarchical address
%
this = hExpl.hItem;

if isempty(treeNodeStr)
    hChild = [];
    %cellStr = '{}';
    cellStr = getChildFromCellStr('');  % depends on formatting
else
    if isHG(hExpl.hItem)
        % HG: get explicit hierarchical indices
        % go from '1:figure/1:uiflowcontainer/2:axes'
        %  ... to {'1:figure','1:uiflowcontainer','2:axes'}
        r = textscan(treeNodeStr,'%s','delimiter','/');
        r = r{1};
        %  ... to v=[1 1 2]
        for i=1:numel(r)
            v(i)=sscanf(r{i},'%d'); %#ok
        end
        cellStr = mat2str(v);
        hChild = findchild_hg(this,v);
    else
        % UIMGR: unique strings for child names
        r = textscan(treeNodeStr,'%s','delimiter','/');
        % pop out of scalar cell as returned by textscan,
        % leaving a standard cellstring of the hierarchy names
        r = r{1};
        cellStr = getChildFromCellStr(r);
        % Find uimgr child entry
        % Get handle associated with this address
        %
        % Remove first entry from r, since the handle (this)
        % is already from that address location
        N=numel(r);
        if N<2
            hChild = [];
        else
            hChild = this.findchild(r{2:end});
        end
    end
end

% -------------------------------------------------------
function hChild = findchild_hg(this,v)
% Find hierarchical child defined by vector of indices, V
% Each entry v(i) indicates the v(i)'th child
% First entry v(1) indicates the element of "this" itself
%   (i.e., v(1) doesn't describe a child)
hChild = this;
if isempty(v), return; end
hChild=hChild(v(1));
v=v(2:end);
while ~isempty(v)
    % Flip order of children to match "creation order"
    % (HG maintains these in reverse order)
    hChild=flipud(get(hChild,'children'));
    hChild=hChild(v(1));
    v=v(2:end);
end

% -------------------------------------------------------
function cellStr = getChildFromCellStr(r)
% Can return either of two formatted strings:
%  1) a cell-array of strings, '{''one'',''two''}'
%  2) a delimited string, 'one/two'

childNameStyle = 1;
if childNameStyle==1
    cellStr = getChildFromCellStr_path(r);
else
    cellStr = getChildFromCellStr_address(r);
end

% -------------------------------------------------------
function p = getChildFromCellStr_path(r)
% Construct path string corresponding to address
% for the user's convenience (can copy this for an application)
% Example address: 'top/child/node'
% Example path: (same)

if isempty(r)
    p = '''''';
else
    p = sprintf('%s/',r{:});
    if isempty(p)
        % could be empty if r had no '/' in it
        p='''''';
    else
        % Remove trailing slash, embed in apostrophes
        p=['''' p(1:end-1) ''''];
    end
end

% -------------------------------------------------------
function cellStr = getChildFromCellStr_address(r)

% Construct cell-array of strings corresponding to address
% for the user's convenience (can copy this for an application)
% Example address: 'top/child/node'
% Example cell-array arg: '{''top'',''child'',''node''}'
%
% NOTE: We skip the first name in the address.  Since the user
%   has the handle to the hierarchy (by definition! they pass it in!)
%   they do not need to "find" it, and the first name in the address
%   is redundant.  In fact, if we return it and the user copies it,
%   it will NOT work with h.findchild() (assuming h is the same handle).

N=numel(r);
cellStr = '{';
for i=2:N % skip the name of the top-level node
    cellStr=[cellStr '''' r{i} '''']; %#ok
    if i<N
        cellStr=[cellStr ',']; %#ok
    end
end
cellStr = [cellStr '}'];

% [EOF]
