function deleteScope(this)
%DELETESCOPE    Delete callback function for closing a scope

%   @commscope/@abstractScope
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/07 18:17:52 $

% Reset the scope handle to invalid
this.PrivScopeHandle = -1;

%-------------------------------------------------------------------------------
% [EOF]
