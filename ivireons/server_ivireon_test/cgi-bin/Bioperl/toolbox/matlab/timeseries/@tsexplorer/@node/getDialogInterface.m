function [panel,helppanel] = getDialogInterface(this, manager)
% GETDIALOGINTERFACE Refreshes help panel and may reset the right click menus (which
% can change if the plots have changed)

% Copyright 2004-2005 The MathWorks, Inc.

[panel,helppanel] = this.updatenode(manager);
