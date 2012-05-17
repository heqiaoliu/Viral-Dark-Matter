function b = isScopeAvailable(this)
%ISSCOPEAVAILABLE True if the scope is available

%   @commscope/@abstractScope
%
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/01/05 17:45:33 $

if ishghandle(this.PrivScopeHandle, 'figure')
    b = true;
else
    b = false;
end

%-------------------------------------------------------------------------------
% [EOF]
