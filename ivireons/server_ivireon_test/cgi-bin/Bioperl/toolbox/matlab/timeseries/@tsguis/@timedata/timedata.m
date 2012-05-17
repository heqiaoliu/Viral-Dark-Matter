function h = timedata(varargin)

% Copyright 2004 The MathWorks, Inc.

h = tsguis.timedata;
if nargin>0
   h.Timeseries = varargin{1};
end
