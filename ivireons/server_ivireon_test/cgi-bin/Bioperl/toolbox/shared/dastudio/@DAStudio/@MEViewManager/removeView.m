function success = removeView(h, viewName)
% Remove the given view

%   Copyright 2009 The MathWorks, Inc.

success = true;
% Check if views exists, if not return false.
targetView = find(h, '-isa', 'DAStudio.MEView', 'Name', viewName);
if isempty(targetView)
    success = false;
    return;
end

% Delete the view.
try 
    targetView.delete;
    success = true;
catch e
    success = false;
end
