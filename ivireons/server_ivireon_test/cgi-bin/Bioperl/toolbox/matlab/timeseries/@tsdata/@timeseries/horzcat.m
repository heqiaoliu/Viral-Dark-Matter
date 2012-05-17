function ts = horzcat(this)
%HORZCAT  Overloaded horizontal concatenation for time series objects
%
% HORZCAT is disabled by design. Only VERTCAT is supported.
%
%   See also TIMESERIES/VERTCAT
%

%   Copyright 2006-2010 The MathWorks, Inc.

ts = tsdata.timeseries;
ts.TsValue = this.Tsvalue;