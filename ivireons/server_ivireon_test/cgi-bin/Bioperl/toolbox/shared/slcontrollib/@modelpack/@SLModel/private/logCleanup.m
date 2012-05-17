function logCleanup(this, ports, settings)
% LOGCLEANUP Restores the data logging settings of a Simulink model to the
% values specified for the given PORTS.
%
% See LOGSETUP.

% Author(s): P. Gahinet, Bora Eryilmaz
% Revised:
% Copyright 2004-2010 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2010/03/22 04:19:54 $

model = this.getName;

% Restore data logging settings of each port.
LogStruct = settings.LogStruct;
for ct = 1:length(ports)
  port = ports(ct);
  lsct = LogStruct(ct);

  set( port, 'DataLogging',         lsct.DataLogging, ...
             'DataLoggingName',     lsct.DataLoggingName, ...
             'DataLoggingNameMode', lsct.DataLoggingNameMode );
end

% Restore signal logging settings of the model (Dirty flag last).
set_param( model, ...
           'SignalLogging',     settings.LogFlag, ...
           'SignalLoggingName', settings.LogName, ...
           'Dirty',             settings.Dirty );
