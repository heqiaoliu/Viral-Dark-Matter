function close
%  close
%
%  Close the Diagnostic Viewer.
%  
%  Copyright 2008 The MathWorks, Inc.

  viewer = DAStudio.DiagViewer.findActiveInstance();
  viewer.Visible = false;
   
end