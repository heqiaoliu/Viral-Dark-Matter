function b = isConnected(this)
%ISCONNECTED True if the object is Connected

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/01/05 17:58:35 $

% If our error condition is anything other than success we are not properly
% connected regardless of what we hold in the SLConnectMgr object.
b = ~isempty(this.SLConnectMgr) && strcmpi(this.ErrorStatus, 'success');

% [EOF]
