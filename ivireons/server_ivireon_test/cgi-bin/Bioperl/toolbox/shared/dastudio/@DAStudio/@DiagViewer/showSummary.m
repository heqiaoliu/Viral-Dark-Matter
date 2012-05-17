function showSummary(h, onoff)
%  toggleShowMessage
%
%  Toggles the visibility of the Message column in the message list view of
%  the Diagnostic Viewer.
%
%
%  Copyright 2008 The MathWorks, Inc.

  if onoff == true
    h.showSummaryAction.On = 'on';
  else
    h.showSummaryAction.On = 'off';
  end
    
  
end


