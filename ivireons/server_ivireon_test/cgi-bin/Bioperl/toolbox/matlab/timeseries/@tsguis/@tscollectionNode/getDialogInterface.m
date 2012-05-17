function [panel,helppanel] = getDialogInterface(this, manager)
% GETDIALOGINTERFACE Refreshes help panel and may reset the right click menus (which
% can change if the plots have changed)

% Copyright 2005 The MathWorks, Inc.

[panel,helppanel] = this.updatenode(manager);

%% Refesh the New Plot panel since the views may have changed.
if ~isempty(this.NewPlotPanel)
     this.NewPlotPanel.update(manager,[]);
end
