function dlgstruct = getDialogSchema(hKeyMgr,arg) %#ok
%GetDialogSchema Construct KeyMgr help dialog.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2009/05/23 08:12:29 $

% Get the key manager help dialog text
% Concatenates all child KeyGroup help descriptions into a vector
% of structures, converting Help to structs as it operates.
%
% Each struct contains the fields:
%   .Title: title of next section of key help
%   .Mapping: a cell-array passed to DDG2ColText
%          {'key1', 'description1'; ...
%           'key2', 'description2'; }
%   Column 1 is the name of the key (keys)
%   Column 2 is a brief description of the action take for the
%      corresponding key (keys)
%   Ex:
%      s.'Title' = 'Navigation commands';
%      s.Mapping = ...
%          {'n',  'Go to next entry'; ...
%           'p',  'Go to previous entry'};
%

helpStruct = getHelpStruct(hKeyMgr);

% Merge keyboard button groups that have identical 'Title' strings,
% as if they were part of the same group of definitions.  That gives
% plug-in's a way to extend the key help for "existing" groups.
%
helpStruct = mergeCommonGroups(helpStruct);

% Sort help alphabetically by title
%
helpStruct = sortGroupTitles(helpStruct);

Ngroups = numel(helpStruct);
if Ngroups == 0
    % No help text specified
    helpStruct.Title = '';
    helpStruct.Mapping = {'','No key commands are defined.'};
    Ngroups = 1;
end

% Create DDG groups from help database
%
overallEnable = strcmpi(hKeyMgr.Enabled,'on');
DDG_Group = cell(1, Ngroups);  % default group
for i=1:Ngroups
    DDG_Group{1,i} = DDG2ColText(helpStruct(i).Title, ...
        helpStruct(i).Mapping, i, overallEnable);
end

% add spacer for g381027
spacer.Type = 'panel';
spacer.RowSpan = [Ngroups+1, Ngroups+1];
spacer.ColSpan = [1,1];

% Collect all groups into a panel
%
cAll.Type = 'panel';
cAll.Items = [DDG_Group,spacer];
cAll.LayoutGrid = [Ngroups+1 1];

% Return top-level DDG dialog structure
%
dlgstruct                     = hKeyMgr.StdDlgProps;
dlgstruct.Items               = {cAll};
dlgstruct.StandaloneButtonSet = {'OK'};
dlgstruct.DialogTag           = 'KeyboardCommandHelp';
end

%%
function grp = DDG2ColText(groupName, entries, grpIdx, overallEnable)
%DDG2ColText Create a 2-column group of text widgets.
%   Creates a DDG group of text widgets in a 2-column
%   format.
%
%  groupName: visible name of the group widget
%  entries: Nx3 cell-array, [col1, col2, ena], containing two columns
%           to render using text widgets in a 2-column format
%  grpIdx: row-coordinate to assign to group

% Construct individual text widgets for
% each key binding and description
%
numEntries = size(entries,1); % # Rows
allW = cell(1, 2*numEntries);  % all widgets for this group
for indx=1:numEntries
    % Construct text widgets for next description and key
    % Store interleaved widgets,
    %  [description1, key1, description2, key2, ...]
    %
    
    % Control enable state of the text based on whether the key binding
    % is enabled or disabled and on whether the key binding is visible or
    % invisible
    itemEnabled  = entries{indx,3};
    itemVisibility = entries{indx, 4};
    if ~itemVisibility
        itemEnabled = 0;
    end
        
    ena = overallEnable && itemEnabled; 
    
    % Description
    w.Type    = 'text';
    w.Name    = entries{indx,2};  % description
    w.Tag     = entries{indx,2};
    w.RowSpan = [indx indx];
    w.ColSpan = [1 1];
    %w.RowStretch = [0];
    w.Enabled = ena;
    w.Visible = itemVisibility;
    allW{2*indx-1} = w;

    % Key
    w.Type    = 'text';
    w.Name    = entries{indx,1};  % key
    w.Tag     = entries{indx,1};
    w.RowSpan = [indx indx];
   % w.RowStretch = [0];
    w.ColSpan = [2 2];
    w.Enabled = ena;
    w.Visible = itemVisibility;
    allW{2*indx} = w;
end
%spacer.Type = 'panel';
% Construct Group widget
%
grp.Type = 'group';
grp.Name = groupName;
grp.Tag = groupName;
%grp.Items = [allW, spacer];  % all widgets
grp.Items = allW;
grp.LayoutGrid = [numEntries 2]; % internal to group
grp.RowSpan = [grpIdx grpIdx];   % external for parent
grp.ColSpan = [1 1];

end

%%
function helpStruct = mergeCommonGroups(helpStruct)
%mergeCommonGroups Merge help descriptions according to Title names.
%
% Note that help text is assembled as a vector of structs,
% each struct containing the fields:
%   .Title: title of next section of key help
%   .Mapping: a cell-array passed to DDG2ColText
%          {'key1', 'description1'; ...
%           'key2', 'description2'; }
%   Column 1 is the name of the key (keys)
%   Column 2 is a brief description of the action take for the
%      corresponding key (keys)
%   Ex:
%      s.'Title' = 'Navigation commands';
%      s.Mapping = ...
%          {'n',  'Go to next entry'; ...
%           'p',  'Go to previous entry'};
%
%  We identify identical Title strings and merge these groups
%  in the order found.

if ~isempty(helpStruct)
    % See if there are common title strings
    %
    % Get all titles and unique titles, then compare:
    allTitles = {helpStruct.Title};
    uniqueTitles = unique(allTitles);
    Nu = numel(uniqueTitles);
    Na = numel(allTitles);
    if Nu < Na
        % Merge of groups is required
        %   (that is, at least one Title is a duplicate)
        %
        % Loop over all unique group names and merge these
        % groups with duplicate Titles
        for i=1:Nu
            thisTitle = uniqueTitles{i};  % next unique title
            allTitles = {helpStruct.Title}; % can change each time
            titleIdx = strmatch(thisTitle,allTitles,'exact');
            Nt = numel(titleIdx); % multiple groups with the same title?
            if Nt>1               % only merge if more than one in common
                % Loop over all groups with common Titles, and
                % merge them into the first such group found:
                wi = helpStruct(titleIdx(1)).Mapping;  % 1st group
                for j=2:numel(titleIdx)
                    wj = helpStruct(titleIdx(j)).Mapping; % next group in set
                    wi = [wi; wj];                        %#ok merge contents
                end
                % Write the merged list back to the first group
                helpStruct(titleIdx(1)).Mapping = wi;
                % Delete the merged entries
                helpStruct(titleIdx(2:end))=[];
            end
        end
    end
end

end

%%
function helpStruct = sortGroupTitles(helpStruct)
%sortGroupTitles Sort render-ordering of help groups by title.

if ~isempty(helpStruct)
    % Collect .Title of each help entry, and sort in ascending order
    helpStruct = helpStruct(:);         % make it a column
    [~,idx] = sort({helpStruct.Title}); % sort down column
    helpStruct = helpStruct(idx);
end

end

% [EOF]
