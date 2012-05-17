function show(this)
%SHOW DDG-based tree view inspector.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2007/03/13 19:46:22 $

if isempty(this.dialog) || ~isa(this.dialog, 'DAStudio.Dialog')
    % create new dialog
    this.dialog = DAStudio.Dialog(this);
else
    % already open
    this.dialog.refresh;    % update the existing data
end
show(this.dialog); % must call show when ExplicitShow=true
this.dialog.resetSize(1);  % force a resize

% [EOF]
