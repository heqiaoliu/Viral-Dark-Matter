function clickCloseButton(h)
%  clickCloseButton
%
%  Clicks the Diagnostic Viewer's Close button.
%
%  Copyright 2008 The MathWorks, Inc.

  if isa(h.Explorer, 'DAStudio.Explorer')
    dlg = h.Explorer.getDialog();
    imd = DAStudio.imDialog.getIMWidgets(dlg);
    imd.clickCustomButton('DiagMsg_CloseButton');
  else
     ME = MException('DiagnosticViewer:NoGUI', ...
      'Diagnostic Viewer GUI does not exist.');
     throw(ME);
  end

  
end