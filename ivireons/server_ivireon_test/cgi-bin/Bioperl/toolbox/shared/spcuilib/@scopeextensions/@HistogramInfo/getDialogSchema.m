function dlgStruct = getDialogSchema(this,arg) %#ok
% GETDIALOGSCHEMA Construct the dialog to display histogram information.

%   Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $   $ Date: $
        
dlgStruct.DialogTitle = '';
dlgStruct.Items = {};


group.Title = 'Data Information';
group.Widgets = getAllWidgets(this);

% Create DDG groups from the collected widgets.
%

Ngroups = numel(group);
DDG_Group = cell(1, Ngroups);
for i=1:Ngroups
    DDG_Group{i} = DDG2ColText(group(i).Title, ...
        group(i).Widgets, i);
end

grp.Type = 'panel';
grp.Tag = 'DataInfoPanel';
grp.LayoutGrid = [Ngroups 1];
grp.Items = DDG_Group;


dlgStruct = this.StdDlgProps;
dlgStruct.ExplicitShow = false;
dlgStruct.DialogTitle = DAStudio.message('Spcuilib:scopes:titleHistogramInfoDlg');
dlgStruct.Items = {grp};
dlgStruct.DialogTag = 'DataInformation';
dlgStruct.StandaloneButtonSet = {'OK'};


%----------------------------------------------
function widgets = getAllWidgets(this)

widgets = {...
    'Variable name', this.SourceLocation; ...
    'Current data type',this.DataType;...
    'Minimum value', this.Min;...
    'Maximum value',this.Max;...
    'Minimum non-zero absolute value',this.AbsMin;...
    'Mean',this.Mean;...
    'Standard deviation',this.StdDev;...
    'Percent of zeros',this.NumZeros;...
    'Percent of overflows',this.PercentOverflw;...
    'Percent of underflows',this.PercentUnderflw;...
    'Number of samples',this.NumSamples...
          };

%--------------------------------------------------------
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
grp.Tag = 'DataInfoGroupBox';
grp.Type = 'group';
grp.Name = groupName;
grp.Items = allW;  % all widgets
grp.LayoutGrid = [numEntries+1 2]; % internal to group
grp.RowStretch = [zeros(1, numEntries) 1];
grp.ColStretch = [1 1];
grp.RowSpan = [grpIdx grpIdx];   % external for parent
grp.ColSpan = [1 1];

%-----------------------------------------------
