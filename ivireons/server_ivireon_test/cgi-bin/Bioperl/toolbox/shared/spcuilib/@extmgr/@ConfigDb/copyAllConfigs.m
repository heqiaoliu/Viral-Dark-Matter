function hConfigDb = copyAllConfigs(this)
%COPYALLCONFIGS Copy all configurations

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2007/08/24 15:06:13 $

% Create new ConfigDb, copying name and description from original
hConfigDb             = extmgr.ConfigDb;
hConfigDb.Name        = this.Name;
hConfigDb.Description = this.Description;

hConfig = allChild(this);

% Add copies of all child configs
for indx = 1:length(hConfig)
    hConfigDb.add(copy(hConfig(indx), 'children'));
end

% [EOF]
