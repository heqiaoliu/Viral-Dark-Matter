function varargout = auxInfoChartCache(command, varargin)

%   Copyright 1995-2008 The MathWorks, Inc.

persistent cache

mlock;
if isempty(cache)
    cache = struct();
end

switch command % listed in order of estimated frequency of use
    case 'get'
        % Returns a (possibly empty) build info structure if the
        % chartId is in the cache. 
        % Returns an empty structure if the chartId is not in the cache.
        chartId = varargin{1};
        fldName = chartFieldName(chartId);
        if isfield(cache, fldName)
            varargout{1} = true; % found
            varargout{2} = cache.(fldName);
        else
            varargout{1} = false; % not found
            varargout{2} = struct();
        end
        
    case 'set'
        % Sets the build info for the specified chartId.
        chartId = varargin{1};
        auxBuildInfo = varargin{2};
        fldName = chartFieldName(chartId);
        cache.(fldName) = auxBuildInfo;    
        
    case 'clr'
        % Clears from the cache the specified list of chartIds
        chartIds = varargin{1};
        for i = 1:length(chartIds)
            chartId = chartIds(i);
            fldName = chartFieldName(chartId);
            if isfield(cache, fldName)
                cache = rmfield(cache, fldName);
            end
        end
end

function fldName = chartFieldName(chartId)
fldName = ['chart' num2str(chartId)];

