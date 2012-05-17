function tscout = vertcat(tsc1,varargin)
%VERTCAT  Overloaded vertical concatenation for tscollection object 
%
%   TSC = VERTCAT(TSC1, TSC2, ...) performs
%
%         TSC = [TSC1 ; TSC2 ; ...]
% 
%   This operation appends tscollection objects.  The time vectors must not
%   overlap.  The last time in TSC1 must be earlier than the first time in
%   TSC2.  All the tscollection objects to be combined must have the same
%   time series members.      

%   Copyright 2005-2010 The MathWorks, Inc.

if nargin==1
    tscout = tsc1;
    return
else
    tsc{1} = tsc1;
    for i=2:length(varargin)+1
        if isa(varargin{i-1},'tscollection')
            tsc{i} = varargin{i-1}; %#ok<AGROW>
        else
            error('tscollection:vertcat:badtype',...
                'Tscollection objects can only be concatenated with other tscollection objects.')
        end
    end
end

tscout = tsc{1};
for i=1:length(varargin)
    tscout = utdualvertcat(tscout,tsc{i+1});
end


function tscout = utdualvertcat(tsc1,tsc2)
%UTDUALHORZCAT vertical concatenation on two tscollection object

% Check that the members match
memberVars1 = gettimeseriesnames(tsc1);
memberVars2 = gettimeseriesnames(tsc2);
if length(memberVars1) ~= length(memberVars2)  
    error('tscollection:utdualvertcat:badmembernumber',...
        'Each tscollection you are trying to concatenate must have the same number of members.')
end
mismatchingTsnames = union(setdiff(memberVars1,memberVars2),setdiff(memberVars2,memberVars1));
if ~isempty(mismatchingTsnames)
    error('tscollection:utdualvertcat:badmembername',...
        'Both tscollections must have members with the same names.')
end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE The following code is in common with @timeseries/vertcat
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Merge time vectors onto a common basis
[ts1timevec, ts2timevec,outprops] = ...
    timemerge(tsc1.TimeInfo, tsc2.TimeInfo,tsc1.Time,tsc2.Time);

% Concatonate time and ord data
if ts1timevec(end)>ts2timevec(1)
    error('tscollection:utdualvertcat:overlaptime',...
        'The time vectors of the specified time series must not overlap and be consecutive.')
end
time = [ts1timevec;ts2timevec];

% Build output tscollection
tscout = tscollection(time);
tscout.timeInfo = reset(tsc1.TimeInfo,time);
tscout.TimeInfo.Startdate  = outprops.ref;
tscout.TimeInfo.Units = outprops.outunits;
tscout.TimeInfo.Format = outprops.outformat;

% Add concatonated timeseries one at a time
for k=1:length(memberVars1)
    % Concatonate ordinate data
    timeseries1 = getts(tsc1,memberVars1{k});
    timeseries2 = getts(tsc2,memberVars2{k});
    try
        ts = append(timeseries1,timeseries2);
    catch %#ok<*CTCH>
        error('tscollection:utdualvertcat:badsamplesize',...
            'The sample size or data type of %s does not match the other members of the tscollection.',memberVars1{k});
    end
    tscout = tscout.addts(ts,memberVars1{k});
end
  


