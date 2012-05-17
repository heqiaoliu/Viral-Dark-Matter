function show(this)
%SHOW DDG-based tree view inspector.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.3 $  $Date: 2009/03/09 19:34:04 $

persistent Load_DA_Studio
if isempty(Load_DA_Studio)
    DAStudio.Object;    % Setup DAStudio for DDG
    Load_DA_Studio = 1; % no need to repeat in the same MATLAB session
end
if isempty(this.dialog) || ~uimgr.isHandle(this.dialog)
    % create new dialog
    this.dialog = DAStudio.Dialog(this);
else
    % already open
    this.dialog.refresh;    % update the existing data
end
show(this.dialog); % must call show when ExplicitShow=true
this.dialog.resetSize(1);  % force a resize

% [EOF]
