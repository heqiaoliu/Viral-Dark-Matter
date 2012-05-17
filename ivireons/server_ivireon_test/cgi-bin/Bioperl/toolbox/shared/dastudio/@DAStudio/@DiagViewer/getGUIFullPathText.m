function path = getGUIFullPathText(h)
%  getGUIFullPathText
%
%  Returns the full path displayed on the Diagnostic Viewer's GUI.
%
%  Copyright 2008 The MathWorks, Inc.

  if isa(h.Explorer, 'DAStudio.Explorer')
    dlg = h.Explorer.getDialog();
    imd = DAStudio.imDialog.getIMWidgets(dlg);
    widget = find(imd, 'Tag', 'DiagMsg_FullPathText');
    path = widget.text;
  else
    ME = MException('DiagnosticViewer:NoWindow', ...
      'Diagnostic viewer window does not exist.');
    throw(ME);
  end

end