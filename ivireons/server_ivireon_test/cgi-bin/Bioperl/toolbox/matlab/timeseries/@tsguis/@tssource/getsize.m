function s = getsize(h, varargin)

% Copyright 2004-2006 The MathWorks, Inc.

if ~isempty(h.Timeseries) && ~isempty(h.Timeseries2)
    ts1Size = h.Timeseries.getdatasamplesize;
    ts2Size = h.Timeseries2.getdatasamplesize;
    s = [ts1Size(1) ts2Size(1) 1];
elseif ~isempty(h.Timeseries)
    ts1Size = h.Timeseries.getdatasamplesize;
    s = [ts1Size(1) 1 1];
else
    s = [0 0];
end

if nargin>1
   s = s(varargin{1});
end