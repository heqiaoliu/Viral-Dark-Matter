function tsout = pvset(ts,varargin)
%PVSET  Set properties of time series.
%
%   TS = PVSET(TS,'Property1',Value1,'Property2',Value2,...)
%   sets the values of the properties 'Property1', 'Property2', ...
%
%   See also TIMESERIES\SET.

%   Copyright 2004-2010 The MathWorks, Inc.

if numel(ts)~=1
    error('timeseries:pvset:noarray',...
     'The pvset method can only be used for a single timeseries object');
end
tsout = set(ts,varargin{:});
