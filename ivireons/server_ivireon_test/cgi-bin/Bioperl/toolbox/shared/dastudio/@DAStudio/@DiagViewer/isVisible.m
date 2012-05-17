
function result = isVisible(h)
%  ISVISIBLE This function is used to see if the diagnostic viewer is visible or not
%  for the Diagnostic Viewer  
%  Copyright 1990-2008 The MathWorks, Inc.

result = h.Visible && ~isempty(h.Explorer);


end