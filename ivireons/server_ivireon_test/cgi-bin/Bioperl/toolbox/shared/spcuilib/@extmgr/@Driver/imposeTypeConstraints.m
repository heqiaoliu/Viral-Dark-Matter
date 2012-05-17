function imposeTypeConstraints(this)
%IMPOSETYPECONSTRAINTS Enforce extension type constraints.
%   IMPOSETYPECONSTRAINTS(H) applies extension type constraint to
%   extension configurations.  Extensions may need to be enabled or
%   disabled in order to achieve constraint.
%
%   Events are suppressed when changing enable-properties in order to
%   impose constraints without continuous updates.  processAll is called to
%   keep the extensions up to date at the end of the method only if the
%   AllowConfigEnableChangedEvent is set to true when this method is
%   called.
%
%   See RegisterType for details on type constraints.

% Copyright 2006-2009 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2009/10/07 14:23:38 $

% Get database of registered extension types
% Note that not all extension types are registered, only those for which a
% client has generally set optional attributes, such as a constraint.
hRegisterTypeDb = this.RegisterDb.RegisterTypeDb;

% If there are no registered types, there is nothing to impose.
if isEmpty(hRegisterTypeDb)
    return;
end

hConfigDb = this.ConfigDb;

% We "turn off" enable-property change detection prior to touching the
% enable properties.  We don't want to initiate the process of adding
% extensions due to enable/disable at this time.  We do this uniformly for
% all extensions later, when processAll() is called as an iterator.
oldEnableState = get(hConfigDb, 'AllowConfigEnableChangedEvent');
hConfigDb.AllowConfigEnableChangedEvent = false;

% Visit each registered RegisterType to implement constraint
iterator.visitImmediateChildren(hRegisterTypeDb, ...
    @(h) impose(h.Constraint, hConfigDb, this.RegisterDb));

% Re-enable event that broadcasts changes to the Enable property
hConfigDb.AllowConfigEnableChangedEvent = oldEnableState;

% Force an update here, only if the Allow flag was set to true when we
% entered this function.  If it is false, then the caller would not expect
% extensions to be created/destroyed until it calls processAll explicitly.
if oldEnableState
    processAll(this);
end

% [EOF]
