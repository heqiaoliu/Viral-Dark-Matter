function reset(h)

% Copyright 2005 The MathWorks, Inc.

%% Clears the lock on the tree so that node can be selected

selectModel = h.Tree.getTree.getSelectionModel;
selectModel.fCurrentPath = [];

