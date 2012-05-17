function inportInfo = constructInportInformation(sldvData)

    dataInputPortInfo = sldvData.AnalysisInformation.InputPortInfo;       
    inportInfo = struct('Name','','BlockPath','','PortIndex',[],'SignalName','','ParentName','');
    
    for i=1:length(dataInputPortInfo)
        if iscell(dataInputPortInfo{i})
            BlockPath = dataInputPortInfo{i}{1}.BlockPath;
            SignalName = dataInputPortInfo{i}{1}.SignalName;
        else
            BlockPath = dataInputPortInfo{i}.BlockPath;
            SignalName = dataInputPortInfo{i}.SignalName;
        end           
        [notUsed,blockName] = strtok(BlockPath,'/');
        inportInfo(i).Name = blockName(2:end);
        inportInfo(i).BlockPath = BlockPath;
        inportInfo(i).PortIndex = i;                        
        inportInfo(i).SignalName = SignalName;
        inportInfo(i).ParentName = inportInfo(i).SignalName;                    
    end       
          
end