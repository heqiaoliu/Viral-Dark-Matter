function istiled = is_print_job_tiled(printobj)

% Copyright 2005 The MathWorks, Inc.

    istiled = isequal(get_param(printobj, 'PaperPositionMode'), 'tiled');

    % But wait!  If this is a Stateflow-sponsored print, we 
    % have to ask SF about tiledness
    if inmem('-isloaded', 'sf')
        portal = sf('find','all','portal.sfPrintPortal', 1);
        if ~isempty(portal) && sf('get',portal(1),'.sfBasedPrintJob')
            chart = sf('get', portal(1), '.chart');
            if ~isempty(chart)
                udchart = idToHandle(sfroot, chart);
                istiled = isequal(udchart.PaperPositionMode, 'tiled');
            end            
        end        
    end        
end
