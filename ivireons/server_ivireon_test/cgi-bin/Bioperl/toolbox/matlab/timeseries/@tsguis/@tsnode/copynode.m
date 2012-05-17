function copynode(this,manager)

% Copyright 2004-2005 The MathWorks, Inc.

%% Copy context menu/ctrl-c callback
manager.Root.Tsviewer.Clipboard = this;
%% Refresh the paste menu
getDialogInterface(this, manager);