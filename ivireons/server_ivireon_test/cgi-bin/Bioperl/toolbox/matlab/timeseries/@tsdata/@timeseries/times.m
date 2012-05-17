function tsout = times(ts1, ts2, varargin)

% Copyright 2004-2006 The MathWorks, Inc.

if isnumeric(ts2)
    tsout = copy(ts1);
    tsout.TsValue = times(ts1.TsValue,ts2,varargin{:});
else
    tsout = copy(ts1);
    tsout.TsValue = times(ts1.TsValue,ts2.TsValue,varargin{:});
end