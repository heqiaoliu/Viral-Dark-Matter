function [rnames,cnames] = getrcname(src)
%GETIONAMES  Returns time series names.

%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.6.3 $ $Date: 2005/12/15 20:58:00 $

rnames = {};
cnames = {};

%% Do not return channel names from a single timeseries data src since the 
%% assignment of time series columns to axes can be arbitrary
if numel(src.Timeseries2)>0 && numel(src.Timeseries)>0
    for row=1:size(src.Timeseries2.Data,2)
        rnames{row} = sprintf('%s:%d',src.Timeseries2.Name,row);
    end
    for col=1:size(src.Timeseries.Data,2)
        cnames{col} = sprintf('%s:%d',src.Timeseries.Name,col);
    end
end
