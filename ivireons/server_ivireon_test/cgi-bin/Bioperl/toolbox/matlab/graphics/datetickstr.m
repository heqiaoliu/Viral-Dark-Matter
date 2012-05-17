function out = datetickstr(D,varargin)
% Returns the date string associated with the values input. Any values of
% NaN are returned as empty strings:

out = repmat({''},size(D));
out(~isnan(D)) = cellstr(datestr(D(~isnan(D)),varargin{:}));