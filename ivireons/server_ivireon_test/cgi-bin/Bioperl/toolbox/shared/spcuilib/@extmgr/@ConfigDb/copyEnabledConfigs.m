function hConfigDb = copyEnabledConfigs(this)
%copyEnabledCfgs Copy only enabled configs to new database.
%   copyEnabledCfgs(hConfigDb) creates a new config database and adds to it
%   only those configurations that are enabled.  This is a minimum
%   configuration set, useful for serialization to a file.
%
%   Makes a deep copy of configurations so sources are not corrupted.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/03/13 19:45:36 $

% Create new ConfigDb, copying name and description from original
hConfigDb             = extmgr.ConfigDb;
hConfigDb.Name        = this.Name;
hConfigDb.Description = this.Description;

% Find all the enabled children.
hConfig = findChild(this, 'Enable', true);

% Add copies of enabled child configs only
for indx = 1:length(hConfig)
    hConfigDb.add(copy(hConfig(indx), 'children'));
end

% [EOF]
