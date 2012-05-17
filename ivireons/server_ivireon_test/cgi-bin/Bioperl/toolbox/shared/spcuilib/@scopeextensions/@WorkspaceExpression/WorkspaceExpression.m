function this = WorkspaceExpression(hApp)
%LoadExpr Constructor for LoadExpr
% Manages updates to open dialog when property values change
% Installs listener of MPlay GUI to close dialog automatically

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2009/03/09 19:33:30 $

this = scopeextensions.WorkspaceExpression;

% Initialize DialogBase properties
this.initExt('Import from Workspace', hApp);

% [EOF]
