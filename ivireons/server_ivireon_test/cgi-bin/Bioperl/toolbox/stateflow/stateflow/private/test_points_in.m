function testPoints = test_points_in(chart, machineName, isSFSfunSim, sfBlkH)

% Copyright 2003-2009 The MathWorks, Inc.

codingDebug = false;
codingExtMode = false;

if nargin < 2 || isempty(machineName)
    machine = sf('get', chart, 'chart.machine');
    machineName = sf('get', machine, 'machine.name');
end

if nargin < 3
    isSFSfunSim = false;
end

if nargin < 4
    sfBlkH = chart2block(chart);
end


if isSFSfunSim
    cs = getActiveConfigSet(machineName);
    codingDebug = strcmp(get_param(cs,'SFSimEnableDebug'),'on');
    if ~isempty(cs) && cs.isValidParam('ExtMode')
        codingExtMode = strcmp(get_param(cs,'ExtMode'), 'on');
    end
end

tp = sf('TestPointsIn', chart, sfBlkH, codingDebug && ~codingExtMode);
testPoints = [tp.data tp.state];

return;
