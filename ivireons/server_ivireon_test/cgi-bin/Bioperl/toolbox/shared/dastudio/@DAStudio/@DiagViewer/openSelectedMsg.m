function openSelectedMsg
%  openSelectedMsg
%  Open the message selected in the Diagnostic Viewer's
%  window
%  Copyright 2008 The MathWorks, Inc.
   
  viewer = DAStudio.DiagViewer.findActiveInstance();
  viewer.openMessage(viewer.selectedMsg);
  
end




