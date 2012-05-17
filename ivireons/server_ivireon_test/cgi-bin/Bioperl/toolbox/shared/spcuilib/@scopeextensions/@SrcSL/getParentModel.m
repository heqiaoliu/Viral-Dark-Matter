function parentModel = getParentModel(this)
%GETPARENTMODEL Get the handle to the parent model.

%   Author(s): J. Schickler
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/14 04:06:40 $

if isempty(this.SLConnectMgr)
    parentModel = [];
else
    parentModel = getSystemHandle(this.SLConnectMgr);
end

% [EOF]
