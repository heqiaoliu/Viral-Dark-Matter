function data = getdatasamples(this,I)
%GETDATASAMPLES Obtain a subset of timeseries samples using a subscript/index
%array.
%
%   This operation returns the data from a subset of timeseries samples
%   extracted based in the supplied subscript/index array.
%
%   DATA = GETDATASAMPLES(TS,I) returns the data obtained from the samples of the
%   timeseries TS corresponding to the time(s) TS.TIME(I).
%
%   See also TIMESERIES/GETSAMPLES, TIMESERIES/RESAMPLE

%   Copyright 2009-2010 The MathWorks, Inc.

if numel(this)~=1
    error('timeseries:getdatasamples:noarray',...
        'The getdatasamples method can only be used for a single timeseries object');
end
if isempty(I)
    data = [];
    return;
elseif islogical(I)
    if length(I)>this.Length
        error('timeseries:getdatasamples:badlogicalsubscript',...
            'Logical index exceeds time vector length.')
    end
elseif isnumeric(I) && isvector(I) && isreal(I)
    if this.Length==0 || any(I<1) || any(I>this.Length) || ~isequal(round(I),I)
        error('timeseries:getdatasamples:badsubscript',...
            'Indices must be positive, integers that do not exceed the time vector length.')
    end
else
    error('timeseries:getdatasamples:badind',...
        'The subsrcipt/index array must be a vector of logicals or positive integers that do not exceed the time vector length.');
end   

% Slice and return the data 
data = this.Data;
ind = repmat({':'},[ndims(data) 1]);
if isempty(I)
    data = [];
elseif this.IsTimeFirst
    data = data(I,ind{2:end});
else
    data = data(ind{1:end-1},I);
end


