function hConfig = createActiveConfig(this)
%createActiveConfig Create an active Config object.
%  createActiveConfig(h) creates an Config object representing the
%  default property values of this extension registration.
%  All properties are set to Active status.
%
%  NOTE: This method calls getResources, and may check out a product
%  license in so doing.  See help for getResources for valid settings
%  for licenseChecks, and the outcomes for each.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2007/03/13 19:46:44 $

hPropertyDb = getPropertyDb(this);

% Copy the properties database for this extension
%
% By definition, properties from Register all have "default" status,
% and we set them now to Active. To do this, we must make a deep
% copy of the prop database, including all child Property's
%
% (If we don't make a copy, we'll be changing the status of the
%  Register property object as well - that would be bad.  Plus we
%  just need our own to hand off to Config)
%
hPropertyDb = copy(hPropertyDb, 'children');

% Now change all props to Active in the copy
set(allChild(hPropertyDb), 'Status', 'active');

% Create and return extension configuration object
hConfig = extmgr.Config(this.Type, this.Name, false, hPropertyDb);

% [EOF]
