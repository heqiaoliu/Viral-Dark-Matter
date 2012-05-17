function showReported(h, onoff)
%  toggleShowMessage
%
%  Toggles the visibility of the Message column in the message list view of
%  the Diagnostic Viewer.
%
%
%  Copyright 2008 The MathWorks, Inc.

  if onoff == true
    h.showReportedAction.On = 'on';
  else
    h.showReportedAction.On = 'off';
  end
    
  
end


