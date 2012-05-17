function setPendingSimTimeReadout(this)
%SetPendingSimTimeReadout
%   Set pending time-update flag of all OTHER players
%   connected to this model

% Copyright 2004-2005 The MathWorks, Inc.
% $Date: 2009/11/16 22:34:08 $ $Revision: 1.1.6.3 $

m = findScopesSameBD(this, 'scopeextensions.SrcSL');
for i=1:numel(m)
    m(i).DataSource.controls.PendingSimTimeReadout = true;
end

% [EOF]
