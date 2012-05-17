function tsList = getTimeSeries(h,varargin)

%   Copyright 2004-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2006/06/27 23:11:39 $

%% Interface method to get the list of @timeseries to be plotted.
tsList = h.getts;
if nargin>1
    v = varargin{1}; 
    if isnumeric(v) || ischar(v)
        tsList = localGetTs(tsList,v);
    elseif iscell(v)  
        tsListOut = {};
        for k = 1:length(v)
            thists = localGetTs(tsList,v{k});
            if ~isempty(thists) 
               tsListOut = [tsListOut;{thists}];
            end
        end
        tsList = tsListOut;
    else
        tsList = {};
    end
end      

function tsout = localGetTs(tsList,key)

% Extract a timeseries from a cell array by name or by index
if isnumeric(key) && isscalar(key) && key<=numel(tsList)
    tsout = tsList{key};
elseif ischar(key)
    for k=1:numel(tsList)
        if strcmp(key,tsList{k}.Name)
            tsout = tsList{k};
            return;
        end
    end
end
tsout = [];