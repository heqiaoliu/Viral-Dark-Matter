function d = unpackmodeldatalogs(h)
%UNPACKMODELDATALOGS

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/10 21:33:27 $

%initialize variables
d = [];
%start unpacking at the root
d = unpack(d, h, h.signals, 0, '', '');

%--------------------------------------------------------------------------
function d = unpack(d, h, logsout, isMdlRef, path, name)
% get the names of the logged signals
signals = logsout.who;
% loop through the logged signals and add data to record
for signalIndex = 1:numel(signals)
  % get the name of the signal to extract from ModelDataLogs
  signalName = signals{signalIndex};
  % remove the parentheses and quotes from signals and subsystems
  % whose names contain spaces
  signalName = strrep(strrep(signalName, '(''', ''), ''')', '');
  % get the signal from ModelDataLogs
  try
    thisSignal = logsout.(signalName);
  catch
    DAStudio.error('FixedPoint:fixedPointTool:warningSignalNotCollected', signalName);
  end
  clz = class(thisSignal);
  switch clz
    %this is a Timeseries so add it
    case 'Simulink.Timeseries'
      d = h.utadddata(d, thisSignal, isMdlRef, path, name);
    %this is a ModelDataLogs object from a model reference 
    case 'Simulink.ModelDataLogs'
      d = unpack(d, h, thisSignal, 1, thisSignal.BlockPath, thisSignal.Name);
    %this is some other container tah tis not a model reference (eg: subsystem)
    otherwise
      d = unpack(d, h, thisSignal, 0, '', '');
  end
end

% [EOF]