function yesno = isSourceVisible(h)
%  toggleShowSource
%
%  Toggles the visibility of the Source column in the Source list view of
%  the Diagnostic Viewer.
%
%
%  Copyright 2008 The MathWorks, Inc.

  if ismember('SourceName', h.msgListProps)
    yesno = true;
  else
    yesno = false;
  end
    
  
end


