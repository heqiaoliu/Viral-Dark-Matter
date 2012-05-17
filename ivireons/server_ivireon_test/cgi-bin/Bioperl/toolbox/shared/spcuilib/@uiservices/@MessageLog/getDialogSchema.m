function dlgstruct = getDialogSchema(this,arg) %#ok
%GetDialogSchema Construct MessageLog dialog.

% Copyright 2004-2010 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2010/01/25 22:48:00 $

% Message Filter
%

% Title text
label.Name = 'Display messages with:';
label.Type = 'text';
label.RowSpan = [1 1];
label.ColSpan = [1 2];

% Type popup
typeList = {'All','Info','Warn','Fail'};
typePopup.Tag      = 'type';
typePopup.Name     = 'Type:';
typePopup.Type     = 'combobox';
typePopup.RowSpan  = [2 2];
typePopup.ColSpan  = [1 1];
typePopup.Mode     = 0; % auto-apply; no "pending" color changes
typePopup.Entries  = typeList;
%typePopup.DialogRefresh = true; % force update
typePopup.Graphical = true; % prevents "apply" color changes
typePopup.UserData = typeList; % cache list corresponding to popup enum
typePopup.ObjectMethod = 'handleButtons';
typePopup.MethodArgs   = {'type'};
typePopup.ArgDataTypes = {'string'};

% Category popup
%
% Get list of category names - it's dynamic and changes
theList = ['All' catList(this)];
catPopup.Tag      = 'category';
catPopup.Name     = 'Category:';
catPopup.Type     = 'combobox';
catPopup.RowSpan  = [3 3];
catPopup.ColSpan  = [1 1];
catPopup.Entries  = theList;
catPopup.UserData = theList; % cache list corresponding to popup enum
catPopup.Graphical = true; % prevents "apply" color changes
catPopup.ObjectMethod = 'handleButtons';
catPopup.MethodArgs   = {'category'};
catPopup.ArgDataTypes = {'string'};

% Delete button
%
% NOTE: We have removed this button from the dialog.  It's reasonable to
% consider adding it back, but we must think about the 'delete' behavior
% when linked logs are being used.  That is, delete currently only removes
% messages from the "local" MessageLog; it would need to be defined how to
% influence linked logs --- and whether it would make sense to remove
% messages from those logs.
%
%{
deleteButton.Tag     = 'delete';
deleteButton.Name    = 'Delete';
deleteButton.Type    = 'pushbutton';
deleteButton.RowSpan = [2 2];
deleteButton.ColSpan = [3 3];
deleteButton.ToolTip = sprintf(['Delete all messages in\n' ...
                                'Message Summaries list']);
deleteButton.ObjectMethod = 'handleButtons';
deleteButton.MethodArgs   = {'delete'};
deleteButton.ArgDataTypes = {'string'};
%}

% Message filter panel
mfp.Type    = 'group';
mfp.Name    = 'Message filter';
mfp.Flat    = false;
% mfp.Items   = {label,typePopup,catPopup,deleteButton};  % delete button
mfp.Items   = {label,typePopup,catPopup};
mfp.LayoutGrid = [4 2];  % [4 3];
mfp.RowStretch = [1 1 1 1];
mfp.ColStretch = [0 1];  % [0 1 0];
mfp.Visible    = 1;
mfp.RowSpan    = [1 1];
mfp.ColSpan    = [1 1];

% List of summary log items
%

% Message summary list
[hdr,tbl,idx] = getDialogSummaryList(this);
cnt = numel(tbl); % # of summaries

% Make sure that the Details text object is up to date.
cacheDialogDetail(this);

item.Tag          = 'summary';
item.Name         = hdr;
item.Type         = 'listbox';
item.Graphical    = true; % prevents table from turning "yellow" when a row is clicked
item.MultiSelect  = false;
item.FontFamily   = 'Courier';  % monospaced (non-proportional) font
item.Entries      = tbl;
item.ObjectMethod = 'handleButtons';
item.MethodArgs   = {'summary'};
item.ArgDataTypes = {'string'};
item.Value        = this.SelectedSummary;
item.Mode         = 1;
item.Tunable      = 1;
item.UserData     = idx; % record index of each msg (0=last)
item.MinimumSize = [400 140];  % [w h]

%
% Map the double-click callback
% item.ListDoubleClickCallback = @(hDlg,tag,idx)handleButtons(this,'Open');

% Message summary panel
msp.Type    = 'group';
msp.Name    = sprintf('Message summaries (%d)',cnt);
msp.Flat    = false;
msp.Items   = {item};
msp.Visible = 1;
msp.RowSpan = [2 2];
msp.ColSpan = [1 1];

% Selected item detail panel
%

% Message detail browser (renders HTML text)
detail.Type     = 'textbrowser';
detail.Text     = this.cache_SelectedDetail;
detail.Tag      = 'detail';

% Message detail panel
mdp.Type    = 'group';
mdp.Name    = 'Message detail';
mdp.Flat    = false;
mdp.Items   = {detail};
mdp.Visible = 1;
mdp.RowSpan = [3 3];
mdp.ColSpan = [1 1];

% Dialog auto-open control
%
autoOpen.Tag  = 'autoOpen';
autoOpen.Name = 'Open message log:';
autoOpen.Type = 'combobox';
autoOpen.RowSpan = [4 4];
autoOpen.ColSpan = [1 1];
autoOpen.ObjectProperty = 'AutoOpenMode';
autoOpen.Mode      = true;
autoOpen.Graphical = true;  % auto-apply
autoOpen.ToolTip = sprintf(['Set condition for automatically\n' ...
                            'opening Message Log window']);

% Overall panel
%
main.Type = 'panel';
main.Items = {mfp,msp,mdp,autoOpen};
main.LayoutGrid = [4 1];
main.RowStretch = [0 1 1 0];
main.ColStretch = 1;

% Return DDG dialog structure
dlgstruct                     = this.StdDlgProps;
dlgstruct.Items               = {main};
dlgstruct.StandaloneButtonSet = {''};  % no standard buttons
dlgstruct.DialogTag           = 'MessageLog';

%function to call after the dialog has been opened
dlgstruct.OpenCallback = @onOpen;

function onOpen(this)
%select the first item in the summary widget after the dialog has been
%opened
this.setWidgetValue('summary', 0);


% [EOF]
