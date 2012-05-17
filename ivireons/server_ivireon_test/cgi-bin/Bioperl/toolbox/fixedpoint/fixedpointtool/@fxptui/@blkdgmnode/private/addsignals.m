function signals = addsignals(h,signals,path,wsvarname,wsdata,isoneresult)
%ADDSIGNALS adds ToWorkspace and Scopes signals to signals. Does not work
%           with Outport data

%   Author(s): G. Taillefer
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/02/18 02:06:58 $

[time, data] = getaxesdata(h, wsdata, path);
%if this is indexed based we need to adjust the length of time vector
isindexed = 0;

for idx = 1:length(data)
    %create timeseries for column vectors
    if ndims(data{idx}) > 2
        time_indexbased = 0:size(data{idx},ndims(data{idx}))-1;
    else
        rows = size(data{idx},1);
        time_indexbased = 0:rows-1;
    end
    if(isempty(time))
        time = time_indexbased;
        isindexed = 1;
    end
    signals = createtimeseries(signals,wsvarname,path,time,data{idx},isoneresult,isindexed,idx);
end

%--------------------------------------------------------------------------
function signals = createtimeseries(signals,wsvarname, path, time,data,isoneresult,isindexed,prtnum)
%create a timeseries with multiple columns

ts = fxptui.createtimeseries(wsvarname, path, time, data);
ts.DataInfo.UserData.isindexed = isindexed;
if ~(isoneresult)
    ts.PortIndex = prtnum;
end

signals{numel(signals) + 1} = ts;

%---------------------------------------------------------------------------
% [EOF]
