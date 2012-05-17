function Value = get(ts,varargin)
%GET  Access/Query time series property values.
%
%   VALUE = GET(TS,'PropertyName') returns the value of the 
%   specified property of the time series object.  An equivalent
%   syntax is 
%
%       VALUE = TS.PropertyName 
%   
%   GET(TS) displays all properties of TS and their values.  
%
%   See also TIMESERIES\SET, TIMESERIES\TSPROPS.

%   Copyright 2004-2010 The MathWorks, Inc.

if isempty(ts)
    Value = [];
    return;
end

if numel(ts)==1 % get on a scalar timeseries
    Value = uttsget(ts,varargin{:});
    return
end

% Process array values
if nargin>=2 % get on a timeseries array with specified properties
    if ischar(varargin{1})
        Value = cell(size(ts));
        for k=1:numel(ts)
            Value{k} = uttsget(ts(k),varargin{:});
        end
    elseif iscell(varargin{1})
        props = varargin{1};
        Value = cell(numel(ts),length(props));
        for k=1:numel(ts)
            for j=1:length(props)
                Value{k,j} = uttsget(ts(k),props{j});
            end
        end
    end
else % Return a stuct array for a timeseries array with no props
    for k=numel(ts):-1:1
        Value(k) = uttsget(ts(k),varargin{:});
    end
end
