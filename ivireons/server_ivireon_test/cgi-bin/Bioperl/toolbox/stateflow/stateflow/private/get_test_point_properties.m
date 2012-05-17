function [numTps, tpProps] = get_test_point_properties(sfBlkH, isSFSfunSim)

% Copyright 2004-2008 The MathWorks, Inc.

numTps  = 0;
tpProps = {};

try
    if nargin < 2
        isSFSfunSim = false;
    end

    chart = block2chart(sfBlkH);
    if isempty(chart) || ~sf('ishandle', chart)
        return;
    end

    machineName = get_param(bdroot(sfBlkH), 'Name');

    tps = test_points_in(chart, machineName, isSFSfunSim, sfBlkH);
    numTps = length(tps);

    % Bail out early if only number of testpoints is needed
    if nargout < 2
        return;
    end

    tpProps = cell(numTps, 1);

    entry = [];
    for i = 1:numTps
        entry.id      = tps(i);
        entry.name    = sf('FullNameOf', entry.id, chart, '.');
        entry.logName = entry.name;

        if isSFSfunSim
            entry.path  = sprintf('StateflowChart/%s', entry.logName);
        else
            chartPath   = getfullname(sfBlkH);
            name        = slprivate('encpath',entry.logName,'','','');
            entry.path  = slprivate('encpath',chartPath,'StateflowChart',name,'stateflow');
        end

        entry.type    = '';

        tpProps{i} = entry;
    end
catch ME
    disp(ME.message);
    disp('errors occurred in get_test_point_properties for Stateflow charts');
end

return;
