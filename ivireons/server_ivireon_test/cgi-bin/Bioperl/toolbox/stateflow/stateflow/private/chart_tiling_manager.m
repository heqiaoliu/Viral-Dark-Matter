function out = chart_tiling_manager(chartid, command)

% Copyright 2005 The MathWorks, Inc.

    rt = sfroot;
    out = [];
    chart = rt.idToHandle(chartid);
    if (~isempty(chart))
        switch (command)
          case 'register'
            register(chart);
          case 'unregister'
            unregister(chart)
          case 'start'
            start_tiling(chart);
          case 'stop'
            stop_tiling(chart);
          case 'is_tiled'
            out = is_tiling;
        end
    end
end


function [oldChartIds] = all_charts_access(varargin)
    persistent chartIds;
    oldChartIds = chartIds;
    if (nargin>0)
        chartIds = varargin{1};
    end
end



function register(chart)
    chartId = chart.Id;
    if (~is_registered(chartId))
        chartIds = all_charts_access;
        all_charts_access([chartIds, chartId]);
        if (isequal(chart.ShowPageBoundaries, 'on'))
            start_tiling(chart);
        end
    end
end

function unregister(chart)
    chartId = chart.Id;
    if(is_registered(chartId))
        stop_tiling(chart);
        chartIds = all_charts_access;
        chartix = (chartIds==chartId);
        chartIds(chartix) = [];
        all_charts_access(chartIds);
    end
end



function [oldChartIds] = active_charts_access(varargin)
    persistent chartIds;
    oldChartIds = chartIds;
    if (nargin>0)
        chartIds = varargin{1};
    end
end

function [oldListeners] = modifying_listeners_access(varargin)
    persistent listeners;
    oldListeners = listeners;
    if (nargin>0)
        listeners = varargin{1};
    end
end


function repatch_callback(evSource, evData, chart) %#ok
    chart_retile(chart);
end 

function ir = is_registered(chartId)
    chartIds = all_charts_access;
    ir = (~isempty(chartIds) && any(chartIds==chartId));
end


function is = is_tiling(chartId)
    chartIds = active_charts_access;
    is = (~isempty(chartIds) && any(chartIds==chartId));
end


function l = get_modifying_listener(chart, obj, propname)
    l = handle.listener(obj, ...
                        findprop(obj, propname), ...
                        'PropertyPostSet', ...
                        {@repatch_callback, chart});
end


function nl = get_new_listeners(chart, subsystem)
    % Paper size not needed since it is a derived property
    ssProps = {'PaperType', 'TiledPaperMargins', 'TiledPageScale', ...
               'ShowPageBoundaries', 'PaperPositionMode', 'PaperUnits'};
    nl = cell(1,2*length(ssProps) + 2);
    for i=1:length(ssProps)    
        nl(1,2*i-1) = {get_modifying_listener(chart, subsystem, ssProps{i})};
        nl(1,2*i) = {get_modifying_listener(chart, chart, ssProps{i})};
    end
    axid = sf('get', chart.id, '.hg.axes');
    axo = handle(axid);
    nl(1, i+1) = {get_modifying_listener(chart, axo, 'XLim')};
    nl(1, i+2) = {get_modifying_listener(chart, axo, 'YLim')};
end


function start_tiling(chart)
    chartId = chart.Id;
    if (~is_tiling(chartId))
        subsystem = chart.up;
        chartIds = active_charts_access;
        listeners = modifying_listeners_access;
        active_charts_access([chartIds, chartId]);
        listeners = [listeners, {get_new_listeners(chart, subsystem)}];
        modifying_listeners_access(listeners);
        chart_retile(chart);
    end
end

function stop_tiling(chart)
    chartId = chart.Id;
    if (is_tiling(chartId))
        chartIds = active_charts_access;
        listeners = modifying_listeners_access;
        chartix = (chartIds==chartId);
        chartIds(chartix) = [];
        listeners(chartix) = [];
        active_charts_access(chartIds);
        modifying_listeners_access(listeners);
        ax = sf('get', chart.id, '.hg.axes');
        delete(findobj(ax, 'Type', 'patch', 'Tag', 'print_patch' ));
    end
end

