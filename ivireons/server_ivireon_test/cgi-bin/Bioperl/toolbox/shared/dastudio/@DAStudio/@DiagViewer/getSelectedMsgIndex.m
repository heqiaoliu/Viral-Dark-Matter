function index = getSelectedMsgIndex(h)
%  GETSELECTEDMSGINDEX
%
%  Get the index of the message currently selected in the
%  Diagnostic Viewer.
%
%  Copyright 1990-2008 The MathWorks, Inc.

  selectedMsg = h.getSelectedMsg;
  
  msgs = h.Messages;
  
  index = 0;
  for i = 1:length(msgs)
    if msgs(i) == selectedMsg
      index = i;
      break;
    end
  end
  
  if (index <= 0)
    ME = MException('DiagnosticViewer:InconsistentMessageSelection', ...
      'The Diagnostic Viewer has no record of selected message.');
    throw(ME);
  end
  
end
