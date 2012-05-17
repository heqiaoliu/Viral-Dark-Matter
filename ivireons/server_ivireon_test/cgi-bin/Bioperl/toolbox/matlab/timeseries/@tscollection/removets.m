function h = removets(h, tsname)
%REMOVETS  Remove time series object(s) from a tscollection object.
%
% REMOVETS(TSC,NAME) removes a time series object, whose name is specified
% in string NAME, from the tscollection TSC. 
%
% REMOVETS(TSC,NAMES) removes time series objects, whose names are stored
% in a cell array NAME, from the tscollection TSC.
%

%   Copyright 2005-2006 The MathWorks, Inc.
%

if iscellstr(tsname) || ischar(tsname)
    I = ismember(gettimeseriesnames(h),strtrim(tsname));
    h.Members_(I) = [];
else
    error('timeseries:removets:invalidname',...
        'The second input argument must be a time series name or a cell array of name strings.')
end
