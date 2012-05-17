function Log = findLog(this, port, DataLog)
% FINDLOG Finds the data log for the specified PORT.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2008 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2008/10/02 19:04:19 $

if isempty(DataLog)
  Log = [];
  return
end

LogWho = DataLog.who('all');

% The block whose output we are interested in.
for ct = 1:length(LogWho)
  Log = eval( ['DataLog.' LogWho{ct} ';'] );

  if strcmp(Log.BlockPath, modelpack.strdisp(port.Parent)) && ...
        (Log.PortIndex == port.PortNumber)
    break;
  end
end

% Extract log for specified signal
if isa(Log, 'Simulink.TsArray')
  list = Log.flatten;
  time = LocalUniqueTimeVector(list);

  % Start with an empty time series.
  ts = Simulink.Timeseries;

  % Merge into ts.
  Data = [];
  for ct = 1:length(list)
    tsct = copy( list{ct} );
    tsct.resample(time);

    Data = [ Data, LocalFlattenData(tsct) ];
  end
  set(ts,'Time',time,'Data',Data);

  % Reset properties from port and Log.
  set(ts,'Name',port.UserSpecifiedLogName);
  set(ts,'BlockPath',Log.BlockPath);
  set(ts,'PortIndex',Log.PortIndex);
  set(ts,'SignalName',port.Name);
  set(ts,'ParentName',port.UserSpecifiedLogName);
  Log = ts;
elseif isa(Log, 'Simulink.Timeseries')
  % Reset properties from port.
  set(Log,'Name',port.UserSpecifiedLogName);
  set(Log,'SignalName',port.Name);
  set(Log,'ParentName',port.UserSpecifiedLogName);
end

% ----------------------------------------------------------------------------
function data = LocalFlattenData(ts)
len = ts.length;

if ~ts.IsTimeFirst
  data = reshape( ts.Data, [], len )';
else
  data = ts.Data;
end

% Support for non-double data types
if ~isa(data, 'double')
  data = double(data);
end

% ----------------------------------------------------------------------------
function time = LocalUniqueTimeVector(list)
time = [];
for ct = 1:length(list)
  time = [ time; list{ct}.Time ];
end
time = unique(time);

% TODO:                                                                       
% Consider removing "equal" time points based on some tolerance.
% reltol = power(10, -round(log10(min(abs(diff(time))))));
% reltol = max(reltol, 1/eps);
% time   = unique( round(time*reltol)/reltol );
