function prepareInputDataForCGVObj(obj)

%   Copyright 2010 The MathWorks, Inc.

    obj.getInputMATFilePaths;

    numTestCases = length(obj.TcIdx);
    for idx=1:numTestCases
        simData = obj.SimDataTimeSeries(obj.TcIdx(idx));        
        sldvParameters = simData.paramValues;
        
        data = simData.dataValues;         %#ok<NASGU>
        evalc(sprintf('%s=data',obj.BaseWSSldvDataName));
        save(obj.CGVMATFileInput{idx},obj.BaseWSSldvDataName);
        
        stoptime = simData.timeValues(end); %#ok<NASGU>
        evalc(sprintf('%s=stoptime',obj.BaseWSStopTimeName));
        save(obj.CGVMATFileInput{idx},obj.BaseWSStopTimeName,'-append');                        
                        
        for jdx=1:length(sldvParameters)
            if isfield(obj.BaseWSSimulinkParameters,sldvParameters(jdx).name)
                paramValue = obj.BaseWSSimulinkParameters.(sldvParameters(jdx).name);
                paramValue.Value = sldvParameters(jdx).value;
            else
                paramValue = sldvParameters(jdx).value; %#ok<NASGU>
            end            
            evalc(sprintf('%s=paramValue',sldvParameters(jdx).name));
            save(obj.CGVMATFileInput{idx},sldvParameters(jdx).name,'-append');                    
        end
    end
end
% LocalWords:  stoptime
