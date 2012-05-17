function [ts1timevec,outprops,warningFlag] = utArithCommonTime(ts1,ts2)
%UTARITHCOMMONTIME
%
 
% Copyright 2006-2010 The MathWorks, Inc.

% Check if the length of time matches
if ~isequal(ts1.Length,ts2.Length)
    error('timeseries:utArithCommonTime:lengthmis', ...
        'Time series lengths are mismatched.')
end
% Merge time vectors onto a common basis
[ts1timevec, ts2timevec, outprops] = ...
    timemerge(ts1.TimeInfo, ts2.TimeInfo,ts1.Time,ts2.Time);
% Deal with empty object: return an empty ts which is consistent with
% Matlab command 2+[], 2./[] etc.
if isempty(ts1timevec) || isempty(ts2timevec)
    ts1timevec = [];
    outprops = [];
    warningFlag = false;
    return
end
% Relative time vectors - remove initial values and prepare a warning
warningFlag = false;    
if isempty(outprops.ref) && (ts1timevec(1)~=ts2timevec(1))
    ts1timevec = ts1timevec-ts1timevec(1);
    ts2timevec = ts2timevec-ts2timevec(1);
    warningFlag = true;
end
% Check that the time vectors match
if ~tsIsSameTime(ts1timevec,ts2timevec)
    error('timeseries:utArithCommonTime:badsizes', ...
        xlate('To arithmetically combine time series, their time vectors must be the same within a scalar offset.'));
end
