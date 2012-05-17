function this = ctranspose(this)
% TRANSPOSETIMEDIM  Return a new time series object in which the isTimeFirst value
% is changed from TS and the data is permuted accordingly.
%
%   Copyright 2005-2010 The MathWorks, Inc.

this = builtin('ctranspose',this);
for k=1:numel(this)
    this(k) = timeseries.transposetimedim(this(k));
end