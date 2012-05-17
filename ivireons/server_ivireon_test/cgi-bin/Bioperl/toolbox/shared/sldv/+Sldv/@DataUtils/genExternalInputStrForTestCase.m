function str = genExternalInputStrForTestCase(sldvData, idx, baseWsSldvDataVarName)
    simData = Sldv.DataUtils.getSimData(sldvData,idx);    
    numberInports = length(simData.dataValues);
    if isfield(sldvData,'TestCases') 
        simDataFieldName = 'TestCases';
    else
        simDataFieldName = 'CounterExamples';
    end            
    str = '';
    for j=1:numberInports;
        test_idx_port_j = sprintf('%s.%s(%d).dataValues{%d}',baseWsSldvDataVarName,simDataFieldName,idx,j);
        str = horzcat(str,test_idx_port_j);
        if j~=numberInports
            str = horzcat(str,', ');
        end
    end               
end