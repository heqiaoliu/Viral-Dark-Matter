function this = JumpTo(hApp)
%JumpTo Constructor for JumpTo
%  Manages updates to open dialog when property values change
%  Installs listener of MPlay GUI to close dialog automatically

% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2009/03/09 19:33:08 $

this = scopeextensions.JumpTo;

% Initialize DialogBase properties
this.initExt('Jump To', hApp);

% [EOF]
