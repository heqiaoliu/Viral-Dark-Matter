function schema = getDialogSchema(this, name) %#ok<INUSD>

tag_prefix = 'DiagMsgContainer_';

fullPathIcon.Type = 'image';
fullPathIcon.FilePath = fullfile(matlabroot, 'toolbox', 'shared', ...
  'dastudio', 'resources', 'diagviewer', 'block.gif');
fullPathIcon.ColSpan = [1 1];
fullPathIcon.Tag = [tag_prefix 'FullPathIcon'];

fullPathText.Type = 'text';
fullPathText.Name = ' ';
fullPathText.ColSpan = [2 2];
fullPathText.Tag = [tag_prefix 'FullPathText'];

fullPathPanel.Type = 'panel';
fullPathPanel.LayoutGrid = [1 2];
fullPathPanel.RowSpan = [1 1];
fullPathPanel.Items = {fullPathIcon, fullPathText};
fullPathPanel.Tag = [tag_prefix 'FullPathPanel'];

if 0 && DAStudio.Root.hasWebBrowser %PC we have IE widget
   msgBrowser.Type      = 'webbrowser';
else
   msgBrowser.Type      = 'textbrowser';
end

msgBrowser.Text = ' ';
msgBrowser.RowSpan = [2 2];
msgBrowser.Tag = [tag_prefix 'MsgBrowser'];

openButton.Type = 'pushbutton';
openButton.Name = DAStudio.message('Simulink:components:DVOpen');
openButton.ColSpan = [2 2];
openButton.Enabled = false;
openButton.MatlabMethod = 'DAStudio.DiagViewer.openSelectedMsg';
openButton.Tag = [tag_prefix 'OpenButton'];

helpButton.Type = 'pushbutton';
helpButton.Name = DAStudio.message('Simulink:components:DVHelp');
helpButton.ColSpan = [3 3];
helpButton.MatlabMethod = 'DAStudio.DiagViewer.showHelp';
helpButton.Tag = [tag_prefix 'HelpButton'];

closeButton.Type = 'pushbutton';
closeButton.Name = DAStudio.message('Simulink:components:DVClose');
closeButton.ColSpan = [4 4];
closeButton.MatlabMethod = 'DAStudio.DiagViewer.close';
closeButton.Tag = [tag_prefix 'CloseButton'];

buttonSpacer.Type = 'panel';

buttonPanel.Type = 'panel';
buttonPanel.LayoutGrid = [1 4];
buttonPanel.ColStretch = [1, 0, 0, 0];
buttonPanel.Items = {buttonSpacer, openButton, helpButton, closeButton};
buttonPanel.Tag = [tag_prefix 'ButtonPanel'];

schema.DialogTitle = ''; 
schema.DialogTag = [tag_prefix 'Dialog'];
schema.EmbeddedButtonSet = buttonPanel;
schema.IsScrollable = false;
schema.LayoutGrid = [3 1];
schema.Items = {fullPathPanel, msgBrowser};


end


