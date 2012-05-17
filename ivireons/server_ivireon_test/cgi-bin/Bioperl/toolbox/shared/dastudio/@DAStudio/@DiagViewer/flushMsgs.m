function flushMsgs(h)
%  FLUSHMSGS
%  Clears messages from the Diagnostic Viewer window.
%
%  Copyright 1990-2008 The MathWorks, Inc.
 
 h.Messages = [];
 
 h.updateWindow();

end

