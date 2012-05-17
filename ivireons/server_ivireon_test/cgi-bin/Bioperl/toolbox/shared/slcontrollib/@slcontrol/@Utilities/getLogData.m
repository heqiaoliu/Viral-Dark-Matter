function [Yexp,Ysim,Tcom] = getLogData(this, ExpLog, SimLog)
% GETLOGDATA Extract and interpolate experiment and simulation data at the
% common time base.

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/12/10 19:33:41 $

% Experiment data
te = ExpLog.Time;
ye = ExpLog.Data;

% Simulation data
ts = SimLog.Time;
ys = SimLog.Data;

% Extract data at the right time points
if isempty(te) || isempty(ye)
  % Empty experiment data.
  ye = []; ys = []; tc = [];
else
  nd = length(ExpLog.Dimensions);
  if nd > 1
    % For multi-dimensional data, time is along the last dimension.
    % Reshape to 2-D array with time along the first dimension.
    ye = reshape( permute(ye,[nd+1,1:nd]), [length(te),prod(ExpLog.Dimensions)]);
    ys = reshape( permute(ys,[nd+1,1:nd]), [length(ts),prod(ExpLog.Dimensions)]);
  end
  
  % Merge the time bases.  Empty tc if there is no time overlap.
  tmin = max( te(1),   ts(1) );
  tmax = min( te(end), ts(end) );
  tc   = te(te>=tmin & te<=tmax);
  
  % Turn interpolation warning off (NaNs in the data)
  ws = warning('off', 'MATLAB:interp1:NaNinY'); lw = lastwarn;
  
  % Interpolate.  No extrapolation since tc is always a subset of te & ts.
  % ATTN: Do linear interpolation anyway.
  % methods = {'nearest', 'linear'};
  methods = {'linear', 'linear'};
  idx = strcmp( ExpLog.InterSample, {'zoh', 'foh'} );
  ye = interp1( te, ye, tc, methods{idx} );
  ys = interp1( ts, ys, tc, methods{idx} );
  
  % Restore warning state
  warning(ws); lastwarn(lw);
end

% Outputs
Yexp = ye;
Ysim = ys;
Tcom = tc;
