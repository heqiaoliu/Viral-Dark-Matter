function tsList = getTimeSeries(h,varargin)

% Copyright 2005 The MathWorks, Inc.

if ~isempty(h.Plot) && ishandle(h.Plot)
    if nargin>=2
        tsList = h.Plot.getTimeSeries(varargin{1});
        return
    else
        tsList = h.Plot.getTimeSeries;
        if isempty(tsList)
            tsList = {};
        end
    end
else
    tsList = {};
end

%% Don't return empty
tsList = tsList(~cellfun('isempty',tsList));