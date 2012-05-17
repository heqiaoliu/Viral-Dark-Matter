function selection = getlistselection(h)
%GELISTSELECTION get the first selected row in the listview

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 19:59:40 $

selection = [];
selections = h.imme.getSelectedListNodes;
%get selection
if(~isempty(selections))
  %ignore multiple selections
  selection = selections(1);
end

% [EOF]
