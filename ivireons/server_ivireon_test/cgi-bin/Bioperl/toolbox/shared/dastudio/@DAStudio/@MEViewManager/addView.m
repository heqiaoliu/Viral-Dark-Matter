function addView(h, view)

%   Copyright 2009 The MathWorks, Inc.

% add view to the view management hierarchy
if ~isempty(view) && ~isempty(h)
    % Check valid view names and if it already exists or not.
    v = find(h, '-isa', 'DAStudio.MEView', 'Name', view.Name);
    if isempty(v)
        view.ViewManager = h;
        view.connect(h, 'up');
        view.enableLiveliness;
    end
end
