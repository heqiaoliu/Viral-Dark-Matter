function dlgstruct = getDialogSchema(this,name) %#ok<INUSD>

% Copyright 2002-2009 The MathWorks, Inc.

if ~exist(this.Document, 'file')
    item1.Value = DAStudio.message('EMLCoder:reportGen:noReportAvailable', this.DocumentTitle);
    item1.Type = 'editarea';
else
    item1.Url  = this.Document;
    item1.Type = 'webbrowser';
    item1.WebKit = true;
end
    
%------------------------------------------------------------------
% Main dialog
%------------------------------------------------------------------
dlgstruct.DialogTitle = this.DocumentTitle;
dlgstruct.StandaloneButtonSet  = {'Ok', 'Help'}; 

dlgstruct.DispatcherEvents = {};
dlgstruct.Items = {item1};
dlgstruct.EmbeddedButtonSet = {''};
dlgstruct.HelpMethod = '';
dlgstruct.HelpArgs = {};

