function isExtMode = sim_mode_is_external(handle)

if is_sf_id(handle)
    [CHART, MACHINE] = sf('get', 'default', 'chart.isa', 'machine.isa');
    switch sf('get', handle, '.isa')
        case CHART
            machine = actual_machine_referred_by(handle);
        case MACHINE
            machine = handle;
        otherwise
            error('Stateflow:UnexpectedError','Input must be Stateflow chart or machine.');
    end
    modelH = sf('get', machine, 'machine.simulinkModel');
else
    modelH = handle;
end

simMode = get_param(modelH, 'SimulationMode');
isRapidAccel = ~strcmpi(get_param(modelH, 'RapidAcceleratorSimStatus'), 'inactive');
isExtMode = strcmp(simMode, 'external') && ~isRapidAccel;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = is_sf_id(mId)

result = 0;

if ~isempty(mId) && ((floor(mId) - mId) == 0)
    result = sf('ishandle', mId);
end
