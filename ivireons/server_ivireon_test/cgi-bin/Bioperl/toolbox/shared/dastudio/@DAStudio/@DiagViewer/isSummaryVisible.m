function yesno = isSummaryVisible(h)
%  toggleShowSummary
%
%  Toggles the visibility of the Summary column in the Summary list view of
%  the Diagnostic Viewer.
%
%
%  Copyright 2008 The MathWorks, Inc.

  if ismember('Summary', h.msgListProps)
    yesno = true;
  else
    yesno = false;
  end
    
  
end


