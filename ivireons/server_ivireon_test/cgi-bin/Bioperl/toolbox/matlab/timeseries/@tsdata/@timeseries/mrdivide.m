function tsout = mrdivide(ts1, ts2, varargin)

% Copyright 2004-2006 The MathWorks, Inc.

tsout = ts1.copy;
tsout.TsValue = mrdivide(ts1.TsValue,ts2.TsValue,varargin{:});



