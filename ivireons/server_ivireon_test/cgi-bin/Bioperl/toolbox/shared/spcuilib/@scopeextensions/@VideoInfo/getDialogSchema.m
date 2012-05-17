function dlgstruct = getDialogSchema(this,arg)  %#ok
%GetDialogSchema Construct VideoInfo dialog

% Copyright 2004-2010 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2010/03/31 18:43:09 $

% Get the datasource-specific dialog plug-in
% A vector of structs, containing fields:
%   .Title: title of next section of info section
%   .Widgets: a cell-array passed to DDG2ColText
%
infoStruct = [GetCommonInfo(this) this.playbackInfo];

% Merge all info groups into one, contiguous group
% (Basically, ignore separate group names, unlike
%  key help which preserves group names in the dialog)
%
infoStruct = local_MergeGroups(infoStruct);

% Create DDG groups from help database
%
Ngroups = numel(infoStruct);
DDG_Group = cell(1, Ngroups);
for i=1:Ngroups
    DDG_Group{i} = DDG2ColText(infoStruct(i).Title, ...
        infoStruct(i).Widgets, i);
end

% Collect all groups into a panel
%
cAll.Tag = 'VideoInfoPanel';
cAll.Type = 'panel';
cAll.Items = DDG_Group;
cAll.LayoutGrid = [Ngroups 1];

% Return top-level DDG dialog structure
%
dlgstruct = this.StdDlgProps;
dlgstruct.ExplicitShow = false;
dlgstruct.DialogTitle = this.TitlePrefix;
dlgstruct.Items = {cAll};
dlgstruct.StandaloneButtonSet = {'OK'};
dlgstruct.DialogTag      = 'VideoInfo';

% -----------------------------------------------------
function group = local_MergeGroups(infoStruct)
% Merge all separate groups into a single 'Video Info' group
% Ignore group names, etc

% Merge all widgets
w = {};
for i=1:numel(infoStruct)
    w = [w; infoStruct(i).Widgets]; %#ok
end
group.Title = 'Video Info';
group.Widgets = w;

% -----------------------------------------------------
function common_group = GetCommonInfo(this)
% Get "Common Group" of DDG help entries

common_group.Title = 'Common';
if strcmp(this.sourceType, 'Streaming') 
  common_group.Widgets = { ...
    'Frame size',   this.ImageSize; ...
    'Color format', this.ColorSpace; ...
    'Source data type',  this.DataType; ...
    'Display data type', this.DisplayDataType};
else
  common_group.Widgets = { ...
    'Source type',  this.SourceType; ...
    'Source name',  this.SourceLocation; ...
    'Frame size',   this.ImageSize; ...
    'Color format', this.ColorSpace; ...
    'Source data type',  this.DataType; ...
    'Display data type', this.DisplayDataType};
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
allW = cell(1, 2*numEntries);  % all widgets for this group
for indx = 1:numEntries
    % Construct text widgets for next description and key
    % Store interleaved widgets,
    %  [description1, key1, description2, key2, ...]
    %
    % Name
    w.Type    = 'text';
    w.Tag     = strrep(entries{indx,1}, ' ', '');
    w.Name    = [entries{indx,1} ':'];
    w.Alignment = 5;  % 4: ctr right, 6: ctr left
    w.Bold    = 0;
    w.RowSpan = [indx indx];
    w.ColSpan = [1 1];
    allW{2*indx-1} = w;
    
    % Value
    w.Type    = 'text';
    w.Tag     = [w.Tag 'Value'];
    w.Name    = ['  ' entries{indx,2}];
    w.Alignment = 5;
    w.Bold = 0;
    w.RowSpan = [indx indx];
    w.ColSpan = [2 2];
    allW{2*indx} = w;
end

% Construct Group widget
%
grp.Tag = 'VideoInfoGroupBox';
grp.Type = 'group';
grp.Name = groupName;
grp.Items = allW;  % all widgets
grp.LayoutGrid = [numEntries+1 2]; % internal to group
grp.RowStretch = [zeros(1, numEntries) 1];
grp.ColStretch = [1 1];
grp.RowSpan = [grpIdx grpIdx];   % external for parent
grp.ColSpan = [1 1];

% [EOF]
