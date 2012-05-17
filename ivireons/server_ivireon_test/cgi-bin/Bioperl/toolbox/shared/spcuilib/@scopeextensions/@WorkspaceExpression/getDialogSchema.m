function dlgstruct = getDialogSchema(this,arg) %#ok
%GetDialogSchema Construct "Import from workspace" dialog.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2009/09/09 21:29:41 $

wvar.Type           = 'edit';
wvar.Name           = 'MATLAB variable or expression:';
wvar.Tag            = 'mlvar';
wvar.ObjectProperty = 'mlvar';
wvar.RowSpan        = [1 1];
wvar.ColSpan        = [1 2];
%wvar.Value          = 1;
wvar.Mode           = false;

wvarpanel.Type      = 'panel';
wvarpanel.Name      = 'varPanel';
wvarpanel.Tag       = 'varpanel';
wvarpanel.LayoutGrid= [1 3];  % define space for children
wvarpanel.RowSpan   = [1 1];  % relative to parent
wvarpanel.ColSpan   = [1 1];  % relative to parent
wvarpanel.Items     = {wvar};
wvarpanel.RowStretch = 1;
wvarpanel.ColStretch = [.75 0 .25]; % only the 'space' can grow horiz


% Table of base workspace variables
%
% Get formatted header and table of variables
[hdr,tbl,ws_names] = getFormattedWhos;

% Make header as width as widest table entry plus a few more chars
% (this guarantees the initial sizing of the dialog is sufficient,
%  and prevents a horiz-scrollbar for the table)
Nhdr = numel(hdr);
maxWidth = 4+max(cellfun(@numel,tbl));
if Nhdr < maxWidth
    hdr=[hdr repmat(' ',1,maxWidth-Nhdr)];
end

% Setup variable table
wtable.Tag         = 'WorkspaceVars';
wtable.Name        = hdr;
wtable.Type        = 'listbox';
wtable.Graphical   = true; % prevents table from turning "yellow" when a row is clicked
wtable.MultiSelect = false;
wtable.FontFamily  = 'Courier';
wtable.RowSpan     = [2 2];
wtable.ColSpan     = [1 1];
wtable.Entries     = getFormattedTableEntries(tbl);
wtable.UserData    = ws_names;
wtable.ObjectMethod  = 'handleButtons';
wtable.MethodArgs    = {'ListBox'};
wtable.ArgDataTypes  = {'string'};
wtable.Value         = []; % de-select all rows
wtable.Mode        = 1;
wtable.Tunable     = 1;
% Remap the double-click callback to look like
% the "Import" button was pressed:
wtable.ListDoubleClickCallback = @(hDlg,tag,idx)handleButtons(this,'Import');

% Buttons and button panel
%
wblank.Type           = 'text';
wblank.Name           = '';
wblank.RowSpan        = [1 1];
wblank.ColSpan        = [1 1];
wblank.MinimumSize     = [100 42];  % [w h]
wblank.Alignment      = 3;  % top right

wimport.Type           = 'pushbutton';
wimport.Name           = 'Import';
wimport.Tag            = 'pushImport';
wimport.RowSpan        = [1 1];
wimport.ColSpan        = [2 2];
wimport.ObjectMethod   = 'handleButtons';
wimport.MethodArgs     = {'Import'};
wimport.ArgDataTypes   = {'string'};
%wimport.MinimumSize    = [0 0];  % [w h]
wimport.Alignment      = 3;  % top right

wrefresh.Type           = 'pushbutton';
wrefresh.Name           = 'Refresh';
wrefresh.Tag            = 'pushRefresh';
wrefresh.RowSpan        = [1 1];
wrefresh.ColSpan        = [3 3];
wrefresh.ObjectMethod   = 'handleButtons';
wrefresh.MethodArgs     = {'Refresh'};
wrefresh.ArgDataTypes   = {'string'};
wrefresh.Alignment      = 3;  % top right

wcancel.Type           = 'pushbutton';
wcancel.Name           = 'Cancel';
wcancel.Tag            = 'pushCancel';
wcancel.RowSpan        = [1 1];
wcancel.ColSpan        = [4 4];
wcancel.ObjectMethod   = 'handleButtons';
wcancel.MethodArgs     = {'Cancel'};
wcancel.ArgDataTypes   = {'string'};
wcancel.Alignment      = 3;  % top right

wbuttonpanel.Type      = 'panel';
wbuttonpanel.Name      = 'buttonPanel';
wbuttonpanel.Tag       = 'buttonpanel';
wbuttonpanel.LayoutGrid= [1 4];  % define space for children
wbuttonpanel.RowSpan   = [4 4];  % relative to parent
wbuttonpanel.ColSpan   = [1 1];  % relative to parent
wbuttonpanel.Items     = {wblank, wimport, wrefresh, wcancel};
%wbuttonpanel.Items     = {wimport, wrefresh, wcancel};
wbuttonpanel.RowStretch = 1;
wbuttonpanel.ColStretch = [1 0 0 0]; % only the space can grow horiz

%(g347374) add extra row to prevent buttons get cutoff with large fonts 
wspace.Type           = 'text';
wspace.Name           = '';
wspace.RowSpan        = [1 1];
wspace.ColSpan        = [1 1];
wspace.MinimumSize     = [0 12];  % [w h]
wspace.Alignment      = 3;  % top right

blankpanel.Type      = 'panel';
blankpanel.Name      = 'buttonPanel';
blankpanel.Tag       = 'buttonpanel';
blankpanel.LayoutGrid= [1 4];  % define space for children
blankpanel.RowSpan   = [5 5];  % relative to parent
blankpanel.ColSpan   = [1 1];  % relative to parent
blankpanel.Items     = {wspace};
%blankpanel.Items     = {wimport, wrefresh, wcancel};
blankpanel.RowStretch = 0;
blankpanel.ColStretch = [1 0 0 0]; 
% ----------------------------------------------
% Return main dialog structure
% ----------------------------------------------
%
dlgstruct = this.StdDlgProps;
dlgstruct.LayoutGrid     = [4 1];
dlgstruct.RowStretch     = [0 1 0 0];
dlgstruct.ColStretch     = 1;
dlgstruct.Items          = {wvarpanel, wtable, wbuttonpanel, blankpanel};
dlgstruct.DialogTag      = 'ImportFromWorkspace';
dlgstruct.CloseMethod         = 'handleButtons';
dlgstruct.CloseMethodArgs     = {'Cancel'};
dlgstruct.CloseMethodArgsDT   = {'string'};
dlgstruct.StandaloneButtonSet = {''};

% ----------------------------------
function [hdr,tbl,ws_names] = getFormattedWhos
% Table content for each variable in workspace
% hdr: string header for 1st line of table
% tbl: cell-array of strings, one string per variable
%      {'line 1', 'line 2', 'line 3', ...};

% Call whos, and capture formatted output
s=evalin('base','evalc(''whos'')');
v=evalin('base','whos');
% Cache variable names
ws_names = {v.name};
% Parse into individual lines
[~,~,~,ws] = regexp(s,'[^\n]*');
N = numel(ws);
if N>0
    % Get 1st line as header
    %  add a 1st space in order to better align "header" with "table content"
    hdr = [' ' ws{1}];
    % Skip last line ("grand total" summary)
    tbl = ws(2:end);
else
    % No variables
    hdr = '<Workspace is empty>';
    % hdr = '';
    tbl = {};
end

function tbl = getFormattedTableEntries(tableEntries)
tbl = tableEntries;
if ~isempty(tableEntries)
    tbl = strcat(tableEntries,'&nbsp;');
end

% [EOF]
