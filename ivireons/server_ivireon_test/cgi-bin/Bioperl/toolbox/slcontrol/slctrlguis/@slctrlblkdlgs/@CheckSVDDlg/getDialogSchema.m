function dlgStruct = getDialogSchema(this, varargin)
%

% Author(s): A. Stothert 06-Oct-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/03/31 18:59:35 $

% Get the block handle from the dialog source
hBlk = this.getBlock;

%Get the elements of the dialog
tabAssertion     = this.getAssertionDialogSchema(hBlk);
tabLogging       = this.getLoggingDialogSchema(hBlk);
tabLinearization = this.getLinearizationDialogSchema(hBlk);
tabBounds        = this.getBoundsDialogSchema(hBlk);
%Description text
txtDescription.Type = 'text';
txtDescription.Tag  = 'txtDescription';
txtDescription.Name = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtSigmaDescription');
txtDescription.WordWrap = true;
txtDescription.RowSpan  = [1 1];
txtDescription.ColSpan  = [1 1];
%Description group
grpDescription.Type = 'group';
grpDescription.Tag  = 'grpDescription';
grpDescription.Name = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:grpSigmaDescription');
grpDescription.Items = {txtDescription};
grpDescription.LayoutGrid = [1 1];

%Group tabs
tabList.Type = 'tab';
tabList.Tag  = 'tbpnlMain';
tabList.Tabs = {tabLinearization, tabBounds, tabLogging, tabAssertion};
tabList.ColSpan = [1 1];
tabList.RowSpan = [2 2];

%Construct view button and checkbox
pnlView            = this.getViewDialogSchema;
grpView.Type       = 'panel';
grpView.LayoutGrid = [1 1];
grpView.Items      = {pnlView};
grpView.RowSpan    = [3 3];
grpView.ColSpan    = [1 1];

%% Construct the Dialog
dlgStruct.DialogTag   = 'CheckSVDDlg';
dlgStruct.HelpMethod  = 'slhelp';
dlgStruct.HelpArgs    = {this.getBlock.Handle};
dlgStruct.Items       = {grpDescription, tabList, grpView};
dlgStruct.LayoutGrid  = [3 1];
dlgStruct.ShowGrid    = false;

% Required for widget->dlg->block sync
dlgStruct.PreApplyMethod = 'preApplySVDCallback';
dlgStruct.PreApplyArgs   = {'%dialog'};
dlgStruct.PreApplyArgsDT = {'handle'};
% Required for dlg->block sync
dlgStruct.PostApplyMethod   =  'postApplySVDCallback';
dlgStruct.PostApplyArgs     = {'%dialog'};
dlgStruct.PostApplyArgsDT   = {'handle'};
% Required for deregistration
dlgStruct.CloseMethod       = 'closeCallback';
dlgStruct.CloseMethodArgs   = {'%dialog'};
dlgStruct.CloseMethodArgsDT = {'handle'};

% Disable the dialog in a library, or in a linked subsystem.
[~, isLocked] = this.isLibraryBlock(hBlk);
hParent = get_param(hBlk.Parent,'Object');
isLocked = isLocked || hParent.isLinked;
if isLocked
    dlgStruct.DisableDialog = 1;
else
    dlgStruct.DisableDialog = 0;
end
end