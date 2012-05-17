function destroy(dv)
%  destroy
%
%  Safely deletes this instance of the Diagnostic Viewer.
%  
%  Copyright 2009 The MathWorks, Inc.

  % Hide the Diagnostic Viewer window.
  dv.Visible = false;
  
  % Delete the window. This call is temporarily redundant because the
  % visibility listener deletes the window to avoid drool during testing.
  dv.deleteWindow();
  
  % Disconnect the viewer from DAStudio.Root (see DiagViewer).
  dv.disconnect;
  
  % Delete the Diagnostic Viewer object.
  dv.delete();
  
end