function r = get_eml_external_functions(mainMachineId,machineId,targetName,chartId)

machineName = sf('get',machineId,'machine.name');
sfunName = get_sfun_name(mainMachineId,targetName);
sfunFile = [sfunName '.' mexext];

if ~exist(sfunFile,'file')
    r = {};
    return;
end

oldAccel = feature('accel','off');
try
    chartFileNumber = sf('get',chartId, 'chart.chartFileNumber');
    resolvedFuns = feval(sfunName, 'get_eml_resolved_functions_info', ...
                         machineName, chartFileNumber);
catch
    resolvedFuns = [];
end
feature('accel',oldAccel);

cnt = 0;
for i = 1:numel(resolvedFuns)
    resolvedStr = resolvedFuns(i).resolved;
    extPath = get_external_path(resolvedStr);
    if ~isempty(extPath)
        cnt = cnt + 1;
    end
end
r = cell(1,cnt);
cnt = 1;
for i = 1:numel(resolvedFuns)
    resolvedStr = resolvedFuns(i).resolved;
    extPath = get_external_path(resolvedStr);
    if ~isempty(extPath)
        r{cnt} = extPath;
        cnt = cnt + 1;
    end
end

function r = get_external_path(resolvedStr)
    r = [];
    startBracketIndex = strfind(resolvedStr,'[');
    endBracketIndex = strfind(resolvedStr,']');
    if startBracketIndex(1) < endBracketIndex(1)
        propStr = resolvedStr(startBracketIndex+1:endBracketIndex(1)-1);
        pathStr = resolvedStr(endBracketIndex(1)+1:end);
        if (isempty(strfind(propStr,'I')) && ... % Not an internal function
            isempty(strfind(propStr,'B')) && ... % Not a built-in
            isempty(strfind(propStr,'M')))       % Not a MATLAB function
            % This must be a plain user defined external EML file
            r = pathStr;
        end
    end
    
