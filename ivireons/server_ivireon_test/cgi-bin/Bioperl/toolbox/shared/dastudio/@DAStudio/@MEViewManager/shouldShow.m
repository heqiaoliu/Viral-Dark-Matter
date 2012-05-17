function show = shouldShow(h, obj)

%   Copyright 2009 The MathWorks, Inc.

% If feature is enable check otherwise return true.
if slfeature('ModelExplorerPropertyFilter')
    if ishandle(h.ActiveView)
        show = h.ActiveView.shouldShow(obj);
    else
        show = true;
    end
else
    show = true;
end