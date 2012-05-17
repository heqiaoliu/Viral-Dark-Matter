function switchview(h, viewname)

% Copyright 2004 The MathWorks, Inc.

%% Changes the ViewNode property to the view defined by the supplied name
views = h.Parentviewnode.getChildren;
I = find(strcmp(viewname,get(views,{'Label'})));
if ~isempty(I)
    h.ViewNode = views(I(1));
end