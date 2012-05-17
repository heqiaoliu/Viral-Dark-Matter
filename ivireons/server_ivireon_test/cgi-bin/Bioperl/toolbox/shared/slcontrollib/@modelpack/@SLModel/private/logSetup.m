function settings = logSetup(this, ports)
% LOGSETUP Saves the data logging settings of a Simulink model in a structure
% and turns on data logging for the specified PORTS.
%
% See LOGCLEANUP.

% Author(s): P. Gahinet, Bora Eryilmaz
% Revised:
% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2010/03/22 04:19:55 $

model = this.getName;

% Get model's signal logging settings.
Dirty    = get_param(model, 'Dirty');
LogFlag  = get_param(model, 'SignalLogging');
LogName  = get_param(model, 'SignalLoggingName');

% Store data logging settings for each port.
LogStruct = struct( ...
    'DataLogging',         get(ports, {'DataLogging'}), ...
    'DataLoggingName',     get(ports, {'DataLoggingName'}), ...
    'DataLoggingNameMode', get(ports, {'DataLoggingNameMode'}) );

% Create return data structure.
settings = struct( 'Dirty',     Dirty, ...
                   'LogFlag',   LogFlag, ...
                   'LogName',   LogName, ...
                   'LogStruct', LogStruct );

% Turn on data logging for each port.
for ct = 1:length(ports)
  port = ports(ct);

  % Will log signal using custom data logging name.
  set( port, 'DataLogging',         'on', ...
             'DataLoggingName',     strrep(tempname, tempdir, ''), ...
             'DataLoggingNameMode', 'Custom' );
end

% Turn on signal logging for the model.
set_param( model, 'SignalLogging',     'on', ...
                  'SignalLoggingName', 'Model_DataLog' );
