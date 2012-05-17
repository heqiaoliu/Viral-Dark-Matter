function tsout = ldivide(ts1, ts2, varargin)

% Copyright 2005-2006 The MathWorks, Inc.

tsout = ts1.copy;
tsout.TsValue = ldivide(ts1.TsValue, ts2.TsValue, varargin{:})



