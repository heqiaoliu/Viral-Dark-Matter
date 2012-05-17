function tsList = getts(h,varargin)

% Copyright 2004-2005 The MathWorks, Inc.

%% Returns a list of the @timeseries stored in the tsviewer. The optional
%% second argument is an event, which restricts the @timeseries returned to
%% those containing that event
tsNodes = h.getChildren;
   
if nargin>1
    tsList = {};
    for k=1:length(tsNodes)
        if any(tsNodes(k).Timeseries.Events==varargin{1})
            tsList = [tsList; {tsNodes(k).getTimeSeries}];
        end
    end
else
    tsList = getTimeSeries(tsNodes);
end