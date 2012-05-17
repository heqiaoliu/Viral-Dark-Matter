function addDiagnosticMsg(h,msg)
%  ADDDIAGNOSTICMSG
%  This adds a diagnostic message to the
%  viewer window
%  Copyright 1990-2008 The MathWorks, Inc.
  
%  $Revision: 1.1.8.1 $ 

  
% Here append this message to the list of messages 
% associated with this DiagnosticViewer

h.messages = [h.messages;msg];

