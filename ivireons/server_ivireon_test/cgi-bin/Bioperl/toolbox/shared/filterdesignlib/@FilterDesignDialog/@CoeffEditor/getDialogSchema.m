function dlg = getDialogSchema(this, dummy)
%GETDIALOGSCHEMA   Get the dialog information.

%   Author(s): J. Schickler
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/06/27 23:25:51 $

% Get the Help Frame
helpframe = getHelpFrame;
helpframe.RowSpan = [1 1];
helpframe.ColSpan = [1 1];

% Get the Edit Frame
editframe = getEditFrame(this);
fixpt     = getFixedPointTab(this);

tab.Type               = 'tab';
tab.Tabs               = {editframe, fixpt};
tab.RowSpan            = [2 2];
tab.ColSpan            = [1 1];
tab.Tag                = 'TabPanel';
tab.ActiveTab          = this.ActiveTab;
tab.TabChangedCallback = 'FilterDesignDialog.TabChangedCallback';

dlg.DialogTitle     = 'Coefficient Editor';
dlg.Items           = {helpframe, tab};
% dlg.PostApplyMethod = 'postApply';
dlg.PreApplyMethod  = 'preApply';
dlg.PreApplyArgs    = {'%dialog'};
dlg.PreApplyArgsDT  = {'handle', 'handle'};

% -------------------------------------------------------------------------
function editFrame = getEditFrame(this)

Hd = get(this, 'FilterObject');

% Get the coefficient names from the filter object.  These will be used as
% the labels for the edit boxes.
names = coefficientnames(Hd);

editFrame.Items      = {};
editFrame.LayoutGrid = [length(names)+3 2];

for indx = 1:length(names)
    
    propname = sprintf('CoefficientVector%d', indx);
    
    % Render a label for the edit box.  We do this instead of using the
    % default editbox labels so that the editboxes will line up correctly.
    editlabel.Type    = 'text';
    editlabel.Name    = sprintf('%s: ', interspace(names{indx}));
    editlabel.RowSpan = [indx indx];
    editlabel.ColSpan = [1 1];
    editlabel.Tag     = [propname '_label'];
    
    % Render the editbox.
    editbox.Type           = 'edit';
    editbox.ObjectProperty = propname;
    editbox.RowSpan        = [indx indx];
    editbox.ColSpan        = [2 2];
    editbox.Tag            = propname;
    editbox.Source         = this;
    editbox.Mode           = true;

    editFrame.Items = {editFrame.Items{:}, editlabel, editbox};
end

pMemory.Type    = 'checkbox';
pMemory.Name    = 'Persistent memory';
pMemory.RowSpan = [length(names)+1 length(names)+1];
pMemory.ColSpan = [1 2];
pMemory.ObjectProperty = 'PersistentMemory';
pMemory.Tag     = 'PersistentMemory';
pMemory.Mode    = true;
pMemory.DialogRefresh = true;

stateslabel.Type    = 'text';
stateslabel.Name    = 'States: ';
stateslabel.RowSpan = [length(names)+2 length(names)+2];
stateslabel.ColSpan = [1 1];

statesedit.Type    = 'edit';
statesedit.RowSpan = [length(names)+2 length(names)+2];
statesedit.ColSpan = [2 2];
statesedit.ObjectProperty = 'States';
statesedit.Tag     = 'States';
statesedit.Mode    = true;

stateslabel.Enabled = strcmpi(this.PersistentMemory, 'on');
statesedit.Enabled  = strcmpi(this.PersistentMemory, 'on');

editFrame.Items = {editFrame.Items{:}, pMemory, stateslabel, statesedit};
editFrame.Name  = 'Coefficients';
editFrame.RowStretch = [zeros(1, length(names)+2) 1];

% -------------------------------------------------------------------------
function fixpt = getFixedPointTab(this)

h = get(this, 'FixedPoint');

items = {getDialogSchemaStruct(h)};

fixpt.Name  = 'Fixed-point';
fixpt.Items = items;
fixpt.Tag   = 'FixedPointTab';


% -------------------------------------------------------------------------
function helpFrame = getHelpFrame

helptext.Type = 'text';
helptext.Name = 'We need to add help here';
helptext.Tag  = 'HelpText';

helpFrame.Type  = 'group';
helpFrame.Name  = 'Coefficient Editor';
helpFrame.Items = {helptext};
helpFrame.Tag   = 'HelpFrame';

% [EOF]
