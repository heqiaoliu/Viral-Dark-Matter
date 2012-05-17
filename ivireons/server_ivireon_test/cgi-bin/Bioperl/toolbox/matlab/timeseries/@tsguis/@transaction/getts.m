function tsoutInd = getts(h,tsList)

%% Searches a transaction object for actions on a specified timeseries
%% or cell array or time series. Returns a logical array (tsoutInd) 
%% representing the occurrence of changes to each timeseries in the
%% transaction

%   Copyright 2004-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2008/08/20 23:00:13 $


if isa(tsList,'tsdata.timeseries')
    tsoutInd = localfindts(h,tsList);
elseif iscell(tsList)
    tsoutInd = false([length(tsList) 1]);
    for k=1:length(tsList)
        tsoutInd(k) = localfindts(h,tsList{k});
    end
end

function I = localfindts(this,ts)

I = false;
if ~isempty(this.tsTransaction) && ~isempty(find(this.tsTransaction,'Object',ts))
    I = true;
end
