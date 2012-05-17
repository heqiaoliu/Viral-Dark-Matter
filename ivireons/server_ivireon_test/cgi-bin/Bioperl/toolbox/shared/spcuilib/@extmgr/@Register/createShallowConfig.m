function hConfig = createShallowConfig(this)
%createShallowConfig Create a shallow Config object, that is, one
%  with an empty PropertyDb property database, even if hRegister
%  has resource and property info available.
%
%  Why do this?  Because it does not require license checkout,
%  and leads to a config set that does not "disturb" any other
%  settings in a config database.  We would use this to form a
%  "blank" set of configs, one for each extension in RegisterDb,
%  and use it as a "template" for the config database.  Then,
%  the shallow configs would be in the "disabled" state, and
%  as they are enabled, default property states from the newly-
%  instantiated extension may be loaded into the config database.
%  Perfect for enabling new configs, and provides the
%  opportunity to enable a disabled-yet-available extension.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2007/03/13 19:46:45 $

% Create and return "empty" extension configuration object
hConfig = extmgr.Config(this.Type, this.Name);

% [EOF]
