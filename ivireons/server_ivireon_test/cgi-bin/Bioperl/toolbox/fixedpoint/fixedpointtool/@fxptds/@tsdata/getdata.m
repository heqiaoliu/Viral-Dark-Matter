function d = getdata(h)
%GETDATA gets signals stored in tsdata
%   D = GETDATA(H) returns a struct array with fields ID and Signal
%   containing the path and Simulink.Timeseries for each signal stored in
%   tsdata

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/11/17 21:49:09 $


%initialize variables
d = [];
if(isa(h.signals, 'Simulink.ModelDataLogs'))
  d = h.unpackmodeldatalogs;
end
if(isa(h.signals, 'Simulink.Timeseries'))
  d = h.utadddata(d, h.signals);
end
if(iscell(h.signals))
  for i = 1:numel(h.signals)
    d = h.utadddata(d, h.signals{i});
  end
end

% [EOF]
