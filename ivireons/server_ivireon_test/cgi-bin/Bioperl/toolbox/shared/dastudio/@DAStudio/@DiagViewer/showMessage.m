function showMessage(h, onoff)
%  toggleShowMessage
%
%  Toggles the visibility of the Message column in the message list view of
%  the Diagnostic Viewer.
%
%
%  Copyright 2008 The MathWorks, Inc.

  if onoff == true
    h.showMessageAction.On = 'on';
  else
    h.showMessageAction.On = 'off';
  end
    
  
end


