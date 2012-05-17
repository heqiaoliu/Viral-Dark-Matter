function view = getView(h, viewName)

%   Copyright 2009 The MathWorks, Inc.

% Returns the view with the given name.
    
view = find(h, '-isa', 'DAStudio.MEView', 'Name', viewName);
