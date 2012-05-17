function views = getAllViews(h)

%   Copyright 2009 The MathWorks, Inc.

% Returns the current views with this manager.
    
views = find(h, '-isa', 'DAStudio.MEView');
