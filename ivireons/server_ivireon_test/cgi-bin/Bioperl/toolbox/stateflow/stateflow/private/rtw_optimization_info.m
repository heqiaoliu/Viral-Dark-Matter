function result = rtw_optimization_info(machineName,mainMachineName,chartFileNumber,specialization,optimProp)

%   Copyright 1995-2010 The MathWorks, Inc.
%   $Revision: 1.7.2.14.2.1 $  $Date: 2010/07/26 15:40:31 $
result = [];

try
    % Map multi-instance normal mode copied model names to original mode name
    if(isequal(get_param(mainMachineName, 'ModelReferenceMultiInstanceNormalModeCopy'), 'on'))
        if(isequal(machineName, mainMachineName))
            machineName = get_param(mainMachineName, 'ModelReferenceNormalModeOriginalModelName');
        end
        
        mainMachineName = get_param(mainMachineName, 'ModelReferenceNormalModeOriginalModelName');
    end
    
    infoStruct = sf('Private','infomatman','load','binary',machineName,mainMachineName,'rtw');

	chartNumber = find(infoStruct.chartFileNumbers==chartFileNumber);
    if ~isempty(chartNumber)
        instanceIdx = find(strcmp({infoStruct.chartInfo(chartNumber).instanceInfo.specialization}, specialization));
    end

	switch(optimProp)
	case 'chart_inlinable'
        result = strcmp(infoStruct.chartInfo(chartNumber).instanceInfo(instanceIdx).Inline,'Yes');
	case 'chart_multi_instanced'
        result = strcmp(infoStruct.chartInfo(chartNumber).instanceInfo(instanceIdx).IsMultiInstanced,'Yes');
	case 'reusable_outputs'
        result = infoStruct.chartInfo(chartNumber).instanceInfo(instanceIdx).ReusableOutputs;
	case 'expressionable_inputs'
        result = infoStruct.chartInfo(chartNumber).instanceInfo(instanceIdx).ExpressionableInputs;
    case 'machineDataVarInfo'
        result = infoStruct.machineDataVarInfo;
    otherwise
        result = infoStruct.chartInfo(chartNumber).instanceInfo(instanceIdx).(optimProp);
	end
catch ME
    disp(ME.message);
end
return;

