function dlg = getDialogSchema(this,schemaName)
%GETDIALOGSCHEMA   Get the dialog information.

%   Author(s): J. Yu
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/06/27 23:40:41 $

wiWindow.Name = 'Window length (Nwin):';
wiWindow.Tag = 'Nwin';
wiWindow.Type  = 'edit';
wiWindow.Source = this;
wiWindow.ObjectProperty = 'NWindow';
wiWindow.RowSpan = [1 1]; 
wiWindow.ColSpan = [1 2]; 

wiOverlap.Name = 'Overlap (Nlap):            ';
wiOverlap.Tag = 'Nlap';
wiOverlap.Type  = 'edit';
wiOverlap.Source = this;
wiOverlap.ObjectProperty = 'Nlap';
wiOverlap.RowSpan = [2 2];
wiOverlap.ColSpan = [1 2]; 

wiNfft.Name = 'FFT length (Nfft):         ';
wiNfft.Tag = 'Nfft';
wiNfft.Type  = 'edit';
wiNfft.Source = this;
wiNfft.ObjectProperty = 'Nfft';
wiNfft.RowSpan = [3 3];
wiNfft.ColSpan = [1 2]; 

% Overall container
oc.Type  = 'group';
oc.Name  = 'Settings';
oc.Tag = 'settings';
oc.LayoutGrid  = [3 1];
oc.Items = {wiWindow,wiOverlap,wiNfft};

% Main dialog
dlg.DialogTitle = 'Spectrogram Parameters';
dlg.DialogTag = 'specgramparam';
dlg.DisplayIcon = 'toolbox\shared\dastudio\resources\MatlabIcon.png';
dlg.HelpMethod = 'doc';
dlg.HelpArgs =  {'spectrogram'};
dlg.Items = {oc};
dlg.CloseCallback = 'dialogClosecallback';
dlg.CloseArgs = {this};
dlg.PostApplyCallback = 'dialogApplycallback';
dlg.PostApplyArgs = {this};
dlg.PostApplyArgsDT = {'handle'};

% [EOF]
