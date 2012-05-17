function clickHelpButton(h)
%  clickHelpButton
%
%  Clicks the Diagnostic Viewer's Help button.
%
%  Copyright 2008 The MathWorks, Inc.

  if isa(h.Explorer, 'DAStudio.Explorer')
    dlg = h.Explorer.getDialog();
    imd = DAStudio.imDialog.getIMWidgets(dlg);
    imd.clickCustomButton('DiagMsg_HelpButton');
  else
     ME = MException('DiagnosticViewer:NoGUI', ...
      'Diagnostic Viewer GUI does not exist.');
     throw(ME);
  end

  
end