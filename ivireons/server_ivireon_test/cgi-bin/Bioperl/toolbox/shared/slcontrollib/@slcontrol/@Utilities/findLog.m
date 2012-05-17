function Log = findLog(this, LogObject, LogName, LogWho)
% FINDLOG Extracts signal log with a given name.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.6.8 $ $Date: 2010/02/17 18:58:55 $

if isempty(LogObject)
  Log = [];  return
end

if nargin < 4
  LogWho = LogObject.who('all');
end

% Find index in log
s = regexp(LogWho, ['(\.', LogName, '$|', LogName, '$)'], 'once');
idx = find( ~cellfun('isempty', s) );
if isempty(idx)
  ctrlMsgUtils.error( 'SLControllib:slcontrol:SignalNotFound', LogName );
end

% Extract log for specified signal
Log = eval( ['LogObject.' LogWho{idx}] );
if isa(Log, 'Simulink.TsArray')
  members = Log.Members;
  ts = copy(Log.(members(1).name));
  for ct = 2:length(members)
    tsct = copy(Log.(members(ct).name));
    try
      merge(ts, tsct, 'union');
    catch E
      % Handle tolerance error (g616818).
      if strcmp(E.identifier, 'timeseries:synchronize:tol')
        merge(ts, tsct, 'union', 'tolerance', 1e-20);
      else
        rethrow(E);
      end
    end
    ts.Data = [ts.Data, tsct.Data];
  end
  Log = ts;
end

% Support for non-double data types
if ~isa(Log.Data, 'double')
  Log.Data = double(Log.Data);
end
