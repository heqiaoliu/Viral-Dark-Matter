function selectDiagnosticMsg(h, msg)
%  SELECTDIAGNOSTICMSG
%
%  Select message in viewer window.
%
%  Copyright 2008-2010 The MathWorks, Inc.
  
  h.Explorer.view(msg);
  h.selectedMsg = msg;
  
end


