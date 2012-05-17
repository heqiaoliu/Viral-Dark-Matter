function tsList = getTimeSeries(h,varargin)

% Copyright 2004-2008 The MathWorks, Inc.

%% Overloaded getTimeSeries. Needed bacause the base method relies on a
%% response being present in the plot to return a non-empty list of
%% timeseries. This may not be the case of @xyplots because the mergedlg 
%% (which needs to call getTimeSeries) is opened before plot creation
%% when the lengths mismatch
if ~isempty(h.Plot) && length(h.Plot.Responses)>0
    if nargin>=2
        tsList = h.Plot.getTimeSeries(varargin{1});
        return;
    else
        tsList = h.Plot.getTimeSeries;
    end
else
   tsList = {};
   
   if nargin>=2
       if numel(h.Timeseries1)>0 && strcmp(h.Timeseries1.Name,varargin{1})
           tsList = h.Timeseries1;
           return
       end
       if numel(h.Timeseries2)>0 && strcmp(h.Timeseries2.Name,varargin{1})
           tsList = h.Timeseries2;
           return
       end
   else
       tsList = {h.Timeseries1,h.Timeseries2};
   end
end

%% Don't return empty
tsList = tsList(~cellfun('isempty',tsList));

