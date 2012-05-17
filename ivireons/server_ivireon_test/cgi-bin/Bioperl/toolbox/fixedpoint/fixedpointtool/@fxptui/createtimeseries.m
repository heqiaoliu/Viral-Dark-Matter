function ts = createtimeseries(name, path, time, data)
%CREATETIMESERIES  create a timeseries

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 19:57:55 $

starttime = [];
stoptime = [];
interval = [];
if(numel(time) ~= numel(data(:,1)))
  [time, starttime, stoptime, interval] = gettsargs(time, data);
end
ts = Simulink.Timeseries;
path = fxptds.getpath(path);
ts.initialize(name, path, [], ...
	'', '', data, time, starttime, ...
	interval, stoptime, [], [1 1]);%[1 numel(time)]);
ts.Name = name;
ts.ParentName = 'Workspace';

%--------------------------------------------------------------------------
function   [time, starttime, stoptime, interval] = gettsargs(time, data)
starttime = time(1);
stoptime = time(end);
if(numel(time) == 1)
  interval = 0;
else
  interval = time(2) - time(1);
end
%if this is a single time step pass initialize time = 0
if(interval <= 0)
  interval = (stoptime-starttime)/numel(data);
  stoptime = stoptime - interval;
  time = 0;
%otherwise use starttime, stoptime and interval to initialize
else
  time = [];
end

% [EOF]
