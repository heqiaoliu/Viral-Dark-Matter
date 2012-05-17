function thisnode = getselectednode(h)

% Copyright 2004 The MathWorks, Inc.

%% Gets the udd habdle to the curretnly selected node
selnodes = h.Tree.getSelectedNodes;
if length(selnodes)>0
    thisnode = handle(selnodes(1).getValue);
else
    thisnode = [];
end