function status = isOpenButtonEnabled(h)
%  isOpenButtonEnabled
%
%  Checks whether the Diagnostic Viewer's Open button is enabled.
%
%  Copyright 2008 The MathWorks, Inc.

  status = false;
  
  if isa(h.Explorer, 'DAStudio.Explorer')
    dlg = h.Explorer.getDialog();
    imd = DAStudio.imDialog.getIMWidgets(dlg);
    status = imd.isCustomButtonEnabled('DiagMsg_OpenButton');
  else
     ME = MException('DiagnosticViewer:NoGUI', ...
      'Diagnostic Viewer GUI does not exist.');
     throw(ME);
  end

  
end