function setCurrentConfig(this, config)
% SETCURRENTCONFIG Sets the current configuration set used in the model.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2006/11/17 14:00:40 $

% Set configuration set.
model = get_param( this.Name, 'Object' );

oldConfig = model.getConfigSet(config.Name);  %Potential name conflict
if isempty(oldConfig) 
  % Uniquely named configuration set, attach and make it active.
  model.attachConfigSet(config);
  model.setActiveConfigSet(config.Name);
elseif ~isequal(oldConfig, config )
  % Replace old configuration with new config with same name.
  name = config.Name;

  % Temporary name
  config.Name = strrep(tempname, tempdir, '');

  % Add new configuration and make it active.
  model.attachConfigSet(config);
  model.setActiveConfigSet(config.Name);

  % Remove old configset and rename the new one.
  model.detachConfigSet(name);
  config.Name = name;
else
   % Set old configuration as the active configuration
   model.setActiveConfigSet(config.Name)
end
