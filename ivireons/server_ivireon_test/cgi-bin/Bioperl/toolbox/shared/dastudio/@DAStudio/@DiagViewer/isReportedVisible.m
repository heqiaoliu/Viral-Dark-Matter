function yesno = isReportedVisible(h)
%  toggleShowReported
%
%  Toggles the visibility of the Reported column in the Reported list view of
%  the Diagnostic Viewer.
%
%
%  Copyright 2008 The MathWorks, Inc.

  if ismember('Component', h.msgListProps)
    yesno = true;
  else
    yesno = false;
  end
    
  
end


