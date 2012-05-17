function browser_text = getMessageBrowserText(h)
%  getMessageBrowserText
%
%  Returns the text displayed in the Diagnostic Viewer's message
%  browser.
%
%  Copyright 2008 The MathWorks, Inc.

  if isa(h.Explorer, 'DAStudio.Explorer')
    imme = DAStudio.imExplorer(h.Explorer);
    dlg = imme.getDialogHandle();
    if isempty(dlg)
      ME = MException('DiagnosticViewer:NoDialog', ...
      'Diagnostic viewer content dialog does not exist.');
       throw(ME);
    end
    imd = DAStudio.imDialog.getIMWidgets(dlg);
    msg_browser = find(imd, 'Tag', 'DiagMsg_MsgBrowser');
    browser_text = msg_browser.text;
  else
    ME = MException('DiagnosticViewer:NoWindow', ...
      'Diagnostic viewer window does not exist.');
    throw(ME);

  end

end