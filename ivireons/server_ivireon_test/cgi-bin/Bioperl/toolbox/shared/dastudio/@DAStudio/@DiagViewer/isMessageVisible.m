function yesno = isMessageVisible(h)
%  toggleShowMessage
%
%  Toggles the visibility of the Message column in the Message list view of
%  the Diagnostic Viewer.
%
%
%  Copyright 2008 The MathWorks, Inc.

  if ismember('DispType', h.msgListProps)
    yesno = true;
  else
    yesno = false;
  end
    
  
end


